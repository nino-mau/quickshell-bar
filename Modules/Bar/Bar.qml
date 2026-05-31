import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.Commons
import qs.Modules.Bar.Widgets as Widgets

/**
* The window and content for the bar on one screen.
*/
PanelWindow {
    id: root

    color: "transparent"

    readonly property bool isBottom: BarConfig.position === "bottom"

    WlrLayershell.namespace: "quickshell-bar-" + (screen ? screen.name : "unknown")
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    WlrLayershell.exclusionMode: BarConfig.exclusive ? ExclusionMode.Auto : ExclusionMode.Ignore

    anchors {
        top: !root.isBottom
        bottom: root.isBottom
        left: true
        right: true
    }

    margins {
        top: Style.barMarginT
        right: Style.barMarginX
        left: Style.barMarginX
    }

    implicitHeight: Style.barHeight

    Rectangle {
        anchors.fill: parent
        radius: Style.barRadius
        color: Style.barBackground
        clip: true

        RowLayout {
            id: leftSection
            anchors.left: parent.left
            anchors.leftMargin: Style.marginM
            anchors.verticalCenter: parent.verticalCenter
            spacing: Style.marginS
        }

        RowLayout {
            id: centerSection
            anchors.centerIn: parent
            spacing: Style.barGap
            height: parent.height

            Widgets.Clock {
                Layout.alignment: Qt.AlignVCenter
            }

            Widgets.Workspaces {
                screen: root.screen
            }
        }

        RowLayout {
            id: rightSection
            anchors.right: parent.right
            anchors.rightMargin: Style.barPaddingX
            anchors.verticalCenter: parent.verticalCenter
            spacing: Style.marginS

            Widgets.Tray {
                Layout.alignment: Qt.AlignVCenter
            }

            Widgets.Audio {
                Layout.alignment: Qt.AlignVCenter
            }
        }
    }
}
