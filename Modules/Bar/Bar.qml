import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.Commons
import qs.Modules.Bar.Widgets as Widgets

PanelWindow {
    id: root

    color: "transparent"

    // Style

    readonly property int barWidth: 50
    readonly property int barRadius: Style.defaultRadius
    readonly property int barMargin: 16
    readonly property int barPadding: 8
    readonly property int barGap: 10
    readonly property real barBackgroundOpacity: 0.8
    readonly property color barBackgroundColor: Theme.withAlpha(Theme.bg1, barBackgroundOpacity)

    WlrLayershell.namespace: "quickshell-bar-vert-" + (screen ? screen.name : "unknown")
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    WlrLayershell.exclusionMode: ExclusionMode.Auto

    anchors {
        top: true
        bottom: true
        left: true
        right: false
    }

    margins {
        top: barMargin
        right: 0
        left: barMargin
        bottom: barMargin
    }

    implicitWidth: barWidth

    Control {
        anchors.fill: parent
        padding: root.barPadding
        clip: true

        background: Rectangle {
            radius: root.barRadius
            color: root.barBackgroundColor
        }

        contentItem: Item {
            // Top section widgets
            ColumnLayout {
                id: topSection
                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                }
                spacing: root.barGap

                Widgets.Launcher {
                    baseColor: Theme.bg2
                    square: true
                }
                Widgets.Weather {
                    baseColor: Theme.bg2
                }
                Widgets.SystemMonitor {
                    baseColor: Theme.bg2
                }
                Widgets.MediaPlayer {
                    square: true
                    baseColor: Theme.bg2
                }
            }

            // Middle section widgets
            ColumnLayout {
                id: middleSection
                anchors {
                    verticalCenter: parent.verticalCenter
                    left: parent.left
                    right: parent.right
                }
                spacing: root.barGap

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 10
                    color: "red"
                    border.color: "black"
                    border.width: 5
                    radius: 10
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 10
                    color: "red"
                    border.color: "black"
                    border.width: 5
                    radius: 10
                }
            }

            // Bottom section widgets
            ColumnLayout {
                id: bottomSection
                anchors {
                    bottom: parent.bottom
                    left: parent.left
                    right: parent.right
                }
                spacing: root.barGap

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 10
                    color: "red"
                    border.color: "black"
                    border.width: 5
                    radius: 10
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 10
                    color: "red"
                    border.color: "black"
                    border.width: 5
                    radius: 10
                }
            }
        }
    }
}
