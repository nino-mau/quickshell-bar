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
        top: Style.barMarginTop
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
            anchors.leftMargin: Style.barContentMarginX
            anchors.verticalCenter: parent.verticalCenter
            spacing: Style.barGap

            Widgets.Launcher {
                Layout.alignment: Qt.AlignVCenter
            }
            Widgets.MediaPlayer {
                Layout.alignment: Qt.AlignVCenter
            }
            Widgets.Weather {
                Layout.alignment: Qt.AlignVCenter
            }
        }

        RowLayout {
            id: centerSection
            anchors.centerIn: parent
            height: parent.height
            spacing: Tokens.space7

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
            spacing: Style.barGap

            Widgets.Tray {
                Layout.alignment: Qt.AlignVCenter
            }

            Widgets.Network {
                Layout.alignment: Qt.AlignVCenter
            }

            Widgets.Audio {
                Layout.alignment: Qt.AlignVCenter
            }
        }
    }
}
