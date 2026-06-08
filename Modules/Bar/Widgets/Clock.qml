pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Commons

Item {
    id: root

    property color baseColor
    property bool square: false
    property color textColor: Theme.fg

    Layout.fillWidth: true
    Layout.preferredHeight: root.square ? (root.width > 0 ? root.width : layout.implicitHeight) : layout.implicitHeight
    implicitWidth: layout.implicitWidth
    implicitHeight: layout.implicitHeight
    Accessible.name: qsTr("Clock")

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }

    ColumnLayout {
        id: layout

        anchors.centerIn: parent
        spacing: root.square ? -2 : 1

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: root.square ? Qt.formatDateTime(clock.date, "HH") : Qt.formatDateTime(clock.date, "HH:mm")
            color: root.textColor
            font.pixelSize: root.square ? Math.max(14, Math.round(root.width * 0.55)) : Style.textXS
            font.weight: Style.fontBold
            font.letterSpacing: root.square ? -0.8 : 0
        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 2
            Layout.bottomMargin: 2
            visible: root.square
            spacing: 3

            Rectangle {
                Layout.preferredWidth: 3
                Layout.preferredHeight: 3
                radius: width / 2
                color: root.textColor
                opacity: 0.85
            }

            Rectangle {
                Layout.preferredWidth: 3
                Layout.preferredHeight: 3
                radius: width / 2
                color: root.textColor
                opacity: clock.date.getSeconds() % 2 === 0 ? 0.85 : 0.25

                Behavior on opacity {
                    NumberAnimation {
                        duration: 450
                        easing.type: Easing.InOutQuad
                    }
                }
            }
        }

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: root.square ? Qt.formatDateTime(clock.date, "mm") : Qt.formatDateTime(clock.date, "ddd dd")
            color: Theme.withAlpha(root.textColor, root.square ? 0.78 : 0.7)
            font.pixelSize: root.square ? Math.max(13, Math.round(root.width * 0.50)) : Style.textXXS
            font.weight: Style.fontMedium
            font.letterSpacing: root.square ? -0.8 : 0
        }
    }
}
