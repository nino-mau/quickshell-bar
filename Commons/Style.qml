pragma Singleton

import QtQuick
import Quickshell
import qs.Commons as Commons

/**
* General, app-wide style defaults.
*
* Keep this file small: only values that are genuinely shared across the whole
* shell belong here. Primitive scales (spacing, radius, text, font weights,
* durations…) live in Tokens, colors live in Theme, and component-specific
* config lives with the component itself (see Capsule, NotificationPopups…).
*/
Singleton {
    // Default corner radius used by generic surfaces (capsule, popups, bar).
    readonly property int defaultRadius: Commons.Tokens.radiusLG

    // Bar geometry, shared so popups/toasts can position relative to the bar.
    readonly property int barHeight: 44
    readonly property int barMarginTop: 16
    readonly property int barMarginX: 16

    // Resolved default font family for all text in the shell.
    readonly property var fontFamilies: Qt.fontFamilies()
    readonly property string defaultFontFamily: resolveDefaultFontFamily()

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
