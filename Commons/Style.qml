pragma Singleton

import QtQuick
import Quickshell

/**
* Shared design tokens for the bar: sizing, spacing, animation, and colors.
*/
Singleton {
    readonly property int barHeight: 50
    readonly property int barMarginT: Tokens.space5
    readonly property int barMarginX: Tokens.space5
    readonly property int barRadius: Tokens.radius2XL

    readonly property int capsuleHeight: 35

    readonly property int marginXS: Tokens.space1
    readonly property int marginS: Tokens.space2_5
    readonly property int marginM: Tokens.space2 + Tokens.spacePx
    readonly property int marginL: Tokens.space3

    readonly property int radiusXS: Tokens.radiusXS
    readonly property int radiusSM: Tokens.radiusSM
    readonly property int radiusMD: Tokens.radiusMD
    readonly property int radiusLG: Tokens.radiusLG
    readonly property int radiusXL: Tokens.radiusXL
    readonly property int radius2XL: Tokens.radius2XL
    readonly property int radius3XL: Tokens.radius3XL
    readonly property int radius4XL: Tokens.radius4XL
    readonly property int radiusFull: Tokens.radiusFull
    readonly property int borderWidth: Tokens.border1

    readonly property int fontSizeS: Tokens.textXS
    readonly property int fontSizeM: 13
    readonly property int fontSizeL: 15

    readonly property int animationFast: 140
    readonly property int animationNormal: 260

    readonly property color barBackground: Qt.rgba(0.024, 0.024, 0.037, Tokens.opacity60)
    readonly property color capsuleBackground: "#20242c"
    readonly property color capsuleHover: "#2b313b"
    readonly property color border: "#343b47"
    readonly property color text: "#d8dee9"
    readonly property color mutedText: "#8f98a8"
    readonly property color accent: "#8aadf4"
    readonly property color activeText: "#0f1117"
}
