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
}
