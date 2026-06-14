pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.Commons

Rectangle {
    id: root

    property bool hovered: false
    property bool square: false
    // Orientation of the bar this capsule lives in: lets it pick the right
    // (cross) axis when deriving icon/text sizes from its own geometry.
    property bool vertical: true

    readonly property int capsuleHeight: 30
    readonly property int capsuleRadius: Style.defaultRadius
    readonly property int horizontalTextSize: Tokens.textXSHalf

    // Content layout config (capsule-specific, shared by every capsule widget).
    readonly property int contentPadding: 7
    readonly property int contentSpacing: 3
    readonly property real iconSizeRatio: 0.50
    readonly property real iconPaddingRatio: (1 - iconSizeRatio) / 2
    readonly property real textSizeRatio: 0.35
    readonly property real textPaddingRatio: (1 - textSizeRatio) / 2

    // Cross-axis size (height on a horizontal bar, width on a vertical one),
    // used to derive icon/text sizes so widgets don't recompute them.
    readonly property int crossSize: {
        const size = vertical ? width : height;
        return size > 0 ? size : implicitHeight;
    }
    readonly property int iconPadding: Math.round(crossSize * iconPaddingRatio)
    readonly property int iconSize: Math.max(0, crossSize - iconPadding * 2)
    readonly property int textPadding: Math.round(crossSize * textPaddingRatio)
    readonly property int textSize: Math.max(1, crossSize - textPadding * 2)
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
