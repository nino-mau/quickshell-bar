pragma Singleton

import Quickshell

Singleton {
    property string theme: "catppuccin"

    // Bar orientation: "vertical" or "horizontal".
    property string position: "horizontal"

    readonly property bool vertical: position === "vertical"

    // Screen edge the bar is anchored to. Defaults to "left" for a vertical bar
    // and "top" for a horizontal one; override to "right"/"bottom" if wanted.
    property string edge: vertical ? "left" : "top"
}
