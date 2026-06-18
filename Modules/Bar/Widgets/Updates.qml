pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import Quickshell
import qs.Commons
import qs.Services as Services

AbstractButton {
    id: root

    property color baseColor
    property bool vertical: true

    readonly property bool hasUpdates: Services.Updates.hasUpdates
    readonly property bool checking: Services.Updates.loading
    readonly property bool installing: Services.Updates.updating
    readonly property color accentColor: installing ? Theme.blue : capsule.textColor

    // One distinct icon per state: installing > available > checking > up to date.
    // "available" outranks "checking" so a background re-check never disturbs the
    // icon + count once updates are known.
    readonly property string installingIcon: "download-cloud-2-line"
    readonly property string checkingIcon: "loader-4-line"
    readonly property string availableIcon: "download-cloud-fill"
    readonly property string upToDateIcon: "download-cloud-fill"
    readonly property string currentIcon: installing ? installingIcon : (hasUpdates ? availableIcon : (checking ? checkingIcon : upToDateIcon))

    Layout.fillWidth: root.vertical
    Layout.fillHeight: !root.vertical
    Layout.preferredHeight: Math.max(capsule.implicitHeight, implicitHeight)
    Layout.preferredWidth: Math.max(capsule.implicitHeight, implicitWidth)
    topPadding: root.vertical ? capsule.contentPadding : 0
    bottomPadding: root.vertical ? capsule.contentPadding : 0
    leftPadding: root.vertical ? 0 : capsule.contentPadding
    rightPadding: root.vertical ? 0 : capsule.contentPadding
    hoverEnabled: true
    Accessible.name: qsTr("System updates")

    function launch(): void {
        // Open a terminal running the first available helper (or pacman) and
        // keep the shell open afterwards.
        Quickshell.execDetached(["ghostty", "-e", "sh", "-c", "if command -v paru >/dev/null 2>&1; then paru; elif command -v yay >/dev/null 2>&1; then yay; else sudo pacman -Syu; fi; exec $SHELL"]);
    }

    onClicked: launch()

    HoverHandler {
        cursorShape: Qt.PointingHandCursor
    }

    TapHandler {
        acceptedButtons: Qt.RightButton
        onTapped: Services.Updates.reload()
    }

    background: Capsule {
        id: capsule

        vertical: root.vertical
        baseColor: root.baseColor
        hovered: root.hovered || root.down
    }

    contentItem: Item {
        id: content

        implicitWidth: layout.implicitWidth
        implicitHeight: layout.implicitHeight

        GridLayout {
            id: layout

            property real textSpacing: root.hasUpdates ? (root.vertical ? capsule.contentSpacing : 6) : 0

            anchors.centerIn: parent
            columns: root.vertical ? 1 : 2
            rowSpacing: textSpacing
            columnSpacing: textSpacing

            Behavior on textSpacing {
                NumberAnimation {
                    duration: 260
                    easing.type: Easing.InOutQuad
                }
            }

            // Updates icon
            RemixIcon {
                id: updatesIcon

                Layout.alignment: Qt.AlignCenter
                Layout.preferredWidth: capsule.iconSize
                Layout.preferredHeight: capsule.iconSize
                name: root.currentIcon
                color: root.accentColor
                size: capsule.iconSize

                // Spin the loader icon while checking for updates. Use a plain
                // RotationAnimation (not an Animator) so the property is updated
                // on the main thread and resets cleanly to 0 when checking stops.
                RotationAnimation {
                    target: updatesIcon
                    from: 0
                    to: 360
                    duration: 1000
                    loops: Animation.Infinite
                    running: root.currentIcon === root.checkingIcon
                    onStopped: updatesIcon.rotation = 0
                }

                // Pulse the archive icon while an upgrade is downloading/installing.
                SequentialAnimation {
                    running: root.installing
                    loops: Animation.Infinite
                    onStopped: updatesIcon.opacity = 1

                    NumberAnimation {
                        target: updatesIcon
                        property: "opacity"
                        from: 1
                        to: 0.4
                        duration: 600
                        easing.type: Easing.InOutSine
                    }
                    NumberAnimation {
                        target: updatesIcon
                        property: "opacity"
                        from: 0.4
                        to: 1
                        duration: 600
                        easing.type: Easing.InOutSine
                    }
                }

                Behavior on color {
                    ColorAnimation {
                        duration: 140
                        easing.type: Easing.InOutQuad
                    }
                }
            }

            // Update count
            Item {
                id: countWrapper

                Layout.alignment: Qt.AlignCenter
                readonly property bool shown: root.hasUpdates
                property real textWidth: shown ? countText.implicitWidth : 0
                Layout.preferredWidth: textWidth
                Layout.preferredHeight: countText.implicitHeight
                clip: true
                opacity: shown ? 1 : 0

                Text {
                    id: countText

                    anchors.verticalCenter: parent.verticalCenter
                    text: Services.Updates.countText
                    color: root.accentColor
                    font.pixelSize: root.vertical ? capsule.textSize : capsule.horizontalTextSize
                    font.weight: Tokens.fontMedium

                    Behavior on color {
                        ColorAnimation {
                            duration: 140
                            easing.type: Easing.InOutQuad
                        }
                    }
                }

                Behavior on textWidth {
                    NumberAnimation {
                        duration: 260
                        easing.type: Easing.InOutQuad
                    }
                }

                Behavior on opacity {
                    NumberAnimation {
                        duration: 140
                        easing.type: Easing.InOutQuad
                    }
                }
            }
        }
    }
}
