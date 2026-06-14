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
    readonly property bool showingSignalStrengthText: showSignalStrengthText()
    readonly property string networkIcon: getNetworkIcon()
    readonly property string infoText: (!root.vertical && Services.Network.connected && Services.Network.networkName.length > 0) ? Services.Network.networkName : Math.round(Services.Network.signalStrength * 100) + '%'
    property real expansionProgress: showingSignalStrengthText ? 1 : 0

    Layout.fillWidth: root.vertical
    Layout.fillHeight: !root.vertical
    Layout.preferredHeight: Math.max(width > 0 ? width : capsule.implicitHeight, implicitHeight)
    Layout.preferredWidth: Math.max(height > 0 ? height : capsule.implicitHeight, implicitWidth)
    topPadding: root.vertical ? Style.capsuleVerticalPadding * expansionProgress : 0
    bottomPadding: root.vertical ? Style.capsuleVerticalPadding * expansionProgress : 0
    leftPadding: root.vertical ? 0 : Style.capsuleVerticalPadding * expansionProgress
    rightPadding: root.vertical ? 0 : Style.capsuleVerticalPadding * expansionProgress
    hoverEnabled: true
    Accessible.name: qsTr("Volume")

    Behavior on expansionProgress {
        NumberAnimation {
            duration: 220
            easing.type: Easing.InOutQuad
        }
    }

    onClicked: launch(Qt.LeftButton)

    function launch(button: int): void {
        Quickshell.execDetached(["vicinae", "vicinae://launch/@dagimg-dot/store.vicinae.wifi-commander/scan-wifi"]);
    }

    function showSignalStrengthText(): bool {
        return root.hovered;
    }

    function getNetworkIcon(): string {
        if (!Services.Network.connected) {
            return Icons.get("wifi-off");
        }
        if (Services.Network.signalStrength === 0) {
            return Icons.get("wifi-zero");
        }
        if (Services.Network.signalStrength < 0.25) {
            return Icons.get("wifi-low");
        }
        if (Services.Network.signalStrength < 0.5) {
            return Icons.get("wifi-high");
        }
        if (Services.Network.signalStrength < 0.75) {
            return Icons.get("wifi");
        }
        return Icons.get("wifi");
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

        // readonly property real capsuleIconSizeRatio: 0.55
        // readonly property real capsuleIconPaddingRatio: (1 - capsuleIconSizeRatio) / 2
        readonly property int crossSize: root.vertical ? width : height
        readonly property int capsuleBaseSize: crossSize > 0 ? crossSize : capsule.implicitHeight
        readonly property int iconPadding: Math.round(capsuleBaseSize * Style.capsuleIconPaddingRatio)
        readonly property int iconSize: Math.max(0, capsuleBaseSize - iconPadding * 2)
        readonly property int textPadding: Math.round(capsuleBaseSize * Style.capsuleTextPaddingRatio)
        readonly property int textSize: Math.max(1, capsuleBaseSize - textPadding * 2)

        implicitWidth: layout.implicitWidth
        implicitHeight: layout.implicitHeight

        GridLayout {
            id: layout

            property real textSpacing: Style.defaultCapsuleSpacing * root.expansionProgress

            anchors.centerIn: parent
            columns: root.vertical ? 1 : 2
            rowSpacing: textSpacing
            columnSpacing: textSpacing

            // Network icon
            LucideIcon {
                Layout.alignment: Qt.AlignCenter
                Layout.preferredWidth: content.iconSize
                Layout.preferredHeight: content.iconSize
                name: root.networkIcon
                color: capsule.textColor
                size: content.iconSize
            }

            // Network strength text
            Item {
                readonly property bool shown: root.expansionProgress > 0
                property real textWidth: signalStrengthText.implicitWidth * root.expansionProgress
                property real textHeight: signalStrengthText.implicitHeight * root.expansionProgress

                Layout.alignment: Qt.AlignCenter
                Layout.preferredWidth: textWidth
                Layout.preferredHeight: textHeight

                clip: true
                opacity: root.expansionProgress

                Text {
                    id: signalStrengthText

                    anchors.verticalCenter: parent.verticalCenter
                    text: root.infoText
                    color: capsule.textColor
                    font.pixelSize: root.vertical ? Style.textXS : capsule.horizontalTextSize
                    font.weight: Style.fontMedium

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
