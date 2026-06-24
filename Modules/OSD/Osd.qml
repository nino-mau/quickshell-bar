pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.Commons
import qs.Services as Services

// Simple on-screen-display for volume changes. Pops a pill near the top center
// whenever the output volume or mute state changes, then auto-hides. Styled to
// match the notification toasts (see NotificationPopups.qml).
Variants {
    model: Quickshell.screens

    delegate: PanelWindow {
        id: window

        required property ShellScreen modelData

        readonly property int popupWidth: 320
        readonly property int topOffset: Config.edge === "top" ? Style.barHeight + Style.barMarginTop + Tokens.space3 : Tokens.space5

        // Visibility state, driven by the hide timer and animated below.
        property bool shown: false
        // Suppress the OSD during the first moment after launch so the initial
        // volume binding settling doesn't flash a pill on screen.
        property bool ready: false

        readonly property bool muted: Services.Audio.muted
        readonly property real value: muted ? 0 : Services.Audio.volume

        // OSD styling (widget-specific; built from primitives), mirroring the
        // notification toast so the two read as one family.
        QtObject {
            id: osd

            readonly property int radius: Tokens.radius3XL
            readonly property int contentPadding: Tokens.space4
            readonly property int horizontalGap: Tokens.space4
            readonly property real backgroundOpacity: 0.6
            readonly property int borderWidth: Tokens.border1
            readonly property color border: Theme.border
            readonly property color background: Theme.bg1
            readonly property color color: Theme.withAlpha(background, backgroundOpacity)
            readonly property int iconSize: Tokens.textXL
            readonly property color iconColor: window.muted ? Theme.red : Theme.fg
            readonly property color trackColor: Theme.bg2
            readonly property color fillColor: window.muted ? Theme.red : Theme.blue
            readonly property int trackThickness: Tokens.space2
            readonly property color valueColor: Theme.fg
            readonly property int valueTextSize: Tokens.textSM
            readonly property int valueFontWeight: Tokens.fontMedium
        }

        screen: modelData
        color: "transparent"
        visible: shown || pill.opacity > 0.01
        implicitWidth: popupWidth
        implicitHeight: pill.implicitHeight + Tokens.space3

        WlrLayershell.namespace: "quickshell-osd-" + (screen ? screen.name : "unknown")
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.exclusionMode: ExclusionMode.Ignore
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

        // Display-only: never steal pointer input.
        mask: Region {}

        anchors {
            top: true
        }

        margins {
            top: window.topOffset
        }

        function trigger(): void {
            if (!ready)
                return;
            shown = true;
            hideTimer.restart();
        }

        Timer {
            id: startupTimer

            interval: 1500
            running: true
            onTriggered: window.ready = true
        }

        Timer {
            id: hideTimer

            interval: Tokens.duration1000 + Tokens.duration500
            repeat: false
            onTriggered: window.shown = false
        }

        Connections {
            target: Services.Audio

            function onVolumeChanged(): void {
                window.trigger();
            }

            function onMutedChanged(): void {
                window.trigger();
            }
        }

        Rectangle {
            id: pill

            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            width: window.popupWidth
            implicitHeight: content.implicitHeight + osd.contentPadding * 2
            radius: osd.radius
            color: osd.color
            border.width: osd.borderWidth
            border.color: osd.border

            scale: window.shown ? 1.0 : 0.8
            opacity: window.shown ? 1.0 : 0.0

            Behavior on scale {
                SpringAnimation {
                    spring: 3.0
                    damping: 0.4
                    epsilon: 0.01
                    mass: 0.8
                }
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: Tokens.duration300
                    easing.type: Easing.OutCubic
                }
            }

            RowLayout {
                id: content

                anchors.fill: parent
                anchors.margins: osd.contentPadding
                anchors.leftMargin: osd.contentPadding + Tokens.space1
                anchors.rightMargin: osd.contentPadding + Tokens.space1
                spacing: osd.horizontalGap

                RemixIcon {
                    Layout.alignment: Qt.AlignVCenter
                    name: {
                        if (window.muted)
                            return "volume-mute-line";
                        if (Services.Audio.volume <= 0)
                            return "volume-off-vibrate-line";
                        if (Services.Audio.volume < 0.65)
                            return "volume-down-line";
                        return "volume-up-line";
                    }
                    color: osd.iconColor
                    size: osd.iconSize

                    Behavior on color {
                        ColorAnimation {
                            duration: Tokens.duration140
                            easing.type: Easing.InOutQuad
                        }
                    }
                }

                // Progress track.
                Rectangle {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    height: osd.trackThickness
                    radius: height / 2
                    color: osd.trackColor

                    Rectangle {
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        width: parent.width * Math.max(0, Math.min(1, window.value))
                        radius: parent.radius
                        color: osd.fillColor

                        Behavior on width {
                            NumberAnimation {
                                duration: Tokens.duration150
                                easing.type: Easing.OutCubic
                            }
                        }

                        Behavior on color {
                            ColorAnimation {
                                duration: Tokens.duration140
                                easing.type: Easing.InOutQuad
                            }
                        }
                    }
                }

                Text {
                    Layout.alignment: Qt.AlignVCenter
                    Layout.preferredWidth: Tokens.space10
                    horizontalAlignment: Text.AlignRight
                    text: Math.round(window.value * 100) + "%"
                    color: osd.valueColor
                    font.family: Style.defaultFontFamily
                    font.pixelSize: osd.valueTextSize
                    font.weight: osd.valueFontWeight
                }
            }
        }
    }
}
