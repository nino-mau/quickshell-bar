import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Commons
import qs.Modules.Bar.Widgets as Widgets

/**
* The content of the bar
*/
Rectangle {
    id: root

    required property ShellScreen screen

    color: Style.barBackground

    RowLayout {
        id: leftSection
        anchors.left: parent.left
        anchors.leftMargin: Style.marginM
        anchors.verticalCenter: parent.verticalCenter
        spacing: Style.marginS

        Widgets.Text {
            text: "nino-bar"
            Layout.alignment: Qt.AlignVCenter
        }

        Widgets.Workspaces {
            screen: root.screen
        }
    }
}
