import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Commons
import qs.Modules.Bar.Widgets as Widgets

Item {
    id: root

    property var screen
    property int gap: 10

    // Top section widgets
    ColumnLayout {
        id: topSection
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }
        spacing: root.gap

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
        spacing: 20

        Widgets.Workspaces {
            screen: root.screen
        }
        Widgets.Clock {
            square: true
            baseColor: Theme.bg2
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
        spacing: root.gap

        Widgets.Tray {
            baseColor: Theme.bg2
        }
        Widgets.Updates {
            baseColor: Theme.bg2
        }
        Widgets.Bluetooth {
            baseColor: Theme.bg2
        }
        Widgets.Network {
            baseColor: Theme.bg2
        }
        Widgets.Battery {
            baseColor: Theme.bg2
        }
        Widgets.Volume {
            baseColor: Theme.bg2
        }
    }
}
