pragma ComponentBehavior: Bound

import Quickshell.Hyprland
import QtQuick.Layouts
import Quickshell
import QtQuick
import qs.Commons

Item {
    id: root

    required property ShellScreen screen
    property int count: 5

    readonly property int activeWorkspaceId: {
        var monitor = Hyprland.monitorFor(root.screen);
        if (monitor && monitor.activeWorkspace)
            return monitor.activeWorkspace.id;
        return Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id : -1;
    }

    implicitWidth: layout.implicitWidth
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
                readonly property bool active: root.activeWorkspaceId === workspaceButton.workspaceId
                readonly property bool occupied: root.workspaceExists(workspaceButton.workspaceId)

                property real pillWidth: workspaceButton.active ? Style.workspacePillActiveWidth : Style.workspacePillInactiveWidth
                property real pulse: 0

                implicitWidth: pillWidth
                implicitHeight: 25
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
                        duration: Style.animationVerySlow
                        easing.type: Easing.OutBack
                    }
                }

                Rectangle {
                    anchors.fill: parent
                    radius: Style.radiusDefault
                    color: workspaceButton.active ? Style.workspacePillActiveBg : (workspaceButton.containsMouse ? Style.workspacePillInactiveBg : "transparent")
                    border.color: Style.border
                    border.width: Style.borderWidth

                    Behavior on color {
                        ColorAnimation {
                            duration: Style.animationNormal
                            easing.type: Easing.InOutQuad
                        }
                    }

                    Rectangle {
                        anchors.centerIn: parent
                        width: parent.width + workspaceButton.pulse * 18
                        height: parent.height + workspaceButton.pulse * 18
                        radius: width / 2
                        color: "transparent"
                        border.color: Style.workspacePillActiveBg
                        border.width: Math.max(1, Math.round(3 * (1 - workspaceButton.pulse)))
                        opacity: (1 - workspaceButton.pulse) * 0.55
                        visible: workspaceButton.pulse > 0
                    }

                    Text {
                        anchors.centerIn: parent
                        text: workspaceButton.workspaceId
                        color: workspaceButton.active ? Style.activeText : (workspaceButton.occupied ? Style.text : Style.mutedText)
                        font.pixelSize: Style.fontSizeS
                        font.weight: workspaceButton.active || workspaceButton.occupied ? Font.Bold : Font.Medium

                        Behavior on color {
                            ColorAnimation {
                                duration: Style.animationNormal
                                easing.type: Easing.InOutQuad
                            }
                        }
                    }
                }

                // SequentialAnimation {
                //     id: activationPulse
                //
                //     NumberAnimation {
                //         target: workspaceButton
                //         property: "pulse"
                //         from: 0
                //         to: 1
                //         duration: Style.animationNormal
                //         easing.type: Easing.OutCubic
                //     }
                //
                //     PropertyAction {
                //         target: workspaceButton
                //         property: "pulse"
                //         value: 0
                //     }
                // }
            }
        }
    }
}
