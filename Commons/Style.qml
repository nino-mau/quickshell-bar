pragma Singleton

import QtQuick
import Quickshell
import qs.Commons as Commons

/**
* Shared design tokens for the bar: sizing, spacing, animation, and colors.
*/
Singleton {
    id: root

    readonly property string defaultFontFamily: "Maple Mono NF CN"
    readonly property string iconFontFamily: "Symbols Nerd Font"

    readonly property int barHeight: 50
    readonly property int barPaddingX: 10
    readonly property int barMarginT: Commons.Tokens.space5
    readonly property int barMarginX: Commons.Tokens.space5
    readonly property int barRadius: Commons.Tokens.radiusLG
    readonly property int barGap: 9
    readonly property color barBackground: Commons.Theme.withAlpha(Commons.Theme.bg1, 0.80)

    readonly property int pillSize: 31
    readonly property int pillIconSize: Commons.Tokens.textLG
    readonly property int pillRadius: Commons.Tokens.radiusLG
    readonly property color pillText: Commons.Theme.fg
    readonly property color pillBackground: Commons.Theme.bg2
    readonly property color pillHoverBackground: Commons.Theme.withAlpha(Commons.Theme.bg2, 0.7)

    readonly property int marginXS: Commons.Tokens.space1
    readonly property int marginS: Commons.Tokens.space2_5
    readonly property int marginM: Commons.Tokens.space2 + Commons.Tokens.spacePx
    readonly property int marginL: Commons.Tokens.space3

    readonly property int gapDefault: Commons.Tokens.space4

    readonly property int radiusFull: Commons.Tokens.radiusFull
    readonly property int borderWidth: Commons.Tokens.border1
    readonly property int radiusDefault: Commons.Tokens.radiusXL

    readonly property int animationFast: 140
    readonly property int animationNormal: 260
    readonly property int animationSlow: 400
    readonly property int animationVerySlow: 600

    readonly property color border: "#343b47"
    readonly property color textDefault: Commons.Theme.fg
    readonly property color textMuted: Commons.Theme.grey0
    readonly property color accent: "#8aadf4"
    readonly property color activeText: "#0f1117"
}
