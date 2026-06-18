pragma ComponentBehavior: Bound

import QtQuick
import qs.Commons

Item {
    id: root

    property string name: ""
    property color color: Theme.fg
    property int size: 20
    property real verticalOffset: 0

    readonly property string symbol: RemixIcons.get(name)

    implicitWidth: size
    implicitHeight: size
    Accessible.ignored: true

    Text {
        id: label

        x: Math.round((root.width - implicitWidth) / 2)
        y: Math.round((root.height - contentHeight) / 2 + root.verticalOffset)
        text: root.symbol
        color: root.color
        font.family: RemixIcons.fontFamily
        font.pixelSize: root.size
    }
}
