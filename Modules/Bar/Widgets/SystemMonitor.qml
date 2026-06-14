pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import Quickshell
import qs.Commons
import qs.Modules
import qs.Services as Services

AbstractButton {
    id: root

    property color baseColor
    property bool vertical: true

    readonly property int linearGaugeHeight: 3

    readonly property real warningUsageThreshold: 0.7
    readonly property real criticalUsageThreshold: 0.9
    readonly property real warningCpuTempThreshold: 70
    readonly property real criticalCpuTempThreshold: 85

    readonly property string usageRegistrationId: "system-monitor-" + Math.random().toString(36).slice(2)

    Layout.fillWidth: root.vertical
    Layout.fillHeight: !root.vertical
    Layout.preferredHeight: Math.max(capsule.implicitHeight, implicitHeight)
    Layout.preferredWidth: Math.max(capsule.implicitHeight, implicitWidth)
    // The row starts with an icon glyph (which carries font side-bearing
    // whitespace) and ends with a flush gauge bar, so equal box padding looks
    // left-heavy. Nudge the right padding so the *visible* gaps match.
    readonly property int iconOpticalInset: 3

    topPadding: root.vertical ? capsule.contentPadding : 0
    bottomPadding: root.vertical ? capsule.contentPadding : 0
    leftPadding: root.vertical ? 0 : capsule.contentPadding
    rightPadding: root.vertical ? 0 : capsule.contentPadding + iconOpticalInset
    hoverEnabled: true
    Accessible.name: qsTr("System monitor")

    Component.onCompleted: Services.SystemUsage.registerComponent(usageRegistrationId)
    Component.onDestruction: Services.SystemUsage.unregisterComponent(usageRegistrationId)

    onClicked: {
        const entry = DesktopEntries.heuristicLookup("btop");
        if (entry) {
            Quickshell.execDetached(["ghostty", "-e", "btop"]);
        }
    }

    HoverHandler {
        cursorShape: Qt.PointingHandCursor
    }

    function usageColor(value: real): color {
        if (value >= criticalUsageThreshold) {
            return Theme.red;
        }
        if (value >= warningUsageThreshold) {
            return Theme.yellow;
        }
        return capsule.textColor;
    }

    function tempColor(value: real): color {
        if (value >= criticalCpuTempThreshold) {
            return Theme.red;
        }
        if (value >= warningCpuTempThreshold) {
            return Theme.yellow;
        }
        return capsule.textColor;
    }

    background: Capsule {
        id: capsule

        vertical: root.vertical
        baseColor: root.baseColor
        hovered: root.hovered || root.down
    }

    contentItem: Item {
        id: content

        implicitWidth: layout.implicitWidth
        implicitHeight: layout.implicitHeight

        GridLayout {
            id: layout
            anchors.centerIn: parent
            columns: root.vertical ? 1 : 3
            rowSpacing: 8
            columnSpacing: 10

            // Memory usage
            GridLayout {
                Layout.alignment: Qt.AlignCenter
                columns: root.vertical ? 1 : 2
                rowSpacing: 3
                columnSpacing: 4

                LucideIcon {
                    Layout.alignment: root.vertical ? Qt.AlignHCenter : Qt.AlignVCenter
                    Layout.preferredWidth: capsule.iconSize
                    Layout.preferredHeight: capsule.iconSize
                    name: "cpu"
                    color: root.usageColor(Services.SystemUsage.memPerc)
                    size: capsule.iconSize
                }

                LinearGauge {
                    Layout.alignment: root.vertical ? Qt.AlignHCenter : Qt.AlignVCenter
                    Layout.preferredWidth: root.vertical ? capsule.iconSize : root.linearGaugeHeight
                    Layout.preferredHeight: root.vertical ? root.linearGaugeHeight : capsule.iconSize
                    orientation: root.vertical ? Qt.Horizontal : Qt.Vertical
                    ratio: Math.max(0.2, Services.SystemUsage.memPerc)
                    fillColor: root.usageColor(Services.SystemUsage.memPerc)
                }
            }

            // CPU Usage
            GridLayout {
                Layout.alignment: Qt.AlignCenter
                columns: root.vertical ? 1 : 2
                rowSpacing: 3
                columnSpacing: 4

                LucideIcon {
                    Layout.alignment: root.vertical ? Qt.AlignHCenter : Qt.AlignVCenter
                    Layout.preferredWidth: capsule.iconSize
                    Layout.preferredHeight: capsule.iconSize
                    name: "gauge"
                    color: root.usageColor(Services.SystemUsage.cpuPerc)
                    size: capsule.iconSize
                }

                LinearGauge {
                    Layout.alignment: root.vertical ? Qt.AlignHCenter : Qt.AlignVCenter
                    Layout.preferredWidth: root.vertical ? capsule.iconSize : root.linearGaugeHeight
                    Layout.preferredHeight: root.vertical ? root.linearGaugeHeight : capsule.iconSize
                    orientation: root.vertical ? Qt.Horizontal : Qt.Vertical
                    ratio: Math.max(0.2, Services.SystemUsage.cpuPerc)
                    fillColor: root.usageColor(Services.SystemUsage.cpuPerc)
                }
            }

            // CPU Temperature
            GridLayout {
                Layout.alignment: Qt.AlignCenter
                columns: root.vertical ? 1 : 2
                rowSpacing: 3
                columnSpacing: 4

                LucideIcon {
                    Layout.alignment: root.vertical ? Qt.AlignHCenter : Qt.AlignVCenter
                    Layout.preferredWidth: capsule.iconSize
                    Layout.preferredHeight: capsule.iconSize
                    name: "flame"
                    color: root.tempColor(Services.SystemUsage.cpuTemp)
                    size: capsule.iconSize
                }

                LinearGauge {
                    Layout.alignment: root.vertical ? Qt.AlignHCenter : Qt.AlignVCenter
                    Layout.preferredWidth: root.vertical ? capsule.iconSize : root.linearGaugeHeight
                    Layout.preferredHeight: root.vertical ? root.linearGaugeHeight : capsule.iconSize
                    orientation: root.vertical ? Qt.Horizontal : Qt.Vertical
                    ratio: Services.SystemUsage.cpuTempPerc
                    fillColor: root.tempColor(Services.SystemUsage.cpuTemp)
                }
            }
        }
    }
}
