pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import qs.Commons

MouseArea {
    id: root

    readonly property string icon: Icons.os
    property color baseColor: Style.pillDefaultBase

    implicitWidth: pill.implicitWidth
    implicitHeight: Style.barHeight
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor

    onClicked: {
        Quickshell.execDetached(["vicinae", "toggle"]);
    }

    Pill {
        id: pill

        anchors.centerIn: parent
        implicitWidth: Style.pillHeight
        baseColor: root.baseColor

        Text {
            text: root.icon
            anchors.centerIn: parent
            // Correct nerd font icons not being centered properly
            anchors.horizontalCenterOffset: -1.2
            anchors.verticalCenterOffset: -0.5
            color: pill.textColor
            font.family: Style.iconFontFamily
            font.pixelSize: Style.pillIconSize

            Behavior on color {
                ColorAnimation {
                    duration: Tokens.duration140
                    easing.type: Easing.InOutQuad
                }
            }
        }
    }
}
