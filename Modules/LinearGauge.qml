import QtQuick
import qs.Commons

Rectangle {
    id: root

    required property int orientation // Qt.Vertical || Qt.Horizontal
    required property real ratio // 0..1

    property color trackColor: Theme.bg3
    property color fillColor: Theme.blue

    radius: root.orientation === Qt.Vertical ? width / 2 : height / 2
    color: root.trackColor

    Rectangle {
        readonly property real clampedRatio: Math.min(1, Math.max(0, root.ratio))
        readonly property real rawFill: (root.orientation === Qt.Vertical ? root.height : root.width) * clampedRatio

        anchors.left: parent.left
        anchors.bottom: parent.bottom
        width: root.orientation === Qt.Vertical ? root.width : (rawFill < 1 ? 0 : rawFill)
        height: root.orientation === Qt.Vertical ? (rawFill < 1 ? 0 : rawFill) : root.height
        radius: root.radius
        color: root.fillColor
    }
}
