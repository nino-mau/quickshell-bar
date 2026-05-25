import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Commons
import qs.Modules.Bar

/**
* The window containing the bar on one screen
*/
PanelWindow {
    id: root

    color: "transparent"

    readonly property bool isBottom: BarConfig.position === "bottom"

    WlrLayershell.namespace: "nino-bar-" + (screen ? screen.name : "unknown")
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    WlrLayershell.exclusionMode: BarConfig.exclusive ? ExclusionMode.Auto : ExclusionMode.Ignore

    anchors {
        top: !root.isBottom
        bottom: root.isBottom
        left: true
        right: true
    }

    implicitHeight: Style.barHeight

    Bar {
        anchors.fill: parent
        screen: root.screen
    }
}
