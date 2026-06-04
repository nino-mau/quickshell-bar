pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import QtQuick.Layouts
import qs.Commons
import qs.Services as Services

MouseArea {
    id: root

    readonly property int maxNetworkNameWidth: 140
    readonly property string icon: {
        if (!Services.Network.connected) {
            return Icons.wifiStrengthOff;
        }
        if (Services.Network.signalStrength < 0.25) {
            return Icons.wifiStrength1;
        }
        if (Services.Network.signalStrength < 0.5) {
            return Icons.wifiStrength2;
        }
        if (Services.Network.signalStrength < 0.75) {
            return Icons.wifiStrength3;
        }
        return Icons.wifiStrength4;
    }

    implicitWidth: pill.implicitWidth
    implicitHeight: Style.barHeight
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    visible: Services.Network.wifiAvailable

    function showNetworkText(): bool {
        return Services.Network.networkName.length > 0;
    }

    onClicked: {
        Quickshell.execDetached(["vicinae", "vicinae://launch/@dagimg-dot/store.vicinae.wifi-commander/scan-wifi"]);
    }

    Pill {
        id: pill

        anchors.centerIn: parent
        implicitWidth: layout.implicitWidth + 19
        hovered: root.containsMouse

        RowLayout {
            id: layout
            property real textSpacing: root.showNetworkText() ? Style.pillGap : 0

            anchors.centerIn: parent
            spacing: textSpacing

            Behavior on textSpacing {
                NumberAnimation {
                    duration: Tokens.duration260
                    easing.type: Easing.InOutQuad
                }
            }

            // Network icon
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

            // Network text
            Item {
                id: networkTextWrapper

                readonly property bool shown: root.showNetworkText()
                property real textWidth: shown ? Math.min(networkText.implicitWidth, root.maxNetworkNameWidth) : 0

                Layout.preferredWidth: textWidth
                Layout.preferredHeight: networkText.implicitHeight
                Layout.alignment: Qt.AlignVCenter
                clip: true
                opacity: shown ? 1 : 0

                Text {
                    id: networkText

                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width
                    text: Services.Network.networkName
                    elide: Text.ElideRight
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
