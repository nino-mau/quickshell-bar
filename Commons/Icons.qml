pragma Singleton

import QtQuick
import Quickshell
import qs.Commons as Commons

Singleton {
    id: root

    // FA

    // readonly property string volumeHigh: ""
    // readonly property string volumeLow: ""
    // readonly property string volumeOff: ""
    // readonly property string volumeMuted: ""

    // Material

    readonly property string os: "󰣇"

    readonly property string volumeHigh: "󰕾"
    readonly property string volumeMedium: "󰖀"
    readonly property string volumeLow: "󰖀"
    readonly property string volumeOff: "󰖁"
    readonly property string volumeMuted: "󰝟"

    readonly property string wifiStrength4: "󰤨"
    readonly property string wifiStrength3: "󰤥"
    readonly property string wifiStrength2: "󰤢"
    readonly property string wifiStrength1: "󰤟"
    readonly property string wifiStrengthOff: "󰤭"

    readonly property string mediaPause: "󰏤"
    readonly property string mediaNextFilled: "󰒭"
    readonly property string mediaPrevFilled: "󰒮"
    readonly property string mediaNext: "󰼧"
    readonly property string mediaPrev: "󰼨"
    readonly property string mediaPlay: "󰐊"

    // Weather

    readonly property string weatherAlert: ""
    readonly property string weatherSunny: ""
    readonly property string weatherNight: ""
    readonly property string weatherPartlyCloudy: ""
    readonly property string weatherCloudy: ""
    readonly property string weatherFog: ""
    readonly property string weatherRainy: ""
    readonly property string weatherPouring: ""
    readonly property string weatherSnowy: ""
    readonly property string weatherLightning: ""
    readonly property string weatherHail: ""
}
