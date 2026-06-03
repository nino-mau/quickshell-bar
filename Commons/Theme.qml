pragma Singleton

import QtQuick
import Quickshell

Singleton {
    readonly property color bg0: "#181825"
    readonly property color bg1: "#1e1e2e"
    readonly property color bg2: "#313244"
    readonly property color bg3: "#45475a"
    readonly property color bg4: "#585b70"
    readonly property color fg: "#cdd6f4"
    readonly property color fg2: "#bac2de"
    readonly property color red: "#f38ba8"
    readonly property color orange: "#fab387"
    readonly property color yellow: "#f9e2af"
    readonly property color green: "#a6e3a1"
    readonly property color aqua: "#94e2d5"
    readonly property color blue: "#89b4fa"
    readonly property color purple: "#cba6f7"
    readonly property color pink: "#f5c2e7"
    readonly property color lavender: "#b4befe"
    readonly property color grey0: "#6c7086"
    readonly property color grey1: "#7f849c"
    readonly property color grey2: "#9399b2"

    readonly property color surface: bg1
    readonly property color surfaceRaised: bg2
    readonly property color surfaceHighlight: bg3
    readonly property color surfaceHover: withAlpha(surfaceRaised, 0.7)
    readonly property color text: fg
    readonly property color textMuted: grey0
    readonly property color accent: blue
    readonly property color accentText: bg0
    readonly property color borderSubtle: "#343b47"

    function withAlpha(base: color, alpha: real): color {
        const clampedAlpha = Math.max(0, Math.min(1, alpha));
        return Qt.rgba(base.r, base.g, base.b, clampedAlpha);
    }
}
