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
    readonly property bool showingPercentageText: showPercentageText()
    readonly property string batteryIcon: getBatteryIcon()
    // Low/charging states recolor the capsule so the battery reads at a glance,
    // otherwise it falls back to the base color handed down by the bar layout.
    readonly property color effectiveBaseColor: getBatteryColor()
    property real expansionProgress: showingPercentageText ? 1 : 0

    visible: Services.Battery.available
    Layout.fillWidth: root.vertical
    Layout.fillHeight: !root.vertical
    Layout.preferredHeight: Math.max(width > 0 ? width : capsule.implicitHeight, implicitHeight)
    Layout.preferredWidth: Math.max(height > 0 ? height : capsule.implicitHeight, implicitWidth)
    topPadding: root.vertical ? capsule.contentPadding * expansionProgress : 0
    bottomPadding: root.vertical ? capsule.contentPadding * expansionProgress : 0
    leftPadding: root.vertical ? 0 : capsule.contentPadding * expansionProgress
    rightPadding: root.vertical ? 0 : capsule.contentPadding * expansionProgress
    hoverEnabled: true
    Accessible.name: qsTr("Battery")

    Behavior on expansionProgress {
        NumberAnimation {
            duration: 220
            easing.type: Easing.InOutQuad
        }
    }

    onClicked: launch(Qt.LeftButton)

    function launch(button: int): void {
        Quickshell.execDetached(["vicinae", "vicinae://launch/@Gelei/store.vicinae.power-management/power-management"]);
    }

    function showPercentageText(): bool {
        if (root.hovered) {
            return true;
        }
        if (Services.Battery.charging) {
            return true;
        }
        return Services.Battery.low;
    }

    function getBatteryIcon(): string {
        if (Services.Battery.charging) {
            return "battery-charge-fill";
        }
        if (Services.Battery.low) {
            return "battery-low-fill";
        }
        return "battery-fill";
    }

    function getBatteryColor(): color {
        if (Services.Battery.low) {
            return Theme.red;
        }
        if (Services.Battery.charging) {
            return Theme.green;
        }
        return root.baseColor;
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
        baseColor: root.effectiveBaseColor
        hovered: root.hovered || root.down
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

            // Battery icon
            RemixIcon {
                Layout.alignment: Qt.AlignCenter
                Layout.preferredWidth: capsule.iconSize
                Layout.preferredHeight: capsule.iconSize
                name: root.batteryIcon
                color: capsule.textColor
                size: capsule.iconSize
            }

            // Battery percentage text
            Item {
                readonly property bool shown: root.expansionProgress > 0
                property real textWidth: percentageText.implicitWidth * root.expansionProgress
                property real textHeight: percentageText.implicitHeight * root.expansionProgress

                Layout.alignment: Qt.AlignCenter
                Layout.preferredWidth: textWidth
                Layout.preferredHeight: textHeight

                clip: true
                opacity: root.expansionProgress

                Text {
                    id: percentageText

                    anchors.verticalCenter: parent.verticalCenter
                    text: Services.Battery.displayPercentage
                    color: capsule.textColor
                    font.pixelSize: root.vertical ? Tokens.textXSHalf : capsule.horizontalTextSize
                    font.weight: Tokens.fontMedium

                    Behavior on color {
                        ColorAnimation {
                            duration: 140
                            easing.type: Easing.InOutQuad
                        }
                    }
                }
            }
        }
    }
}
