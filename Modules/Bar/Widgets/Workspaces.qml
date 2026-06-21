pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Niri
import qs.Commons

Item {
    id: root

    required property ShellScreen screen

    property bool vertical: true
    property int workspaceCount: 5

    property var workspaceIcons: ["terminal-line", "firefox-fill", "terminal-line", "shapes-fill", "layout-2-fill"]
    property int workspaceWidth: 22
    property int workspaceInactiveHeight: 22
    property int workspaceActiveHeight: 35
    property int workspaceGap: 5
    property int workspaceRadius: Tokens.radiusFull
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

    property int compositorRevision: 0

    readonly property bool niriActive: {
        const socket = Quickshell.env("NIRI_SOCKET");
        return (socket !== undefined && socket !== null && socket.length > 0) || Niri.socketPath.length > 0;
    }
    readonly property bool hyprlandActive: {
        const signature = Quickshell.env("HYPRLAND_INSTANCE_SIGNATURE");
        return !niriActive && ((signature !== undefined && signature !== null && signature.length > 0) || Hyprland.requestSocketPath.length > 0);
    }
    readonly property int effectiveWorkspaceCount: niriActive ? Math.max(workspaceCount, maxNiriWorkspaceIndex()) : workspaceCount
    readonly property int activeWorkspaceId: {
        root.compositorRevision;

        if (root.niriActive) {
            const workspace = root.activeNiriWorkspace();
            return workspace ? workspace.idx : -1;
        }

        if (!root.hyprlandActive) {
            return -1;
        }

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

    Component.onCompleted: {
        if (root.niriActive) {
            Niri.refreshWorkspaces();
        } else if (root.hyprlandActive) {
            Hyprland.refreshMonitors();
            Hyprland.refreshWorkspaces();
        }
    }

    Connections {
        target: root.niriActive ? Niri : null

        function onWorkspacesUpdated(): void {
            root.compositorRevision++;
        }
    }

    Connections {
        target: root.hyprlandActive ? Hyprland : null

        function onFocusedWorkspaceChanged(): void {
            root.compositorRevision++;
        }

        function onFocusedMonitorChanged(): void {
            root.compositorRevision++;
        }

        function onRawEvent(event): void {
            if (["workspace", "createworkspace", "destroyworkspace", "moveworkspace", "focusedmon"].indexOf(event.name) !== -1) {
                root.compositorRevision++;
            }
        }
    }

    function lowerText(value: var): string {
        return value !== undefined && value !== null ? value.toString().toLowerCase() : "";
    }

    function maxNiriWorkspaceIndex(): int {
        root.compositorRevision;

        if (!root.niriActive) {
            return root.workspaceCount;
        }

        const currentOutput = lowerText(currentMonitorName());
        const workspaces = Niri.workspaces.values;
        let maxIndex = root.workspaceCount;

        for (let i = 0; i < workspaces.length; i++) {
            const workspace = workspaces[i];
            if (currentOutput.length > 0 && lowerText(workspace.output) !== currentOutput) {
                continue;
            }
            maxIndex = Math.max(maxIndex, workspace.idx);
        }

        return maxIndex;
    }

    function activeNiriWorkspace(): var {
        root.compositorRevision;

        const currentOutput = lowerText(currentMonitorName());
        const workspaces = Niri.workspaces.values;
        let focusedWorkspace = null;

        for (let i = 0; i < workspaces.length; i++) {
            const workspace = workspaces[i];
            if (currentOutput.length > 0 && lowerText(workspace.output) !== currentOutput) {
                continue;
            }
            if (workspace.active) {
                return workspace;
            }
            if (workspace.focused) {
                focusedWorkspace = workspace;
            }
        }

        if (focusedWorkspace) {
            return focusedWorkspace;
        }

        for (let i = 0; i < workspaces.length; i++) {
            if (workspaces[i].focused) {
                return workspaces[i];
            }
        }

        return null;
    }

    function niriWorkspaceForIndex(workspaceIndex: int): var {
        root.compositorRevision;

        const currentOutput = lowerText(currentMonitorName());
        const workspaces = Niri.workspaces.values;

        for (let i = 0; i < workspaces.length; i++) {
            const workspace = workspaces[i];
            if (workspace.idx !== workspaceIndex) {
                continue;
            }
            if (currentOutput.length === 0 || lowerText(workspace.output) === currentOutput) {
                return workspace;
            }
        }

        return null;
    }

    function workspaceForId(workspaceId: int): var {
        root.compositorRevision;

        if (root.niriActive) {
            return niriWorkspaceForIndex(workspaceId);
        }

        if (!root.hyprlandActive) {
            return null;
        }

        const workspaces = Hyprland.workspaces.values;
        for (let i = 0; i < workspaces.length; i++) {
            if (workspaces[i].id === workspaceId) {
                return workspaces[i];
            }
        }

        return null;
    }

    function workspaceOccupied(workspaceId: int): bool {
        const workspace = workspaceForId(workspaceId);
        return root.niriActive ? workspace !== null && workspace.occupied : workspace !== null;
    }

    function workspaceMonitorName(workspaceId: int): string {
        const workspace = workspaceForId(workspaceId);
        if (!workspace) {
            return "";
        }
        if (root.niriActive) {
            return workspace.output || "";
        }
        return workspace.monitor ? workspace.monitor.name : "";
    }

    function currentMonitorName(): string {
        if (root.niriActive) {
            return root.screen ? root.screen.name : "";
        }

        if (!root.hyprlandActive) {
            return "";
        }

        const monitor = Hyprland.monitorFor(root.screen);
        return monitor ? monitor.name : "";
    }

    function workspaceOnOtherMonitor(workspaceId: int): bool {
        if (root.niriActive || !root.hyprlandActive) {
            return false;
        }

        const workspaceMonitor = workspaceMonitorName(workspaceId);
        const currentMonitor = currentMonitorName();
        return workspaceMonitor.length > 0 && currentMonitor.length > 0 && workspaceMonitor !== currentMonitor;
    }

    function switchToWorkspace(workspaceId: int): void {
        if (root.niriActive) {
            const monitorName = currentMonitorName();
            if (monitorName.length > 0) {
                Niri.dispatch(["focus-monitor", monitorName]);
            }
            Niri.dispatch(["focus-workspace", workspaceId.toString()]);
            return;
        }

        if (root.hyprlandActive) {
            Hyprland.dispatch("workspace " + workspaceId);
        }
    }

    function workspaceIconName(workspaceId: int): string {
        return workspaceIcons[workspaceId - 1] || workspaceIcons[0] || "terminal-line";
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
            model: root.effectiveWorkspaceCount

            MouseArea {
                id: workspaceButton

                required property int index

                readonly property int workspaceId: index + 1
                readonly property bool active: root.activeWorkspaceId === workspaceId
                readonly property bool occupied: root.workspaceOccupied(workspaceId)
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

                onClicked: root.switchToWorkspace(workspaceId)
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

                    RemixIcon {
                        anchors.centerIn: parent
                        name: root.workspaceIconName(workspaceButton.workspaceId)
                        color: workspaceButton.active ? root.activeTextColor : root.inactiveTextColor
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
