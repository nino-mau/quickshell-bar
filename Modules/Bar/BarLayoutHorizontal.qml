import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Commons
import qs.Modules.Bar.Widgets as Widgets

Item {
    id: root

    property var screen
    property int gap: 10

    // Left section widgets
    RowLayout {
        id: leftSection
        anchors {
            left: parent.left
            top: parent.top
            bottom: parent.bottom
        }
        spacing: root.gap

        Widgets.Launcher {
            vertical: false
            square: true
            baseColor: Theme.bg2
        }
        Widgets.MediaPlayer {
            vertical: false
            baseColor: Theme.bg2
        }
        Widgets.Weather {
            vertical: false
            baseColor: Theme.bg2
        }
        Widgets.SystemMonitor {
            vertical: false
            baseColor: Theme.bg2
        }
    }

    // Center section widgets
    RowLayout {
        id: centerSection
        anchors {
            horizontalCenter: parent.horizontalCenter
            top: parent.top
            bottom: parent.bottom
        }
        spacing: 20

        Widgets.Clock {
            vertical: false
            baseColor: Theme.bg2
        }
        Widgets.Workspaces {
            vertical: false
            screen: root.screen
        }
    }

    // Right section widgets
    RowLayout {
        id: rightSection
        anchors {
            right: parent.right
            top: parent.top
            bottom: parent.bottom
        }
        spacing: root.gap

        Widgets.Tray {
            vertical: false
            baseColor: Theme.bg2
        }
        Widgets.Updates {
            vertical: false
            baseColor: Theme.bg2
        }
        Widgets.Bluetooth {
            vertical: false
            baseColor: Theme.bg2
        }
        Widgets.Network {
            vertical: false
            baseColor: Theme.bg2
        }
        Widgets.Volume {
            vertical: false
            baseColor: Theme.bg2
        }
    }
}
