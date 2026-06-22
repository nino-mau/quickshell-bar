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
    // Cross-axis thickness (height on a horizontal bar) and along-axis length of
    // each workspace cell. Cells sit flush (no gap) so occupied surfaces can
    // merge into one connected track, stormy-style.
    property int workspaceWidth: 24
    property int cellLength: 30
    property int workspaceRadius: Style.defaultRadius
    property int workspaceIconSize: 15
    property int slideAnimationDuration: 280
    property int colorAnimationDuration: 160
    property int pulseSize: 12
    property real pulseOpacity: 0.45

    property color activeColor: Theme.blue
    // Subtle connected surface drawn behind occupied workspaces.
    property color occupiedSurface: Theme.withAlpha(Theme.fg, 0.10)
    property color activeTextColor: Theme.bg1
    property color occupiedTextColor: Theme.fg
    property color emptyTextColor: Theme.withAlpha(Theme.fg, 0.40)

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

    // A workspace renders a "filled" surface when it has windows and lives on
    // this monitor. Used both for the connected occupied background and to pick
    // icon colors.
    function workspaceFilled(workspaceId: int): bool {
        return workspaceOccupied(workspaceId) && !workspaceOnOtherMonitor(workspaceId);
    }

    Item {
        id: layout

        anchors.centerIn: parent

        // Flush cells form one continuous track so occupied surfaces can merge.
        readonly property int totalLength: root.effectiveWorkspaceCount * root.cellLength
        readonly property int activeIndex: root.activeWorkspaceId - 1

        implicitWidth: root.vertical ? root.workspaceWidth : totalLength
        implicitHeight: root.vertical ? totalLength : root.workspaceWidth

        function cellX(index: int): int {
            return root.vertical ? 0 : index * root.cellLength;
        }
        function cellY(index: int): int {
            return root.vertical ? index * root.cellLength : 0;
        }

        // Layer 1: connected occupied surface. Adjacent occupied workspaces
        // merge into one continuous track by squaring off their shared edges.
        Repeater {
            model: root.effectiveWorkspaceCount

            Rectangle {
                required property int index

                readonly property int workspaceId: index + 1
                readonly property bool filled: root.workspaceFilled(workspaceId)
                readonly property bool squareStart: filled && index > 0 && root.workspaceFilled(workspaceId - 1)
                readonly property bool squareEnd: filled && index < root.effectiveWorkspaceCount - 1 && root.workspaceFilled(workspaceId + 1)

                x: layout.cellX(index)
                y: layout.cellY(index)
                width: root.vertical ? root.workspaceWidth : root.cellLength
                height: root.vertical ? root.cellLength : root.workspaceWidth

                color: filled ? root.occupiedSurface : "transparent"

                readonly property int r: root.workspaceRadius
                // "start" = toward the previous cell (left/top), "end" = next.
                topLeftRadius: squareStart ? 0 : r
                topRightRadius: (root.vertical ? squareStart : squareEnd) ? 0 : r
                bottomLeftRadius: (root.vertical ? squareEnd : squareStart) ? 0 : r
                bottomRightRadius: squareEnd ? 0 : r

                Behavior on color {
                    ColorAnimation {
                        duration: root.colorAnimationDuration
                        easing.type: Easing.InOutQuad
                    }
                }
                Behavior on topLeftRadius { NumberAnimation { duration: root.colorAnimationDuration } }
                Behavior on topRightRadius { NumberAnimation { duration: root.colorAnimationDuration } }
                Behavior on bottomLeftRadius { NumberAnimation { duration: root.colorAnimationDuration } }
                Behavior on bottomRightRadius { NumberAnimation { duration: root.colorAnimationDuration } }
            }
        }

        // Layer 2: a single accent pill that slides to the active workspace,
        // with a one-shot pulse ring when it lands.
        Rectangle {
            id: indicator

            property real pulse: 0

            visible: layout.activeIndex >= 0 && layout.activeIndex < root.effectiveWorkspaceCount
            x: layout.cellX(layout.activeIndex)
            y: layout.cellY(layout.activeIndex)
            width: root.vertical ? root.workspaceWidth : root.cellLength
            height: root.vertical ? root.cellLength : root.workspaceWidth
            radius: root.workspaceRadius
            color: root.activeColor

            onXChanged: activationPulse.restart()
            onYChanged: activationPulse.restart()

            Behavior on x {
                NumberAnimation {
                    duration: root.slideAnimationDuration
                    easing.type: Easing.OutCubic
                }
            }
            Behavior on y {
                NumberAnimation {
                    duration: root.slideAnimationDuration
                    easing.type: Easing.OutCubic
                }
            }

            Rectangle {
                anchors.centerIn: parent
                width: parent.width + indicator.pulse * root.pulseSize
                height: parent.height + indicator.pulse * root.pulseSize
                radius: height / 2
                color: "transparent"
                border.color: root.activeColor
                border.width: Math.max(1, Math.round(2 * (1 - indicator.pulse)))
                opacity: (1 - indicator.pulse) * root.pulseOpacity
                visible: indicator.pulse > 0
            }

            SequentialAnimation {
                id: activationPulse

                NumberAnimation {
                    target: indicator
                    property: "pulse"
                    from: 0
                    to: 1
                    duration: root.slideAnimationDuration
                    easing.type: Easing.OutCubic
                }
                PropertyAction {
                    target: indicator
                    property: "pulse"
                    value: 0
                }
            }
        }

        // Layer 3: every workspace shows its icon, coloured by state (active /
        // occupied / empty); also the click target.
        Repeater {
            model: root.effectiveWorkspaceCount

            MouseArea {
                id: workspaceButton

                required property int index

                readonly property int workspaceId: index + 1
                readonly property bool active: root.activeWorkspaceId === workspaceId
                readonly property bool filled: root.workspaceFilled(workspaceId)

                x: layout.cellX(index)
                y: layout.cellY(index)
                width: root.vertical ? root.workspaceWidth : root.cellLength
                height: root.vertical ? root.cellLength : root.workspaceWidth

                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                Accessible.role: Accessible.Button
                Accessible.name: qsTr("Workspace %1").arg(workspaceId)

                onClicked: root.switchToWorkspace(workspaceId)

                RemixIcon {
                    anchors.centerIn: parent
                    name: root.workspaceIconName(workspaceButton.workspaceId)
                    size: root.workspaceIconSize
                    color: workspaceButton.active ? root.activeTextColor : workspaceButton.filled ? root.occupiedTextColor : root.emptyTextColor
                    // Lift idle icons a touch on hover.
                    opacity: workspaceButton.active || workspaceButton.filled || workspaceButton.containsMouse ? 1 : 0.85
                    scale: workspaceButton.containsMouse && !workspaceButton.active ? 1.12 : 1

                    Behavior on color {
                        ColorAnimation {
                            duration: root.colorAnimationDuration
                            easing.type: Easing.InOutQuad
                        }
                    }
                    Behavior on scale {
                        NumberAnimation {
                            duration: root.colorAnimationDuration
                            easing.type: Easing.OutBack
                        }
                    }
                }
            }
        }
    }
}
