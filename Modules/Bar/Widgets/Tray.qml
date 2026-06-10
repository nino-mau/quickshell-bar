pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import qs.Commons

Control {
    id: root

    property color baseColor
    readonly property int traySpacing: 8

    Layout.fillWidth: true
    Layout.preferredHeight: trayItems.count > 0 ? Math.max(capsule.implicitHeight, implicitHeight) : 0
    topPadding: Style.capsuleVerticalPadding
    bottomPadding: Style.capsuleVerticalPadding
    hoverEnabled: true
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

    background: Capsule {
        id: capsule

        baseColor: root.baseColor
        hovered: root.hovered
    }

    contentItem: Item {
        id: content

        readonly property real capsuleIconSizeRatio: 0.40
        readonly property real capsuleIconPaddingRatio: (1 - capsuleIconSizeRatio) / 2
        readonly property int capsuleBaseSize: width > 0 ? width : capsule.implicitHeight
        readonly property int iconPadding: Math.round(capsuleBaseSize * capsuleIconPaddingRatio)
        readonly property int iconSize: Math.max(0, capsuleBaseSize - iconPadding * 2)

        implicitWidth: layout.implicitWidth
        implicitHeight: layout.implicitHeight

        ColumnLayout {
            id: layout

            anchors.centerIn: parent
            spacing: root.traySpacing

            Repeater {
                id: trayItems

                model: root.getTrayItems()

                delegate: MouseArea {
                    id: trayButton

                    required property SystemTrayItem modelData

                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: content.iconSize
                    Layout.preferredHeight: content.iconSize
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    Accessible.name: trayButton.modelData.title || trayButton.modelData.id || qsTr("Tray item")

                    onClicked: event => root.activateItem(trayButton.modelData, trayButton, event.button)

                    IconImage {
                        anchors.centerIn: parent
                        width: content.iconSize
                        height: content.iconSize
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
}
