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
    readonly property bool hasDeviceName: Services.Bluetooth.connected && Services.Bluetooth.activeDeviceName.length > 0
    // Horizontal bars reveal the name inline; vertical bars are too narrow, so
    // they show it in a hover tooltip beside the widget instead.
    readonly property bool showingDeviceName: !root.vertical && (root.hovered || root.down) && hasDeviceName
    readonly property bool showingNameTooltip: root.vertical && root.hovered && hasDeviceName
    property real expansionProgress: showingDeviceName ? 1 : 0

    onShowingNameTooltipChanged: showingNameTooltip ? nameTooltip.open() : nameTooltip.close()

    Layout.fillWidth: root.vertical
    Layout.fillHeight: !root.vertical
    Layout.preferredHeight: Math.max(width > 0 ? width : capsule.implicitHeight, implicitHeight)
    Layout.preferredWidth: Math.max(height > 0 ? height : capsule.implicitHeight, implicitWidth)
    topPadding: root.vertical ? capsule.contentPadding : 0
    bottomPadding: root.vertical ? capsule.contentPadding : 0
    leftPadding: root.vertical ? 0 : capsule.contentPadding
    rightPadding: root.vertical ? 0 : capsule.contentPadding
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
        vertical: root.vertical
        baseColor: root.baseColor
        hovered: root.hovered || root.down
    }

    // Connected device name shown beside the widget on a vertical bar.
    BarPopup {
        id: nameTooltip

        readonly property int pad: 8

        anchor.item: root
        grabsFocus: false
        contentWidth: tooltipText.implicitWidth + pad * 2
        contentHeight: tooltipText.implicitHeight + pad * 2

        Text {
            id: tooltipText

            anchors.centerIn: parent
            text: Services.Bluetooth.activeDeviceName
            color: Theme.fg
            font.pixelSize: Tokens.textSM
            font.weight: Tokens.fontMedium
        }
    }

    contentItem: Item {
        id: content

        implicitWidth: layout.implicitWidth
        implicitHeight: layout.implicitHeight

        GridLayout {
            id: layout

            property real textSpacing: capsule.contentSpacing * root.expansionProgress

            anchors.centerIn: parent
            columns: root.vertical ? 1 : 2
            rowSpacing: textSpacing
            columnSpacing: textSpacing

            // Bluetooth icon
            LucideIcon {
                Layout.alignment: Qt.AlignCenter
                Layout.preferredWidth: capsule.iconSize
                Layout.preferredHeight: capsule.iconSize
                name: root.bluetoothIcon
                color: capsule.textColor
                size: capsule.iconSize
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
                    font.weight: Tokens.fontMedium
                }
            }
        }
    }
}
