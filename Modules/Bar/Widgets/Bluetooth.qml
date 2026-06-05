pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import QtQuick.Layouts
import qs.Commons
import qs.Services as Services

MouseArea {
    id: root

    readonly property string icon: getBluetoothIcon()
    property color baseColor: Style.pillDefaultBase

    implicitWidth: pill.implicitWidth
    implicitHeight: Style.barHeight
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    visible: Services.Bluetooth.bluetoothAvailable

    onClicked: event => {
        Quickshell.execDetached(["vicinae", "vicinae://launch/@Gelei/store.vicinae.bluetooth/devices"]);
    }

    function getBluetoothIcon(params) {
        if (!Services.Bluetooth.bluetoothAvailable || !Services.Bluetooth.enabled || Services.Bluetooth.blocked) {
            return Icons.bluetoothOff;
        }
        if (Services.Bluetooth.busy || Services.Bluetooth.discovering) {
            return Icons.bluetoothTransfer;
        }
        if (Services.Bluetooth.connected && !Services.Bluetooth.isDeviceAudio()) {
            return Icons.bluetoothConnect;
        } else if (Services.Bluetooth.isDeviceAudio()) {
            return Icons.bluetoothAudio;
        }
        return Icons.bluetoothOn;
    }

    Pill {
        id: pill

        anchors.centerIn: parent
        implicitWidth: layout.implicitWidth + 19
        hovered: root.containsMouse
        baseColor: root.baseColor

        RowLayout {
            id: layout
            property real textSpacing: pill.hovered ? Style.pillGap : 0

            anchors.centerIn: parent
            spacing: textSpacing

            Behavior on textSpacing {
                NumberAnimation {
                    duration: Tokens.duration260
                    easing.type: Easing.InOutQuad
                }
            }

            // Bluetooth icon
            Text {
                text: root.icon
                color: pill.textColor
                Layout.rightMargin: root.icon === Icons.bluetoothOn ? Style.bluetoothDefaultIconRightMargin : 0
                font.family: Style.iconFontFamily
                font.pixelSize: Style.pillIconSize

                Behavior on color {
                    ColorAnimation {
                        duration: Tokens.duration140
                        easing.type: Easing.InOutQuad
                    }
                }
            }

            // Device name
            Item {
                id: deviceNameWrapper

                readonly property bool shown: pill.hovered
                property real textWidth: shown ? deviceName.implicitWidth : 0

                Layout.preferredWidth: textWidth
                Layout.preferredHeight: deviceName.implicitHeight
                Layout.alignment: Qt.AlignVCenter
                clip: true
                opacity: shown ? 1 : 0

                Text {
                    id: deviceName

                    anchors.verticalCenter: parent.verticalCenter
                    text: Services.Bluetooth.activeDeviceName
                    color: pill.textColor
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
