pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Commons

Item {
    id: root

    property color baseColor
    property bool square: false
    property bool vertical: true
    property color textColor: Theme.fg

    Layout.fillWidth: root.vertical
    Layout.alignment: root.vertical ? Qt.AlignHCenter : Qt.AlignVCenter
    Layout.preferredHeight: root.square ? (root.width > 0 ? root.width : layout.implicitHeight) : layout.implicitHeight
    Layout.preferredWidth: layout.implicitWidth
    implicitWidth: layout.implicitWidth
    implicitHeight: layout.implicitHeight
    Accessible.name: qsTr("Clock")

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }

    GridLayout {
        id: layout

        // In horizontal mode, mirror the row so the date comes before the time.
        LayoutMirroring.enabled: !root.vertical
        LayoutMirroring.childrenInherit: false

        anchors.centerIn: parent
        columns: root.vertical ? 1 : 2
        rowSpacing: root.square ? -2 : 1
        columnSpacing: 7

        Text {
            Layout.alignment: root.vertical ? Qt.AlignHCenter : Qt.AlignVCenter
            text: root.square ? Qt.formatDateTime(clock.date, "HH") : Qt.formatDateTime(clock.date, "HH:mm")
            color: root.textColor
            font.pixelSize: root.square ? Math.max(14, Math.round(root.width * 0.55)) : Tokens.textBase
            font.weight: Tokens.fontBold
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
            Layout.alignment: root.vertical ? Qt.AlignHCenter : Qt.AlignVCenter
            text: root.square ? Qt.formatDateTime(clock.date, "mm") : Qt.formatDateTime(clock.date, "dd MMM")
            color: Theme.withAlpha(root.textColor, root.square ? 0.78 : 0.7)
            font.pixelSize: root.square ? Math.max(13, Math.round(root.width * 0.50)) : Tokens.textSM
            font.weight: Tokens.fontMedium
            font.letterSpacing: root.square ? -0.8 : 0
        }
    }
}
