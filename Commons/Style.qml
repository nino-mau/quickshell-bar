pragma Singleton

import QtQuick
import Quickshell
import qs.Commons as Commons

/**
* Shared design tokens for the bar: sizing, spacing, animation, and colors.
*/
Singleton {
    readonly property int barHeight: 50
    readonly property int barMarginT: Commons.Tokens.space5
    readonly property int barMarginX: Commons.Tokens.space5
    readonly property int barRadius: Commons.Tokens.radius2XL
    readonly property int barGap: Commons.Tokens.space3

    readonly property int capsuleHeight: 35

    readonly property int marginXS: Commons.Tokens.space1
    readonly property int marginS: Commons.Tokens.space2_5
    readonly property int marginM: Commons.Tokens.space2 + Commons.Tokens.spacePx
    readonly property int marginL: Commons.Tokens.space3

    readonly property int radiusXS: Commons.Tokens.radiusXS
    readonly property int radiusSM: Commons.Tokens.radiusSM
    readonly property int radiusMD: Commons.Tokens.radiusMD
    readonly property int radiusLG: Commons.Tokens.radiusLG
    readonly property int radiusXL: Commons.Tokens.radiusXL
    readonly property int radius2XL: Commons.Tokens.radius2XL
    readonly property int radius3XL: Commons.Tokens.radius3XL
    readonly property int radius4XL: Commons.Tokens.radius4XL
    readonly property int radiusFull: Commons.Tokens.radiusFull
    readonly property int borderWidth: Commons.Tokens.border1
    readonly property int radiusDefault: Commons.Tokens.radiusXL

    readonly property int fontSizeS: Commons.Tokens.textXS
    readonly property int fontSizeM: 13
    readonly property int fontSizeL: 15

    readonly property int animationFast: 140
    readonly property int animationNormal: 260

    readonly property color barBackground: Qt.rgba(0.024, 0.024, 0.037, Commons.Tokens.opacity60)
    readonly property color capsuleBackground: "#20242c"
    readonly property color capsuleHover: "#2b313b"
    readonly property color border: "#343b47"
    readonly property color text: "#d8dee9"
    readonly property color mutedText: "#8f98a8"
    readonly property color accent: "#8aadf4"
    readonly property color activeText: "#0f1117"

    readonly property color workspacePillInactiveBg: Commons.Theme.bg2
    readonly property color workspacePillActiveBg: Commons.Theme.primary
    readonly property int workspacePillActiveWidth: 45
    readonly property int workspacePillInactiveWidth: 30
}
