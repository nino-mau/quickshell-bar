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

    // ---- Hover popup (calendar) ---------------------------------------------

    property bool popupHovered: false
    readonly property bool shouldShowPopup: hoverHandler.hovered || root.popupHovered

    HoverHandler {
        id: hoverHandler
    }

    onShouldShowPopupChanged: {
        if (shouldShowPopup) {
            popupCloseTimer.stop();
            calendarPopup.open();
        } else {
            popupCloseTimer.restart();
        }
    }

    Timer {
        id: popupCloseTimer
        interval: 150
        onTriggered: {
            if (!root.shouldShowPopup) {
                calendarPopup.close();
            }
        }
    }

    BarPopup {
        id: calendarPopup

        readonly property int pad: 16
        // 7 columns of 30px + padding.
        contentWidth: 7 * 30 + pad * 2
        contentHeight: popupBody.implicitHeight + pad * 2
        anchor.item: root
        grabsFocus: false
        radius: Tokens.radius2XL

        Column {
            id: popupBody

            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: calendarPopup.pad
            spacing: 12

            // Big time + full date.
            Column {
                width: parent.width
                spacing: 2

                Text {
                    text: Qt.formatDateTime(clock.date, "HH:mm")
                    color: Theme.fg
                    font.pixelSize: Tokens.text3XL
                    font.weight: Tokens.fontBold
                    font.letterSpacing: -0.5
                }

                Text {
                    text: Qt.formatDateTime(clock.date, "dddd, dd MMMM yyyy")
                    color: Theme.withAlpha(Theme.fg, 0.6)
                    font.pixelSize: Tokens.textSM
                    font.weight: Tokens.fontMedium
                }
            }

            Rectangle {
                width: parent.width
                height: 1
                color: Theme.withAlpha(Theme.bg4, 0.4)
            }

            // Weekday headers (Monday-first).
            Row {
                width: parent.width

                Repeater {
                    model: ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]

                    Item {
                        required property string modelData
                        width: 30
                        height: 20

                        Text {
                            anchors.centerIn: parent
                            text: parent.modelData
                            color: Theme.withAlpha(Theme.fg, 0.45)
                            font.pixelSize: Tokens.textXS
                            font.weight: Tokens.fontBold
                        }
                    }
                }
            }

            // Day grid (6 weeks).
            Grid {
                width: parent.width
                columns: 7
                rowSpacing: 2

                Repeater {
                    model: root.monthCells

                    Item {
                        required property var modelData
                        width: 30
                        height: 28

                        Rectangle {
                            anchors.centerIn: parent
                            width: 26
                            height: 26
                            radius: Tokens.radiusFull
                            visible: parent.modelData.today
                            color: Theme.blue
                        }

                        Text {
                            anchors.centerIn: parent
                            visible: parent.modelData.day > 0
                            text: parent.modelData.day > 0 ? parent.modelData.day : ""
                            color: parent.modelData.today ? Theme.bg1 : parent.modelData.inMonth ? Theme.fg : Theme.withAlpha(Theme.fg, 0.3)
                            font.pixelSize: Tokens.textSM
                            font.weight: parent.modelData.today ? Tokens.fontBold : Tokens.fontMedium
                        }
                    }
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.NoButton
            onEntered: root.popupHovered = true
            onExited: root.popupHovered = false
        }
    }

    // 42 cells (6 weeks) describing the visible month, Monday-first.
    readonly property string monthKey: Qt.formatDateTime(clock.date, "yyyy-MM-dd")
    property var monthCells: computeMonthCells()

    onMonthKeyChanged: monthCells = computeMonthCells()

    function computeMonthCells(): var {
        const now = clock.date;
        const year = now.getFullYear();
        const month = now.getMonth();
        const today = now.getDate();

        const first = new Date(year, month, 1);
        // Monday-first offset: JS getDay() is 0=Sun..6=Sat.
        const offset = (first.getDay() + 6) % 7;
        const daysInMonth = new Date(year, month + 1, 0).getDate();
        const daysInPrev = new Date(year, month, 0).getDate();

        const cells = [];
        for (let i = 0; i < 42; i++) {
            const dayNum = i - offset + 1;
            if (dayNum < 1) {
                cells.push({
                    day: daysInPrev + dayNum,
                    inMonth: false,
                    today: false
                });
            } else if (dayNum > daysInMonth) {
                cells.push({
                    day: dayNum - daysInMonth,
                    inMonth: false,
                    today: false
                });
            } else {
                cells.push({
                    day: dayNum,
                    inMonth: true,
                    today: dayNum === today
                });
            }
        }
        return cells;
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
