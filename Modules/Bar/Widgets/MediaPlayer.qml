pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import qs.Commons
import qs.Modules.Bar
import qs.Services as Services

AbstractButton {
    id: root

    property color baseColor
    property bool square: false

    readonly property int visualizerBandCount: 3
    readonly property int visualizerClipPadding: 4
    readonly property real visualizerPauseOpacity: 0.7

    Layout.fillWidth: true
    Layout.preferredHeight: root.square ? (root.width > 0 ? root.width : capsule.implicitHeight) : capsule.implicitHeight
    topPadding: 0
    bottomPadding: 0
    hoverEnabled: true
    Accessible.name: Services.Media.displayText.length > 0 ? Services.Media.displayText : qsTr("Media player")

    onClicked: Services.Media.togglePlaying()

    HoverHandler {
        cursorShape: Services.Media.hasPlayer ? Qt.PointingHandCursor : Qt.ArrowCursor
    }

    TapHandler {
        acceptedButtons: Qt.RightButton
        onTapped: Services.Media.next()
    }

    TapHandler {
        acceptedButtons: Qt.MiddleButton
        onTapped: Services.Media.previous()
    }

    background: Capsule {
        id: capsule

        baseColor: root.baseColor
        hovered: root.hovered || root.down
        square: root.square
    }

    contentItem: Item {
        id: content

        readonly property int capsuleBaseSize: width > 0 ? width : capsule.implicitHeight
        readonly property int iconPadding: Math.round(capsuleBaseSize * Style.capsuleIconPaddingRatio)
        readonly property int iconSize: Math.max(0, capsuleBaseSize - iconPadding * 2)

        implicitWidth: capsule.implicitHeight
        implicitHeight: capsule.implicitHeight

        Item {
            id: visualizerClipBounds

            anchors.fill: parent
            anchors.margins: root.visualizerClipPadding
            clip: true

            AudioVisualizer {
                id: visualizer

                anchors.fill: parent
                visible: Services.Media.hasPlayer
                active: Services.Media.isPlaying
                type: "mirrored"
                spectrumBandCount: root.visualizerBandCount
                minimumLevel: Services.Media.isPlaying ? 0.06 : 0.10
                maximumLevel: 0.62
                levelScale: 0.9
                barWidthRatio: 0.68
                colorOpacity: Services.Media.isPlaying ? 0.9 : root.visualizerPauseOpacity
                barColor: capsule.textColor
            }

            LucideIcon {
                anchors.centerIn: parent
                name: "pause"
                opacity: Services.Media.isPlaying ? 0 : 1
                color: capsule.textColor
                size: content.iconSize
            }
        }
    }
}
