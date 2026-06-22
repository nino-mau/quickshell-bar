pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.Commons

// Very simple Wayland session lock: a dimmed surface with a clock and a
// password field. Trigger it over IPC, e.g.
//   qs -c bar ipc call lock lock
Scope {
    id: root

    property bool locked: false

    // Per-output wallpaper (output name -> image path), queried from awww so the
    // blurred lock backdrop matches the live wallpaper on each monitor.
    property var wallpapers: ({})

    function refreshWallpapers(): void {
        wallpaperProc.running = true;
    }

    function parseWallpapers(out: string): void {
        const map = {};
        for (const line of String(out || "").split("\n")) {
            const match = line.match(/([\w-]+):.*currently displaying: image: (.+)$/);
            if (match)
                map[match[1].trim()] = match[2].trim();
        }
        root.wallpapers = map;
    }

    Process {
        id: wallpaperProc

        command: ["awww", "query"]
        stdout: StdioCollector {
            onStreamFinished: root.parseWallpapers(text)
        }
    }

    Component.onCompleted: refreshWallpapers()

    IpcHandler {
        target: "lock"

        function lock(): void {
            root.locked = true;
        }
        function unlock(): void {
            root.locked = false;
        }
        function toggle(): void {
            root.locked = !root.locked;
        }
    }

    LockContext {
        id: context

        onUnlocked: root.locked = false
    }

    onLockedChanged: {
        if (locked) {
            context.reset();
            refreshWallpapers();
        }
    }

    WlSessionLock {
        id: session

        locked: root.locked

        WlSessionLockSurface {
            id: surface

            // Fallback colour shown if the wallpaper can't be loaded.
            color: Theme.bg0

            // Blurred wallpaper backdrop.
            Image {
                id: wallpaperImage

                readonly property string path: root.wallpapers[surface.screen ? surface.screen.name : ""] ?? ""

                anchors.fill: parent
                source: path.length > 0 ? "file://" + path : ""
                visible: status === Image.Ready
                fillMode: Image.PreserveAspectCrop
                // Blurred anyway, so cap the decode to the surface size.
                sourceSize.width: surface.width
                sourceSize.height: surface.height
                asynchronous: true
                cache: false
                layer.enabled: true
                layer.effect: MultiEffect {
                    blurEnabled: true
                    blur: 1.0
                    blurMax: 64
                }
            }

            // Translucent dim on top of the blur for contrast/readability.
            Rectangle {
                anchors.fill: parent
                color: Theme.withAlpha(Theme.bg0, 0.4)
            }

            SystemClock {
                id: clock

                precision: SystemClock.Minutes
            }

            // Hidden input that captures the password. Bidirectional sync with
            // the context (a plain binding would break on input).
            TextInput {
                id: passwordInput

                visible: false
                enabled: !context.authenticating
                echoMode: TextInput.Password
                focus: true

                onTextChanged: {
                    if (context.currentText !== text)
                        context.currentText = text;
                }
                onAccepted: context.tryUnlock()

                Connections {
                    target: context

                    function onCurrentTextChanged(): void {
                        if (passwordInput.text !== context.currentText)
                            passwordInput.text = context.currentText;
                    }
                }

                Component.onCompleted: forceActiveFocus()
            }

            // Re-grab focus on cursor movement (works around focus quirks after
            // monitor/suspend transitions).
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.NoButton
                onPositionChanged: passwordInput.forceActiveFocus()
            }

            ColumnLayout {
                anchors.centerIn: parent
                spacing: Tokens.space6

                // Clock
                ColumnLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: Tokens.space1

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: Qt.formatDateTime(clock.date, "HH:mm")
                        color: Theme.fg
                        font.family: Style.defaultFontFamily
                        font.pixelSize: Tokens.text7XL
                        font.weight: Tokens.fontBold
                    }

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: Qt.formatDateTime(clock.date, "dddd, d MMMM")
                        color: Theme.grey2
                        font.family: Style.defaultFontFamily
                        font.pixelSize: Tokens.textLG
                        font.weight: Tokens.fontMedium
                    }
                }

                // Password field
                Rectangle {
                    id: field

                    Layout.alignment: Qt.AlignHCenter
                    implicitWidth: Tokens.space80
                    implicitHeight: Tokens.space12
                    radius: Tokens.radiusFull
                    color: Theme.withAlpha(Theme.bg2, 0.7)
                    border.width: Tokens.border1
                    border.color: context.status.length > 0 ? Theme.red : Theme.withAlpha(Theme.bg4, 0.5)

                    Behavior on border.color {
                        ColorAnimation {
                            duration: Tokens.duration140
                            easing.type: Easing.InOutQuad
                        }
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: Tokens.space5
                        anchors.rightMargin: Tokens.space5
                        spacing: Tokens.space3

                        RemixIcon {
                            name: context.authenticating ? "loader-4-line" : "lock-2-line"
                            color: Theme.grey2
                            size: Tokens.textXL

                            RotationAnimation on rotation {
                                running: context.authenticating
                                from: 0
                                to: 360
                                duration: 1000
                                loops: Animation.Infinite
                            }
                        }

                        // Masked dots, one per typed character.
                        Text {
                            Layout.fillWidth: true
                            text: "●".repeat(context.currentText.length)
                            color: Theme.fg
                            elide: Text.ElideRight
                            font.family: Style.defaultFontFamily
                            font.pixelSize: Tokens.textBase

                            // Placeholder when empty.
                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                visible: context.currentText.length === 0
                                text: qsTr("Enter password")
                                color: Theme.withAlpha(Theme.fg, 0.4)
                                font.family: Style.defaultFontFamily
                                font.pixelSize: Tokens.textBase
                            }
                        }
                    }
                }

                // Status / error line (reserves its row so layout doesn't jump).
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredHeight: implicitHeight
                    text: context.status
                    color: Theme.red
                    opacity: context.status.length > 0 ? 1 : 0
                    font.family: Style.defaultFontFamily
                    font.pixelSize: Tokens.textSM

                    Behavior on opacity {
                        NumberAnimation {
                            duration: Tokens.duration140
                        }
                    }
                }
            }
        }
    }
}
