pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import qs.Commons

Item {
    id: root

    required property ShellScreen screen

    property bool vertical: true
    property int workspaceCount: 5

    property var workspaceIcons: ["terminal.svg", "firefox.svg", "terminal.svg", "shapes.svg", "layout.svg"]
    property int workspaceWidth: 22
    property int workspaceInactiveHeight: 22
    property int workspaceActiveHeight: 35
    property int workspaceGap: 5
    property int workspaceRadius: Style.radiusFull
    property int workspaceIconSize: 15
    property real activeIconOpacity: 1
    property real inactiveIconOpacity: 0
    property int pulseSize: 14
    property int pulseBorderWidth: 2
    property real pulseOpacity: 0.5
    property int sizeAnimationDuration: 260
    property int colorAnimationDuration: 160
    property color activeColor: Theme.blue
    property color inactiveColor: Theme.bg2
    property color occupiedColor: Theme.bg3
    property color activeTextColor: Theme.bg1
    property color inactiveTextColor: Theme.fg

    readonly property int activeWorkspaceId: {
        const monitor = Hyprland.monitorFor(root.screen);
        if (monitor && monitor.activeWorkspace) {
            return monitor.activeWorkspace.id;
        }

        return Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id : -1;
    }

    Layout.fillWidth: false
    Layout.fillHeight: !vertical
    Layout.preferredWidth: vertical ? workspaceWidth : implicitWidth
    Layout.preferredHeight: vertical ? implicitHeight : workspaceWidth
    Layout.alignment: vertical ? Qt.AlignHCenter : Qt.AlignVCenter
    implicitWidth: layout.implicitWidth
    implicitHeight: layout.implicitHeight

    function workspaceForId(workspaceId: int): var {
        const workspaces = Hyprland.workspaces.values;
        for (let i = 0; i < workspaces.length; i++) {
            if (workspaces[i].id === workspaceId) {
                return workspaces[i];
            }
        }

        return null;
    }

    function workspaceExists(workspaceId: int): bool {
        return workspaceForId(workspaceId) !== null;
    }

    function workspaceMonitorName(workspaceId: int): string {
        const workspace = workspaceForId(workspaceId);
        return workspace && workspace.monitor ? workspace.monitor.name : "";
    }

    function currentMonitorName(): string {
        const monitor = Hyprland.monitorFor(root.screen);
        return monitor ? monitor.name : "";
    }

    function workspaceOnOtherMonitor(workspaceId: int): bool {
        const workspaceMonitor = workspaceMonitorName(workspaceId);
        const currentMonitor = currentMonitorName();
        return workspaceMonitor.length > 0 && currentMonitor.length > 0 && workspaceMonitor !== currentMonitor;
    }

    function workspaceIconSource(workspaceId: int): url {
        const iconFile = workspaceIcons[workspaceId - 1] || workspaceIcons[0];
        return Qt.resolvedUrl(Quickshell.shellDir + "/Assets/Icons/" + iconFile);
    }

    GridLayout {
        id: layout

        anchors {
            horizontalCenter: parent.horizontalCenter
            verticalCenter: parent.verticalCenter
        }
        columns: root.vertical ? 1 : 99
        rowSpacing: root.workspaceGap
        columnSpacing: root.workspaceGap

        Repeater {
            model: root.workspaceCount

            MouseArea {
                id: workspaceButton

                required property int index

                readonly property int workspaceId: index + 1
                readonly property bool active: root.activeWorkspaceId === workspaceId
                readonly property bool occupied: root.workspaceExists(workspaceId)
                readonly property bool onOtherMonitor: root.workspaceOnOtherMonitor(workspaceId)
                readonly property color buttonColor: active ? root.activeColor : occupied && !onOtherMonitor ? root.occupiedColor : root.inactiveColor
                property real pulse: 0

                readonly property int workspaceLength: active ? root.workspaceActiveHeight : root.workspaceInactiveHeight

                Layout.preferredWidth: root.vertical ? root.workspaceWidth : workspaceLength
                Layout.preferredHeight: root.vertical ? workspaceLength : root.workspaceWidth
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                Accessible.role: Accessible.Button
                Accessible.name: qsTr("Workspace %1").arg(workspaceId)

                onClicked: Hyprland.dispatch("workspace " + workspaceId)
                onActiveChanged: {
                    if (active) {
                        activationPulse.restart();
                    }
                }

                Behavior on Layout.preferredWidth {
                    NumberAnimation {
                        duration: root.sizeAnimationDuration
                        easing.type: Easing.OutCubic
                    }
                }

                Behavior on Layout.preferredHeight {
                    NumberAnimation {
                        duration: root.sizeAnimationDuration
                        easing.type: Easing.OutCubic
                    }
                }

                Rectangle {
                    anchors.fill: parent
                    radius: root.workspaceRadius
                    color: workspaceButton.buttonColor

                    Behavior on color {
                        ColorAnimation {
                            duration: root.colorAnimationDuration
                            easing.type: Easing.InOutQuad
                        }
                    }

                    Rectangle {
                        anchors.centerIn: parent
                        width: parent.width + workspaceButton.pulse * root.pulseSize
                        height: parent.height + workspaceButton.pulse * root.pulseSize
                        radius: width / 2
                        color: "transparent"
                        border.color: root.activeColor
                        border.width: Math.max(1, Math.round(root.pulseBorderWidth * (1 - workspaceButton.pulse)))
                        opacity: (1 - workspaceButton.pulse) * root.pulseOpacity
                        visible: workspaceButton.pulse > 0
                    }

                    SvgIcon {
                        anchors.centerIn: parent
                        source: root.workspaceIconSource(workspaceButton.workspaceId)
                        color: workspaceButton.active ? root.activeTextColor : root.inactiveTextColor
                        sourceColor: "black"
                        opacity: workspaceButton.active ? root.activeIconOpacity : root.inactiveIconOpacity
                        size: root.workspaceIconSize

                        Behavior on color {
                            ColorAnimation {
                                duration: root.colorAnimationDuration
                                easing.type: Easing.InOutQuad
                            }
                        }

                        Behavior on opacity {
                            NumberAnimation {
                                duration: root.colorAnimationDuration
                                easing.type: Easing.InOutQuad
                            }
                        }
                    }
                }

                SequentialAnimation {
                    id: activationPulse

                    NumberAnimation {
                        target: workspaceButton
                        property: "pulse"
                        from: 0
                        to: 1
                        duration: root.sizeAnimationDuration
                        easing.type: Easing.OutCubic
                    }

                    PropertyAction {
                        target: workspaceButton
                        property: "pulse"
                        value: 0
                    }
                }
            }
        }
    }
}
