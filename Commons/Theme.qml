pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons as Commons

Singleton {
    id: root

    property var themes: ({})

    readonly property string themeName: Commons.Config.theme
    readonly property var selectedTheme: themes[themeName] || themes.catppuccin || ({})

    readonly property color bg0: themeColor("bg0", "#181825")
    readonly property color bg1: themeColor("bg1", "#1e1e2e")
    readonly property color bg2: themeColor("bg2", "#313244")
    readonly property color bg3: themeColor("bg3", "#45475a")
    readonly property color bg4: themeColor("bg4", "#585b70")
    readonly property color fg: themeColor("fg", "#cdd6f4")
    readonly property color fg2: themeColor("fg2", "#bac2de")
    readonly property color red: themeColor("red", "#f38ba8")
    readonly property color orange: themeColor("orange", "#fab387")
    readonly property color yellow: themeColor("yellow", "#f9e2af")
    readonly property color green: themeColor("green", "#a6e3a1")
    readonly property color aqua: themeColor("aqua", "#94e2d5")
    readonly property color blue: themeColor("blue", "#89b4fa")
    readonly property color purple: themeColor("purple", "#cba6f7")
    readonly property color pink: themeColor("pink", "#f5c2e7")
    readonly property color lavender: themeColor("lavender", "#b4befe")
    readonly property color grey0: themeColor("grey0", "#6c7086")
    readonly property color grey1: themeColor("grey1", "#7f849c")
    readonly property color grey2: themeColor("grey2", "#9399b2")
    readonly property color border: themeColor("border", "#313244")

    FileView {
        id: themesFile

        path: Quickshell.shellDir + "/themes.json"
        watchChanges: true
        printErrors: false

        onLoaded: root.loadThemes()
        onFileChanged: reload()
        onLoadFailed: root.themes = ({})
    }

    function loadThemes(): void {
        try {
            const parsed = JSON.parse(themesFile.text());
            root.themes = parsed && typeof parsed === "object" ? parsed : ({});
        } catch (error) {
            console.warn("Failed to parse themes.json", error);
            root.themes = ({});
        }
    }

    function themeColor(key: string, fallback: string): string {
        const value = root.selectedTheme[key];
        return typeof value === "string" && value.length > 0 ? value : fallback;
    }

    function withAlpha(base: color, alpha: real): color {
        const clampedAlpha = Math.max(0, Math.min(1, alpha));
        return Qt.rgba(base.r, base.g, base.b, clampedAlpha);
    }
}
