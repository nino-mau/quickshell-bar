pragma Singleton

import QtQuick
import Quickshell
import qs.Commons as Commons

/**
* Component-level defaults for the bar.
*/
Singleton {
    id: root

    readonly property var fontFamilies: Qt.fontFamilies()
    readonly property string defaultFontFamily: resolveDefaultFontFamily()
    readonly property string iconFontFamily: firstAvailableFont(["Symbols Nerd Font", "Symbols Nerd Font Mono", "Symbols Nerd Font Propo"], firstNerdFontFamily())

    readonly property int barHeight: 50
    readonly property int barPaddingX: 10
    readonly property int barMarginTop: Commons.Tokens.space5
    readonly property int barMarginX: Commons.Tokens.space5
    readonly property int barContentMarginX: Commons.Tokens.space2 + Commons.Tokens.spacePx
    readonly property int barRadius: Commons.Tokens.radiusFull
    readonly property int barGap: 9
    readonly property real barColorOpacity: 0.85
    readonly property color barBackground: Commons.Theme.surface

    readonly property int pillHeight: 31
    readonly property int pillIconSize: Commons.Tokens.textLG
    readonly property int pillRadius: Commons.Tokens.radiusFull
    readonly property int pillTextSize: Commons.Tokens.textSM
    readonly property int pillGap: Commons.Tokens.space2
    readonly property color pillDefaultBase: Commons.Theme.surfaceRaised
    readonly property color pillDefaultText: Commons.Theme.text
    readonly property color pillDefaultBackground: Commons.Theme.surfaceRaised
    readonly property color pillDefaultHoverBackground: Commons.Theme.surfaceHover

    readonly property int popupRadius: Commons.Tokens.radiusXL
    readonly property int popupBorderWidth: Commons.Tokens.border1

    function getPillBackgroundColor(color: color): color {
        return Commons.Theme.withAlpha(color, 0.5);
    }

    function resolveDefaultFontFamily(): string {
        const mapleFont = firstAvailableFont(["Maple Mono NF CN", "Maple Mono NF"], "");
        if (mapleFont.length > 0) {
            return mapleFont;
        }

        return firstNerdFontFamily();
    }

    function firstAvailableFont(names: var, fallback: string): string {
        for (const name of names) {
            if (fontFamilies.indexOf(name) !== -1) {
                return name;
            }
        }

        return fallback;
    }

    function firstNerdFontFamily(): string {
        for (const family of fontFamilies) {
            if (family.indexOf("Nerd Font") !== -1 && family.indexOf("Mono") !== -1) {
                return family;
            }
        }

        for (const family of fontFamilies) {
            if (family.indexOf("Nerd Font") !== -1) {
                return family;
            }
        }

        return "";
    }
}
