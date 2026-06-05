pragma ComponentBehavior: Bound

import QtQuick
import qs.Commons

Rectangle {
    id: root

    property bool hovered: false
    property int colorAnimationDuration: Tokens.duration140
    property color baseColor: Style.pillDefaultBase
    property color backgroundColor: getPillBackgroundColor()
    property color hoverBackgroundColor: getPillHoverBackgroundColor()
    property color textColor: getPillTextColor()

    function getPillBackgroundColor(): color {
        if (root.baseColor === Style.pillDefaultBase) {
            return Style.pillDefaultBackground;
        } else {
            return Theme.withAlpha(root.baseColor, 0.10);
        }
    }

    function getPillHoverBackgroundColor(): color {
        if (root.baseColor === Style.pillDefaultBase) {
            return Style.pillDefaultHoverBackground;
        } else {
            return Theme.withAlpha(root.baseColor, 0.2);
        }
    }

    function getPillTextColor(): color {
        if (root.baseColor === Style.pillDefaultBase) {
            return Style.pillDefaultText;
        } else {
            return root.baseColor;
        }
    }

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
