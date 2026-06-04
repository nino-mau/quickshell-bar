pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import QtQuick.Layouts
import qs.Commons
import qs.Services as Services

MouseArea {
    id: root

    readonly property real warningUsageThreshold: 0.7
    readonly property real criticalUsageThreshold: 0.9
    readonly property real warningCpuTempThreshold: 70
    readonly property real criticalCpuTempThreshold: 85

    implicitWidth: pill.implicitWidth
    implicitHeight: Style.barHeight
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor

    Component.onCompleted: Services.SystemUsage.registerComponent("bar:system-monitor")
    Component.onDestruction: Services.SystemUsage.unregisterComponent("bar:system-monitor")

    onClicked: {
        const entry = DesktopEntries.heuristicLookup("btop");
        if (entry) {
            Quickshell.execDetached(["ghostty", "-e", "btop"]);
        }
    }

    function usageColor(value: real): color {
        if (value >= criticalUsageThreshold) {
            return Theme.red;
        }
        if (value >= warningUsageThreshold) {
            return Theme.yellow;
        }
        return Style.pillText;
    }

    function tempColor(value: real): color {
        if (value >= criticalCpuTempThreshold) {
            return Theme.red;
        }
        if (value >= warningCpuTempThreshold) {
            return Theme.yellow;
        }
        return Style.pillText;
    }

    Pill {
        id: pill

        anchors.centerIn: parent
        implicitWidth: layout.implicitWidth + Tokens.space4
        hovered: root.containsMouse

        RowLayout {
            id: layout

            anchors.centerIn: parent
            spacing: Style.pillGap

            // Memory usage
            RowLayout {
                id: memoryUsageLayout
                spacing: Tokens.space1
                // Icon
                Text {
                    text: Icons.memory
                    color: Style.pillText
                    font.pixelSize: Style.pillIconSize
                }
                // Value
                Text {
                    text: Services.SystemUsage.displayMemPerc
                    color: root.usageColor(Services.SystemUsage.memPerc)
                    font.pixelSize: Style.pillTextSize

                    Behavior on color {
                        ColorAnimation {
                            duration: Tokens.duration140
                            easing.type: Easing.InOutQuad
                        }
                    }
                }
            }

            // CPU Temp
            RowLayout {
                id: cpuTempLayout
                spacing: Tokens.space1

                // Icon
                Text {
                    text: Icons.cpuTemp
                    color: Style.pillText
                    font.pixelSize: Style.pillIconSize
                }

                // Value
                Text {
                    text: Services.SystemUsage.displayCpuTemp
                    color: root.tempColor(Services.SystemUsage.cpuTemp)
                    font.pixelSize: Style.pillTextSize

                    Behavior on color {
                        ColorAnimation {
                            duration: Tokens.duration140
                            easing.type: Easing.InOutQuad
                        }
                    }
                }
            }

            // CPU Perc
            RowLayout {
                id: cpuPercLayout
                spacing: Tokens.space1

                // Icon
                Text {
                    text: Icons.cpuPerc
                    color: Style.pillText
                    font.pixelSize: Style.pillIconSize
                }

                // Value
                Text {
                    text: Services.SystemUsage.displayCpuPerc
                    color: root.usageColor(Services.SystemUsage.cpuPerc)
                    font.pixelSize: Style.pillTextSize

                    Behavior on color {
                        ColorAnimation {
                            duration: Tokens.duration140
                            easing.type: Easing.InOutQuad
                        }
                    }
                }
            }
        }
    }
}
