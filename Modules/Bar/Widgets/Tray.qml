pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import qs.Commons

Item {
    id: root

    // Style

    readonly property int itemSize: 22
    readonly property int iconSize: Tokens.textLGHalf

    implicitWidth: layout.implicitWidth
    implicitHeight: Style.barHeight
    visible: trayItems.count > 0

    function openMenu(item, anchor) {
        const window = QsWindow.window as QsWindow;
        if (!window)
            return;

        const position = window.contentItem.mapFromItem(anchor, 0, anchor.height);
        item.display(window, position.x, position.y);
    }

    RowLayout {
        id: layout
        anchors.centerIn: parent
        spacing: Tokens.space2

        Repeater {
            id: trayItems
            model: SystemTray.items.values

            delegate: MouseArea {
                id: trayButton

                required property SystemTrayItem modelData

                implicitWidth: root.itemSize
                implicitHeight: root.itemSize
                Layout.preferredWidth: trayButton.implicitWidth
                Layout.preferredHeight: trayButton.implicitHeight
                Layout.alignment: Qt.AlignVCenter
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                onClicked: event => {
                    if (event.button === Qt.LeftButton && !trayButton.modelData.onlyMenu) {
                        trayButton.modelData.activate();
                        return;
                    }

                    if (trayButton.modelData.hasMenu) {
                        root.openMenu(trayButton.modelData, trayButton);
                        return;
                    }

                    trayButton.modelData.secondaryActivate();
                }

                IconImage {
                    anchors.centerIn: parent
                    width: root.iconSize
                    height: root.iconSize
                    source: trayButton.modelData.icon
                    asynchronous: true
                    opacity: trayButton.containsMouse ? 1 : 0.85

                    Behavior on opacity {
                        NumberAnimation {
                            duration: Tokens.duration140
                            easing.type: Easing.InOutQuad
                        }
                    }
                }
            }
        }
    }
}
