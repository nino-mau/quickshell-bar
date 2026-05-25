import Quickshell.Hyprland
import QtQuick.Layouts
import Quickshell
import QtQuick
import qs.Commons

Item {
    id: root

    required property ShellScreen screen
    property int count: 10

    readonly property int activeWorkspaceId: {
        var monitor = Hyprland.monitorFor(screen);
        if (monitor && monitor.activeWorkspace)
            return monitor.activeWorkspace.id;
        return Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id : -1;
    }

    implicitWidth: 200
    implicitHeight: Style.barHeight

    function workspaceExists(workspaceId) {
        var list = Hyprland.workspaces.values;
        for (var i = 0; i < list.length; i++) {
            if (list[i].id === workspaceId)
                return true;
        }
        return false;
    }

    RowLayout {
        id: layout
        anchors.centerIn: parent
        spacing: Style.marginXS

        Repeater {
            model: root.count

            delegate: MouseArea {
                id: workspaceButton

                required property int index

                readonly property int workspaceId: index + 1
                readonly property bool active: root.activeWorkspaceId === workspaceId
                readonly property bool occupied: root.workspaceExists(workspaceId)

                implicitWidth: active ? 42 : 20
                implicitHeight: 20
                Layout.preferredWidth: implicitWidth
                Layout.preferredHeight: implicitHeight
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                onClicked: Hyprland.dispatch("workspace " + workspaceId)

                Rectangle {
                    anchors.fill: parent
                    radius: height / 2
                    color: workspaceButton.active ? "white" : (workspaceButton.containsMouse ? "#333333" : "transparent")
                    border.color: workspaceButton.occupied ? "white" : "#666666"
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: workspaceButton.workspaceId
                        color: workspaceButton.active ? "black" : "white"
                    }
                }
            }
        }
    }
}
