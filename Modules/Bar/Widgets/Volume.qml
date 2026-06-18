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
    readonly property bool volumeChanging: volumeChangeTimer.running
    readonly property bool showingVolumeText: showVolumeText()
    readonly property string volumeIcon: getVolumeIcon()
    property real expansionProgress: showingVolumeText ? 1 : 0

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

    function getVolumeIcon(): string {
        if (Services.Audio.muted) {
            return "volume-mute-line";
        }
        if (Services.Audio.volume <= 0) {
            return "volume-off-vibrate-line";
        }
        if (Services.Audio.volume < 0.65) {
            return "volume-down-line";
        }
        return "volume-up-line";
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

            // Volume icon
            RemixIcon {
                Layout.alignment: Qt.AlignCenter
                Layout.preferredWidth: capsule.iconSize
                Layout.preferredHeight: capsule.iconSize
                name: root.volumeIcon
                color: capsule.textColor
                size: capsule.iconSize
            }

            // Volume text
            Item {
                id: volumeTextWrapper

                readonly property bool shown: root.expansionProgress > 0
                property real textWidth: volumeText.implicitWidth * root.expansionProgress
                property real textHeight: volumeText.implicitHeight * root.expansionProgress

                Layout.alignment: Qt.AlignCenter
                Layout.preferredWidth: textWidth
                Layout.preferredHeight: textHeight

                clip: true
                opacity: root.expansionProgress

                Text {
                    id: volumeText

                    anchors.verticalCenter: parent.verticalCenter
                    text: Math.round(Services.Audio.volume * 100)
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
