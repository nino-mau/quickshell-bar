pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects
import Quickshell.Widgets
import qs.Commons

Item {
    id: root

    property alias source: image.source
    property color color: Theme.fg
    property color sourceColor: "black"
    property int size: 20
    property bool colorize: true
    property bool asynchronous: true
    property alias status: image.status

    readonly property real iconSize: Math.min(width > 0 ? width : size, height > 0 ? height : size)

    implicitWidth: size
    implicitHeight: size
    Accessible.ignored: true

    IconImage {
        id: image

        anchors.centerIn: parent
        width: root.iconSize
        height: root.iconSize
        asynchronous: root.asynchronous
        mipmap: true

        layer.enabled: root.colorize && root.source.toString() !== ""
        layer.effect: MultiEffect {
            colorization: 1
            colorizationColor: root.color
            brightness: 1 - root.sourceColor.hslLightness
        }
    }
}
