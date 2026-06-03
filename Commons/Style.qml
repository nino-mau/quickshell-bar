pragma Singleton

import QtQuick
import Quickshell
import qs.Commons as Commons

/**
* Component-level defaults for the bar.
*/
Singleton {
    id: root

    readonly property string defaultFontFamily: "Maple Mono NF CN"
    readonly property string iconFontFamily: "Symbols Nerd Font"

    readonly property int barHeight: 50
    readonly property int barPaddingX: 10
    readonly property int barMarginTop: Commons.Tokens.space5
    readonly property int barMarginX: Commons.Tokens.space5
    readonly property int barContentMarginX: Commons.Tokens.space2 + Commons.Tokens.spacePx
    readonly property int barRadius: Commons.Tokens.radiusFull
    readonly property int barGap: 9
    readonly property color barBackground: Commons.Theme.withAlpha(Commons.Theme.surface, 0.8)

    readonly property int pillHeight: 31
    readonly property int pillIconSize: Commons.Tokens.textLG
    readonly property int pillRadius: Commons.Tokens.radiusFull
    readonly property color pillText: Commons.Theme.text
    readonly property color pillBackground: Commons.Theme.surfaceRaised
    readonly property color pillHoverBackground: Commons.Theme.surfaceHover

    readonly property int popupRadius: Commons.Tokens.radiusXL
    readonly property int popupBorderWidth: Commons.Tokens.border1
}
