pragma Singleton

import QtQuick
import Quickshell

/**
* Component-level defaults for the bar.
*/
Singleton {
    readonly property int defaultRadius: radiusXL
    readonly property int defaultCapsuleSpacing: 3

    readonly property int capsuleVerticalPadding: 7
    readonly property real capsuleIconSizeRatio: 0.55
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
}
