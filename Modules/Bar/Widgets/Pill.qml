pragma ComponentBehavior: Bound

import QtQuick
import qs.Commons

Rectangle {
    id: root

    property bool hovered: false
    property int colorAnimationDuration: Tokens.duration140
    property color backgroundColor: Style.pillBackground
    property color hoverBackgroundColor: Style.pillHoverBackground

    implicitHeight: Style.pillHeight
    radius: Style.pillRadius
    color: hovered ? hoverBackgroundColor : backgroundColor

    Behavior on color {
        ColorAnimation {
            duration: root.colorAnimationDuration
            easing.type: Easing.InOutQuad
        }
    }
}
