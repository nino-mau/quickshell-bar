pragma ComponentBehavior: Bound

import QtQuick
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
    acceptedButtons: Qt.NoButton
    hoverEnabled: true
    visible: Services.Network.wifiAvailable

    function showNetworkText(): bool {
        return Services.Network.networkName.length > 0;
    }

    Rectangle {
        id: pill

        anchors.centerIn: parent
        implicitWidth: layout.implicitWidth + 19
        implicitHeight: Style.pillSize
        radius: Style.pillRadius
        color: root.containsMouse ? Style.pillHoverBackground : Style.pillBackground

        RowLayout {
            id: layout
            property real textSpacing: root.showNetworkText() ? Tokens.space2 : 0

            anchors.centerIn: parent
            spacing: textSpacing

            Behavior on textSpacing {
                NumberAnimation {
                    duration: Style.animationNormal
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
                        duration: Style.animationFast
                        easing.type: Easing.InOutQuad
                    }
                }
            }

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
                            duration: Style.animationFast
                            easing.type: Easing.InOutQuad
                        }
                    }
                }

                Behavior on textWidth {
                    NumberAnimation {
                        duration: Style.animationNormal
                        easing.type: Easing.InOutQuad
                    }
                }

                Behavior on opacity {
                    NumberAnimation {
                        duration: Style.animationFast
                        easing.type: Easing.InOutQuad
                    }
                }
            }
        }

        Behavior on color {
            ColorAnimation {
                duration: Style.animationFast
                easing.type: Easing.InOutQuad
            }
        }
    }
}
