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
    readonly property string bluetoothIcon: getBluetoothIcon()
    readonly property bool showingDeviceName: !root.vertical && (root.hovered || root.down) && Services.Bluetooth.connected && Services.Bluetooth.activeDeviceName.length > 0
    property real expansionProgress: showingDeviceName ? 1 : 0

    Layout.fillWidth: root.vertical
    Layout.fillHeight: !root.vertical
    Layout.preferredHeight: Math.max(width > 0 ? width : capsule.implicitHeight, implicitHeight)
    Layout.preferredWidth: Math.max(height > 0 ? height : capsule.implicitHeight, implicitWidth)
    topPadding: root.vertical ? Style.capsuleVerticalPadding : 0
    bottomPadding: root.vertical ? Style.capsuleVerticalPadding : 0
    leftPadding: root.vertical ? 0 : Style.capsuleVerticalPadding
    rightPadding: root.vertical ? 0 : Style.capsuleVerticalPadding
    hoverEnabled: true
    Accessible.name: qsTr("Bluetooth")

    Behavior on expansionProgress {
        NumberAnimation {
            duration: 220
            easing.type: Easing.InOutQuad
        }
    }

    onClicked: launch(Qt.LeftButton)

    function launch(button: int): void {
        Quickshell.execDetached(["vicinae", "vicinae://launch/@Gelei/store.vicinae.bluetooth/devices"]);
    }

    function getBluetoothIcon(): string {
        if (!Services.Bluetooth.bluetoothAvailable || !Services.Bluetooth.enabled || Services.Bluetooth.blocked) {
            return Icons.get("bluetooth-off");
        }
        if (Services.Bluetooth.busy || Services.Bluetooth.discovering) {
            return Icons.get("bluetooth-searching");
        }
        if (Services.Bluetooth.connected) {
            return Icons.get("bluetooth-connected");
        }
        return Icons.get("bluetooth");
    }

    HoverHandler {
        cursorShape: Qt.PointingHandCursor
    }

    TapHandler {
        acceptedButtons: Qt.RightButton
        onTapped: root.launch(Qt.RightButton)
    }

    background: Capsule {
        id: capsule

        square: true
        baseColor: root.baseColor
        hovered: root.hovered || root.down
    }

    contentItem: Item {
        id: content

        readonly property int crossSize: root.vertical ? width : height
        readonly property int capsuleBaseSize: crossSize > 0 ? crossSize : capsule.implicitHeight
        readonly property int iconPadding: Math.round(capsuleBaseSize * Style.capsuleIconPaddingRatio)
        readonly property int iconSize: Math.max(0, capsuleBaseSize - iconPadding * 2)

        implicitWidth: layout.implicitWidth
        implicitHeight: layout.implicitHeight

        GridLayout {
            id: layout

            property real textSpacing: Style.defaultCapsuleSpacing * root.expansionProgress

            anchors.centerIn: parent
            columns: root.vertical ? 1 : 2
            rowSpacing: textSpacing
            columnSpacing: textSpacing

            // Bluetooth icon
            LucideIcon {
                Layout.alignment: Qt.AlignCenter
                Layout.preferredWidth: content.iconSize
                Layout.preferredHeight: content.iconSize
                name: root.bluetoothIcon
                color: capsule.textColor
                size: content.iconSize
            }

            // Connected device name (horizontal, revealed on hover)
            Item {
                readonly property bool shown: root.expansionProgress > 0
                property real textWidth: deviceNameText.implicitWidth * root.expansionProgress
                property real textHeight: deviceNameText.implicitHeight * root.expansionProgress

                Layout.alignment: Qt.AlignCenter
                Layout.preferredWidth: textWidth
                Layout.preferredHeight: textHeight
                visible: !root.vertical
                clip: true
                opacity: root.expansionProgress

                Text {
                    id: deviceNameText

                    anchors.verticalCenter: parent.verticalCenter
                    text: Services.Bluetooth.activeDeviceName
                    color: capsule.textColor
                    font.pixelSize: capsule.horizontalTextSize
                    font.weight: Style.fontMedium
                }
            }
        }
    }
}
