pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import QtQuick.Layouts
import qs.Commons
import qs.Services as Services

MouseArea {
    id: root

    readonly property string icon: {
        if (Services.Audio.muted) {
            return Icons.volumeMuted;
        }
        if (Services.Audio.volume <= 0) {
            return Icons.volumeOff;
        }
        if (Services.Audio.volume < 0.3) {
            return Icons.volumeLow;
        }
        if (Services.Audio.volume >= 0.3 && Services.Audio.volume < 0.65) {
            return Icons.volumeMedium;
        }
        return Icons.volumeHigh;
    }

    readonly property bool volumeChanging: volumeChangeTimer.running

    implicitWidth: pill.implicitWidth
    implicitHeight: Style.barHeight
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor

    onClicked: event => {
        const entry = DesktopEntries.heuristicLookup("wiremix");
        if (entry) {
            Quickshell.execDetached(["ghostty", "-e", "wiremix"]);
        } else if (event.button === Qt.LeftButton) {
            Services.Audio.toggleMuted();
        } else {
            Services.Audio.cycleNextSink();
        }
    }

    onWheel: event => {
        if (event.angleDelta.y > 0)
            Services.Audio.incrementVolume();
        else if (event.angleDelta.y < 0)
            Services.Audio.decrementVolume();
    }

    function showVolumeText(): bool {
        if (volumeChanging) {
            return true;
        }
        if (Services.Audio.muted) {
            return false;
        }
        return false;
    }

    Connections {
        target: Services.Audio

        function onVolumeChanged(): void {
            volumeChangeTimer.restart();
        }
    }

    Timer {
        id: volumeChangeTimer

        interval: 700
    }

    Pill {
        id: pill

        anchors.centerIn: parent
        implicitWidth: layout.implicitWidth + 19
        hovered: root.containsMouse

        RowLayout {
            id: layout
            property real textSpacing: root.showVolumeText() ? Style.pillGap : 0

            anchors.centerIn: parent
            spacing: textSpacing

            Behavior on textSpacing {
                NumberAnimation {
                    duration: Tokens.duration260
                    easing.type: Easing.InOutQuad
                }
            }

            Text {
                text: root.icon
                color: Style.pillText
                font.family: Style.iconFontFamily
                font.pixelSize: Style.pillIconSize

                Behavior on color {
                    ColorAnimation {
                        duration: Tokens.duration140
                        easing.type: Easing.InOutQuad
                    }
                }
            }

            Item {
                id: audioTextWrapper

                readonly property bool shown: root.showVolumeText()
                property real textWidth: shown ? audioText.implicitWidth : 0

                Layout.preferredWidth: textWidth
                Layout.preferredHeight: audioText.implicitHeight
                Layout.alignment: Qt.AlignVCenter
                clip: true
                opacity: shown ? 1 : 0

                Text {
                    id: audioText

                    anchors.verticalCenter: parent.verticalCenter
                    text: Services.Audio.volumeText
                    color: Style.pillText
                    font.family: Style.defaultFontFamily
                    font.pixelSize: Tokens.textSM
                    font.weight: Tokens.fontMedium

                    Behavior on color {
                        ColorAnimation {
                            duration: Tokens.duration140
                            easing.type: Easing.InOutQuad
                        }
                    }
                }

                Behavior on textWidth {
                    NumberAnimation {
                        duration: Tokens.duration260
                        easing.type: Easing.InOutQuad
                    }
                }

                Behavior on opacity {
                    NumberAnimation {
                        duration: Tokens.duration140
                        easing.type: Easing.InOutQuad
                    }
                }
            }
        }
    }
}
