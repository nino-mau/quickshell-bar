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
    readonly property bool showingSignalStrengthText: showSignalStrengthText()
    readonly property string networkIcon: getNetworkIcon()
    property real expansionProgress: showingSignalStrengthText ? 1 : 0

    Layout.fillWidth: true
    Layout.preferredHeight: Math.max(width > 0 ? width : capsule.implicitHeight, implicitHeight)
    topPadding: Style.capsuleVerticalPadding * expansionProgress
    bottomPadding: Style.capsuleVerticalPadding * expansionProgress
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
            return Icons.get("wifi-low");
        }
        if (Services.Network.signalStrength < 0.75) {
            return Icons.get("wifi-high");
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
        readonly property int capsuleBaseSize: width > 0 ? width : capsule.implicitHeight
        readonly property int iconPadding: Math.round(capsuleBaseSize * Style.capsuleIconPaddingRatio)
        readonly property int iconSize: Math.max(0, capsuleBaseSize - iconPadding * 2)
        readonly property int textPadding: Math.round(capsuleBaseSize * Style.capsuleTextPaddingRatio)
        readonly property int textSize: Math.max(1, capsuleBaseSize - textPadding * 2)

        implicitWidth: layout.implicitWidth
        implicitHeight: layout.implicitHeight

        ColumnLayout {
            id: layout

            property real textSpacing: Style.defaultCapsuleSpacing * root.expansionProgress

            anchors.centerIn: parent
            spacing: textSpacing

            // Network icon
            LucideIcon {
                Layout.alignment: Qt.AlignHCenter
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

                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: textWidth
                Layout.preferredHeight: textHeight

                clip: true
                opacity: root.expansionProgress

                Text {
                    id: signalStrengthText

                    anchors.verticalCenter: parent.verticalCenter
                    text: Math.round(Services.Network.signalStrength * 100) + '%'
                    color: capsule.textColor
                    font.pixelSize: Style.textXS
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
