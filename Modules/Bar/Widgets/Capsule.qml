pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.Commons

Rectangle {
    id: root

    property bool hovered: false
    property bool square: false
    readonly property int capsuleHeight: 30
    readonly property int capsuleRadius: Style.defaultRadius
    readonly property int horizontalTextSize: Style.textXSHalf
    property int colorAnimationDuration: 140
    property color defaultBaseColor: Theme.bg2
    property color defaultBackgroundColor: Theme.bg2
    property color defaultHoverBackgroundColor: Theme.withAlpha(defaultBackgroundColor, 0.7)
    property color defaultTextColor: Theme.fg
    property color baseColor: defaultBaseColor
    property color backgroundColor: getCapsuleBackgroundColor()
    property color hoverBackgroundColor: getCapsuleHoverBackgroundColor()
    property color textColor: getCapsuleTextColor()

    Layout.fillWidth: true
    Layout.preferredHeight: root.square ? (root.width > 0 ? root.width : root.capsuleHeight) : root.capsuleHeight

    implicitWidth: root.capsuleHeight
    implicitHeight: root.capsuleHeight
    radius: capsuleRadius
    color: hovered ? hoverBackgroundColor : backgroundColor

    function getCapsuleBackgroundColor(): color {
        if (root.baseColor === defaultBaseColor) {
            return defaultBackgroundColor;
        } else {
            return Theme.withAlpha(root.baseColor, 0.10);
        }
    }

    function getCapsuleHoverBackgroundColor(): color {
        if (root.baseColor === defaultBaseColor) {
            return defaultHoverBackgroundColor;
        } else {
            return Theme.withAlpha(root.baseColor, 0.2);
        }
    }

    function getCapsuleTextColor(): color {
        if (root.baseColor === defaultBaseColor) {
            return defaultTextColor;
        } else {
            return baseColor;
        }
    }

    Behavior on color {
        ColorAnimation {
            duration: root.colorAnimationDuration
            easing.type: Easing.InOutQuad
        }
    }
}
