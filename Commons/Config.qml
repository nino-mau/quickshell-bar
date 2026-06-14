pragma Singleton

import Quickshell

Singleton {
    property string theme: "catppuccin"

    // Bar position on the screen: "left", "right", "top" or "bottom".
    // "left"/"right" render a vertical bar, "top"/"bottom" a horizontal one.
    property string position: "top"

    readonly property bool vertical: position === "left" || position === "right"
}
