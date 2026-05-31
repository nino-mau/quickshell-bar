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
}
