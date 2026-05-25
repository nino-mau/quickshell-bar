pragma Singleton

import QtQuick
import Quickshell

/**
* Shared design tokens for the bar: sizing, spacing, animation, and colors.
*/
Singleton {
    readonly property int barHeight: 50
    readonly property int capsuleHeight: 35

    readonly property int marginXS: 4
    readonly property int marginS: 10
    readonly property int marginM: 9
    readonly property int marginL: 12

    readonly property int radiusM: 1000
    readonly property int radiusL: 1000

    readonly property int fontSizeS: 12
    readonly property int fontSizeM: 13
    readonly property int fontSizeL: 15

    readonly property int animationFast: 140
    readonly property int animationNormal: 260

    readonly property color barBackground: "#00000001"
    readonly property color capsuleBackground: "#20242c"
    readonly property color capsuleHover: "#2b313b"
    readonly property color border: "#343b47"
    readonly property color text: "#d8dee9"
    readonly property color mutedText: "#8f98a8"
    readonly property color accent: "#8aadf4"
    readonly property color activeText: "#0f1117"
}
