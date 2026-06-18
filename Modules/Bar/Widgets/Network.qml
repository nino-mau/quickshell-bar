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
    topPadding: root.vertical ? capsule.contentPadding * expansionProgress : 0
    bottomPadding: root.vertical ? capsule.contentPadding * expansionProgress : 0
    leftPadding: root.vertical ? 0 : capsule.contentPadding * expansionProgress
    rightPadding: root.vertical ? 0 : capsule.contentPadding * expansionProgress
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
            return "signal-wifi-off-fill";
        }
        if (Services.Network.signalStrength === 0) {
            return "signal-wifi-1-fill";
        }
        if (Services.Network.signalStrength < 0.25) {
            return "signal-wifi-1-fill";
        }
        if (Services.Network.signalStrength < 0.5) {
            return "signal-wifi-2-fill";
        }
        if (Services.Network.signalStrength < 0.75) {
            return "signal-wifi-3-fill";
        }
        return "signal-wifi-fill";
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

            // Network icon
            RemixIcon {
                Layout.alignment: Qt.AlignCenter
                Layout.preferredWidth: capsule.iconSize
                Layout.preferredHeight: capsule.iconSize
                name: root.networkIcon
                color: capsule.textColor
                size: capsule.iconSize
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
                    font.pixelSize: root.vertical ? Tokens.textXS : capsule.horizontalTextSize
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
