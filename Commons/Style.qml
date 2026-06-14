pragma Singleton

import QtQuick
import Quickshell
import qs.Commons as Commons

/**
* Component-level defaults for the bar.
*/
Singleton {
    readonly property int defaultRadius: radiusXL
    readonly property int defaultCapsuleSpacing: 3

    readonly property int capsuleVerticalPadding: 7
    readonly property real capsuleIconSizeRatio: 0.50
    readonly property real capsuleIconPaddingRatio: (1 - capsuleIconSizeRatio) / 2
    readonly property real capsuleTextSizeRatio: 0.35
    readonly property real capsuleTextPaddingRatio: (1 - capsuleTextSizeRatio) / 2

    readonly property int radiusXS: 2
    readonly property int radiusSM: 4
    readonly property int radiusMD: 6
    readonly property int radiusLG: 8
    readonly property int radiusXL: 12
    readonly property int radius2XL: 16
    readonly property int radius2XLHalf: 17
    readonly property int radius3XL: 24
    readonly property int radius4XL: 32
    readonly property int radiusFull: 1000

    readonly property int textXXS: 10
    readonly property int textXS: 12
    readonly property int textXSHalf: 13
    readonly property int textSM: 14
    readonly property int textSMHalf: 15
    readonly property int textBase: 16
    readonly property int textLG: 18
    readonly property int textLGHalf: 19
    readonly property int textXL: 20
    readonly property int textXLHalf: 22
    readonly property int text2XL: 24
    readonly property int text2XLHalf: 22
    readonly property int text3XL: 30
    readonly property int text4XL: 36
    readonly property int text5XL: 48
    readonly property int text6XL: 60
    readonly property int text7XL: 72
    readonly property int text8XL: 96
    readonly property int text9XL: 128

    readonly property int fontThin: Font.Thin
    readonly property int fontExtraLight: Font.ExtraLight
    readonly property int fontLight: Font.Light
    readonly property int fontNormal: Font.Normal
    readonly property int fontMedium: Font.Medium
    readonly property int fontDemiBold: Font.DemiBold
    readonly property int fontBold: Font.Bold
    readonly property int fontExtraBold: Font.ExtraBold
    readonly property int fontBlack: Font.Black

    // Fonts
    readonly property var fontFamilies: Qt.fontFamilies()
    readonly property string defaultFontFamily: resolveDefaultFontFamily()

    // Bar geometry (used to position notification toasts relative to the bar)
    readonly property int barHeight: 44
    readonly property int barMarginTop: 16
    readonly property int barMarginX: 16

    // Notification toast tokens
    readonly property int notificationToastRadius: Commons.Tokens.radius3XL
    readonly property int notificationToastContentPadding: Commons.Tokens.space4
    readonly property int notificationToastHorizontalGap: Commons.Tokens.space3
    readonly property int notificationToastVerticalGap: Commons.Tokens.space2
    readonly property int notificationToastHeaderGap: Commons.Tokens.space2
    readonly property int notificationToastVisualSize: Commons.Tokens.space12
    readonly property int notificationToastIconSize: Commons.Tokens.space8
    readonly property int notificationToastImageSourceSize: Commons.Tokens.space24
    readonly property int notificationToastVisualRadius: Commons.Tokens.radiusLG
    readonly property color notificationToastVisualBackground: "transparent"
    readonly property real notificationToastBackgroundOpacity: 0.6
    readonly property int notificationToastBorderWidth: Commons.Tokens.border1
    readonly property color notificationToastBorder: Commons.Theme.border
    readonly property color notificationToastBackground: Commons.Theme.bg0
    readonly property color notificationToastColor: Commons.Theme.withAlpha(notificationToastBackground, notificationToastBackgroundOpacity)
    readonly property int notificationToastCloseButtonSize: Commons.Tokens.space5
    readonly property int notificationToastCloseTextSize: Commons.Tokens.textLG
    readonly property color notificationToastCloseColor: Commons.Theme.grey2
    readonly property color notificationToastCloseHoverColor: Commons.Theme.red
    readonly property color notificationToastAppColor: Commons.Theme.grey2
    readonly property int notificationToastAppTextSize: Commons.Tokens.textXS
    readonly property int notificationToastAppFontWeight: Commons.Tokens.fontMedium
    readonly property color notificationToastSummaryColor: Commons.Theme.fg
    readonly property int notificationToastSummaryTextSize: Commons.Tokens.textSM
    readonly property int notificationToastSummaryFontWeight: Commons.Tokens.fontBold
    readonly property color notificationToastBodyColor: Commons.Theme.fg
    readonly property real notificationToastBodyOpacity: 0.78
    readonly property int notificationToastBodyTextSize: Commons.Tokens.textXS
    readonly property int notificationToastBodyMaxLines: 3

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
