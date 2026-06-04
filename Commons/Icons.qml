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

    readonly property string memory: "󰍛"
    readonly property string cpuTemp: "󰈸"
    readonly property string cpuPerc: "󰊚"

    readonly property string bluetoothOn: "󰂯"
    readonly property string bluetoothAudio: "󰂰"
    readonly property string bluetoothOff: "󰂲"
    readonly property string bluetoothSettings: "󰂳"
    readonly property string bluetoothConnect: "󰂱"
    readonly property string bluetoothTransfer: "󰂴"

    // readonly property string bluetooth: "\u{f00af}"
    // readonly property string bluetoothAudio: "\u{f00b0}"
    // readonly property string bluetoothConnected: "\u{f00b1}"
    // readonly property string bluetoothOff: "\u{f00b2}"
    // readonly property string bluetoothSettings: "\u{f00b3}"
    // readonly property string bluetoothTransfer: "\u{f00b4}"

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
