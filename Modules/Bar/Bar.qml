import QtQuick
import QtQuick.Controls.Basic
import Quickshell
import Quickshell.Wayland
import qs.Commons
import qs.Modules.Bar

PanelWindow {
    id: root

    color: "transparent"

    // Orientation

    readonly property bool vertical: Config.vertical

    // Style

    readonly property int barThickness: vertical ? 50 : 44
    readonly property int barRadius: vertical ? Style.defaultRadius : Style.defaultRadius
    readonly property int barMargin: 16
    readonly property int barPadding: 8
    readonly property int barGap: 10
    readonly property real barBackgroundOpacity: 0.85
    readonly property color barBackgroundColor: Theme.withAlpha(Theme.bg1, barBackgroundOpacity)

    WlrLayershell.namespace: "quickshell-bar-" + (vertical ? "vert-" : "horiz-") + (screen ? screen.name : "unknown")
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    WlrLayershell.exclusionMode: ExclusionMode.Auto

    // Anchor to every edge except the interior one (opposite the bar's screen edge).
    anchors {
        top: Config.edge !== "bottom"
        bottom: Config.edge !== "top"
        left: Config.edge !== "right"
        right: Config.edge !== "left"
    }

    margins {
        top: Config.edge === "bottom" ? 0 : barMargin
        bottom: Config.edge === "top" ? 0 : barMargin
        left: Config.edge === "right" ? 0 : barMargin
        right: Config.edge === "left" ? 0 : barMargin
    }

    implicitWidth: barThickness
    implicitHeight: barThickness

    Control {
        anchors.fill: parent
        padding: root.barPadding
        clip: true

        background: Rectangle {
            radius: root.barRadius
            color: root.barBackgroundColor
        }

        contentItem: Loader {
            sourceComponent: root.vertical ? verticalLayout : horizontalLayout
        }
    }

    Component {
        id: verticalLayout
        BarLayoutVertical {
            screen: root.screen
            gap: root.barGap
        }
    }

    Component {
        id: horizontalLayout
        BarLayoutHorizontal {
            screen: root.screen
            gap: root.barGap
        }
    }
}
