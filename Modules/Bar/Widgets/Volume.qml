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
    readonly property bool volumeChanging: volumeChangeTimer.running
    readonly property bool showingVolumeText: showVolumeText()
    readonly property string volumeIcon: getVolumeIcon()
    property real expansionProgress: showingVolumeText ? 1 : 0

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

    function showVolumeText(): bool {
        if (root.hovered) {
            return true;
        }
        if (volumeChanging) {
            return true;
        }
        if (Services.Audio.muted) {
            return false;
        }
        return false;
    }

    function getVolumeIcon() {
        if (Services.Audio.muted) {
            return "volume-x";
        }
        if (Services.Audio.volume <= 0) {
            return "volume-off";
        }
        if (Services.Audio.volume < 0.3) {
            return "volume";
        }
        if (Services.Audio.volume >= 0.3 && Services.Audio.volume < 0.65) {
            return "volume-1";
        }
        return "volume-2";
    }

    Connections {
        target: Services.Audio

        function onVolumeChanged(): void {
            volumeChangeTimer.restart();
        }
    }

    Timer {
        id: volumeChangeTimer

        interval: 700
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

        // readonly property real capsuleIconSizeRatio: 0.70
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

            // Volume icon
            LucideIcon {
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: content.iconSize
                Layout.preferredHeight: content.iconSize
                name: root.volumeIcon
                color: capsule.textColor
                size: content.iconSize
            }

            // Volume text
            Item {
                id: volumeTextWrapper

                readonly property bool shown: root.expansionProgress > 0
                property real textWidth: volumeText.implicitWidth * root.expansionProgress
                property real textHeight: volumeText.implicitHeight * root.expansionProgress

                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: textWidth
                Layout.preferredHeight: textHeight

                clip: true
                opacity: root.expansionProgress

                Text {
                    id: volumeText

                    anchors.verticalCenter: parent.verticalCenter
                    text: Math.round(Services.Audio.volume * 100)
                    color: capsule.textColor
                    font.pixelSize: Style.textXSHalf
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
