pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Services as Services

MouseArea {
    id: root

    readonly property string icon: Icons.os

    implicitWidth: pill.implicitWidth
    implicitHeight: Style.barHeight
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor

    Rectangle {
        id: pill
        anchors.centerIn: parent
        implicitWidth: Style.pillSize
        implicitHeight: Style.pillSize
        radius: Style.pillRadius
        color: root.containsMouse ? Theme.withAlpha(Theme.primary, 0.25) : Theme.withAlpha(Theme.primary, 0.15)

        Text {
            text: root.icon
            anchors.centerIn: parent
            // Correct nerd font icons not being centered properly
            anchors.horizontalCenterOffset: -1.2
            anchors.verticalCenterOffset: -0.5
            color: Theme.primary
            font.family: Style.iconFontFamily
            font.pixelSize: Style.pillIconSize
        }

        Behavior on color {
            ColorAnimation {
                duration: Style.animationFast
                easing.type: Easing.InOutQuad
            }
        }
    }
}
