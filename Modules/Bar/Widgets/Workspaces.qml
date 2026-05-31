pragma ComponentBehavior: Bound

import Quickshell.Hyprland
import QtQuick.Layouts
import Quickshell
import QtQuick
import qs.Commons

Item {
    id: root

    // Style related propreties

    readonly property var workspaceIcons: ["", "", "", "", ""]
    readonly property int pillActiveWidth: 55
    readonly property int pillInactiveWidth: pillActiveWidth - 23
    readonly property int pillHeight: 23
    readonly property int pillGap: Tokens.space2
    readonly property int pillRadius: Tokens.radius2XL
    readonly property int pillSizeAnimationDuration: Style.animationVerySlow
    readonly property int pillColorAnimationDuration: Style.animationNormal
    readonly property int iconFontSize: Tokens.textSMHalf
    readonly property color pillActiveBg: Theme.primary
    readonly property color pillInactiveBg: Theme.bg3
    readonly property color iconActiveColor: Theme.bg0
    readonly property color iconInactiveColor: root.pillInactiveBg

    required property ShellScreen screen
    property int pillCount: 5

    implicitWidth: layout.implicitWidth

    readonly property int activeWorkspaceId: {
        var monitor = Hyprland.monitorFor(root.screen);
        if (monitor && monitor.activeWorkspace)
            return monitor.activeWorkspace.id;
        return Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id : -1;
    }

    function workspaceIcon(workspaceId: int): string {
        if (workspaceId > 0 && workspaceId <= workspaceIcons.length)
            return workspaceIcons[workspaceId - 1];
        return workspaceId.toString();
    }

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
        spacing: root.pillGap

        Repeater {
            model: root.pillCount

            delegate: MouseArea {
                id: workspaceButton

                required property int index

                readonly property int workspaceId: index + 1
                readonly property bool active: root.activeWorkspaceId === workspaceButton.workspaceId
                readonly property bool occupied: root.workspaceExists(workspaceButton.workspaceId)

                property real pillWidth: workspaceButton.active ? root.pillActiveWidth : root.pillInactiveWidth
                property real pillHeight: root.pillHeight

                property real pulse: 0

                implicitWidth: pillWidth
                implicitHeight: pillHeight
                Layout.preferredWidth: workspaceButton.implicitWidth
                Layout.preferredHeight: workspaceButton.implicitHeight
                Layout.alignment: Qt.AlignVCenter
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: Hyprland.dispatch("workspace " + workspaceButton.workspaceId)
                onActiveChanged: {
                    if (workspaceButton.active)
                        activationPulse.restart();
                }

                Behavior on pillWidth {
                    NumberAnimation {
                        duration: root.pillSizeAnimationDuration
                        easing.type: Easing.OutBack
                    }
                }

                Rectangle {
                    anchors.fill: parent
                    radius: root.pillRadius
                    color: workspaceButton.active ? root.pillActiveBg : root.pillInactiveBg
                    // border.color: Style.border
                    // border.width: Style.borderWidth

                    Behavior on color {
                        ColorAnimation {
                            duration: root.pillColorAnimationDuration
                            easing.type: Easing.InOutQuad
                        }
                    }

                    Rectangle {
                        anchors.centerIn: parent
                        width: parent.width + workspaceButton.pulse * 18
                        height: parent.height + workspaceButton.pulse * 18
                        radius: width / 2
                        color: "transparent"
                        border.color: root.pillActiveBg
                        border.width: Math.max(1, Math.round(3 * (1 - workspaceButton.pulse)))
                        opacity: (1 - workspaceButton.pulse) * 0.55
                        visible: workspaceButton.pulse > 0
                    }

                    Text {
                        anchors.centerIn: parent
                        text: root.workspaceIcon(workspaceButton.workspaceId)
                        color: workspaceButton.active ? root.iconActiveColor : root.iconInactiveColor
                        font.pixelSize: root.iconFontSize

                        Behavior on color {
                            ColorAnimation {
                                duration: root.pillColorAnimationDuration
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
                        duration: Style.animationNormal
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
