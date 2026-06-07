pragma ComponentBehavior: Bound

import QtQuick
import qs.Commons

Item {
    id: root

    property string name: ""
    property color color: Theme.fg
    property int size: 20
    property real fill: 0
    property int grade: 0
    property int weight: 400
    property string fontFamily: "Material Symbols Rounded"

    readonly property string symbol: Icons.get(name)

    implicitWidth: size
    implicitHeight: size
    Accessible.ignored: true

    property real verticalOffset: 0

    Text {
        id: label

        x: Math.round((root.width - implicitWidth) / 2)
        y: Math.round((root.height - contentHeight) / 2 + root.verticalOffset)
        text: root.symbol
        color: root.color
        font.family: root.fontFamily
        font.pixelSize: root.size
        font.variableAxes: ({
                FILL: root.fill.toFixed(1),
                GRAD: root.grade,
                opsz: root.size,
                wght: root.weight
            })
    }
}
