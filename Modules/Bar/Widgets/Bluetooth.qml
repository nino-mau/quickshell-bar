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
    readonly property string bluetoothIcon: getBluetoothIcon()

    Layout.fillWidth: true
    Layout.preferredHeight: Math.max(width > 0 ? width : capsule.implicitHeight, implicitHeight)
    topPadding: Style.capsuleVerticalPadding
    bottomPadding: Style.capsuleVerticalPadding
    hoverEnabled: true
    Accessible.name: qsTr("Volume")

    onClicked: launch(Qt.LeftButton)

    function launch(button: int): void {
        const entry = DesktopEntries.heuristicLookup("wiremix");
        if (entry) {
            Quickshell.execDetached(["ghostty", "-e", "wiremix"]);
            return;
        }

        if (button === Qt.LeftButton) {
            Services.Audio.toggleMuted();
            return;
        }

        Services.Audio.cycleNextSink();
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

        readonly property int capsuleBaseSize: width > 0 ? width : capsule.implicitHeight
        readonly property int iconPadding: Math.round(capsuleBaseSize * Style.capsuleIconPaddingRatio)
        readonly property int iconSize: Math.max(0, capsuleBaseSize - iconPadding * 2)
        readonly property int textPadding: Math.round(capsuleBaseSize * Style.capsuleTextPaddingRatio)
        readonly property int textSize: Math.max(1, capsuleBaseSize - textPadding * 2)

        implicitWidth: layout.implicitWidth
        implicitHeight: layout.implicitHeight

        ColumnLayout {
            id: layout

            property real textSpacing: Style.defaultCapsuleSpacing

            anchors.centerIn: parent
            spacing: textSpacing

            // Bluetooth icon
            LucideIcon {
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: content.iconSize
                Layout.preferredHeight: content.iconSize
                name: root.bluetoothIcon
                color: capsule.textColor
                size: content.iconSize
            }
        }
    }
}
