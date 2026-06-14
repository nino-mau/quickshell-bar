pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import qs.Commons

Item {
    id: root

    property color baseColor
    property bool vertical: true
    readonly property int traySpacing: 8
    readonly property int crossSize: vertical ? width : height
    readonly property int iconSize: Math.max(1, Math.round((crossSize > 0 ? crossSize : 30) * 0.60))
    readonly property int horizontalIconSize: Math.max(1, Math.round((crossSize > 0 ? crossSize : 30) * 0.7))

    Layout.fillWidth: root.vertical
    Layout.fillHeight: !root.vertical
    Layout.preferredHeight: trayItems.count > 0 ? layout.implicitHeight : 0
    Layout.preferredWidth: trayItems.count > 0 ? layout.implicitWidth : 0
    implicitWidth: layout.implicitWidth
    implicitHeight: layout.implicitHeight
    visible: trayItems.count > 0
    Accessible.name: qsTr("System tray")

    function openMenu(item, anchor): void {
        const window = QsWindow.window as QsWindow;
        if (!window)
            return;

        const position = window.contentItem.mapFromItem(anchor, 0, anchor.height);
        item.display(window, position.x, position.y);
    }

    function activateItem(item, anchor, button: int): void {
        if (button === Qt.LeftButton && !item.onlyMenu) {
            item.activate();
            return;
        }

        if (item.hasMenu) {
            root.openMenu(item, anchor);
            return;
        }

        item.secondaryActivate();
    }

    function getTrayItems(): var {
        return SystemTray.items.values.filter(trayItem => trayItem.title !== "blueman");
    }

    GridLayout {
        id: layout

        anchors.centerIn: parent
        columns: root.vertical ? 1 : 99
        rowSpacing: root.traySpacing
        columnSpacing: root.traySpacing

        Repeater {
            id: trayItems

            model: root.getTrayItems()

            delegate: MouseArea {
                id: trayButton

                required property SystemTrayItem modelData

                Layout.alignment: Qt.AlignCenter
                Layout.preferredWidth: root.vertical ? root.iconSize : root.horizontalIconSize
                Layout.preferredHeight: root.vertical ? root.iconSize : root.horizontalIconSize
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                Accessible.name: trayButton.modelData.title || trayButton.modelData.id || qsTr("Tray item")

                onClicked: event => root.activateItem(trayButton.modelData, trayButton, event.button)

                IconImage {
                    anchors.fill: parent
                    source: trayButton.modelData.icon
                    asynchronous: true
                    opacity: trayButton.containsMouse ? 1 : 0.85

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 140
                            easing.type: Easing.InOutQuad
                        }
                    }
                }
            }
        }
    }
}
