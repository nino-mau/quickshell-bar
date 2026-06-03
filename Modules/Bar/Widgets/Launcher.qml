pragma ComponentBehavior: Bound

import QtQuick
import qs.Commons

MouseArea {
    id: root

    readonly property string icon: Icons.os

    implicitWidth: pill.implicitWidth
    implicitHeight: Style.barHeight
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor

    Pill {
        id: pill

        anchors.centerIn: parent
        implicitWidth: Style.pillHeight
        hoverBackgroundColor: Style.pillBackground

        Text {
            text: root.icon
            anchors.centerIn: parent
            // Correct nerd font icons not being centered properly
            anchors.horizontalCenterOffset: -1.2
            anchors.verticalCenterOffset: -0.5
            color: Style.pillText
            font.family: Style.iconFontFamily
            font.pixelSize: Style.pillIconSize
        }
    }
}
