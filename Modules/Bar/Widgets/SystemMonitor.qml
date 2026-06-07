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

    readonly property int linearGaugeHeight: 3
    readonly property real capsuleIconSizeRatio: 0.60
    readonly property real capsuleIconPaddingRatio: (1 - capsuleIconSizeRatio) / 2
    readonly property real capsuleTextSizeRatio: 0.35
    readonly property real capsuleTextPaddingRatio: (1 - capsuleTextSizeRatio) / 2

    readonly property real warningUsageThreshold: 0.7
    readonly property real criticalUsageThreshold: 0.9
    readonly property real warningCpuTempThreshold: 70
    readonly property real criticalCpuTempThreshold: 85

    readonly property string usageRegistrationId: "system-monitor-" + Math.random().toString(36).slice(2)

    Layout.fillWidth: true
    Layout.preferredHeight: Math.max(capsule.implicitHeight, implicitHeight)
    topPadding: Style.capsuleVerticalPadding
    bottomPadding: Style.capsuleVerticalPadding
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

        baseColor: root.baseColor
        hovered: root.hovered || root.down
    }

    contentItem: Item {
        id: content

        readonly property int capsuleBaseSize: width > 0 ? width : capsule.implicitHeight
        readonly property int iconPadding: Math.round(capsuleBaseSize * root.capsuleIconPaddingRatio)
        readonly property int iconSize: Math.max(0, capsuleBaseSize - iconPadding * 2)
        readonly property int textPadding: Math.round(capsuleBaseSize * root.capsuleTextPaddingRatio)
        readonly property int textSize: Math.max(1, capsuleBaseSize - textPadding * 2)

        implicitWidth: layout.implicitWidth
        implicitHeight: layout.implicitHeight

        ColumnLayout {
            id: layout
            anchors.verticalCenterOffset: -2
            anchors.centerIn: parent
            spacing: 8

            // Memory usage
            ColumnLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 1

                Icon {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: content.iconSize
                    Layout.preferredHeight: content.iconSize
                    name: "memory"
                    color: root.usageColor(Services.SystemUsage.memPerc)
                    size: content.iconSize
                }

                LinearGauge {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: content.iconSize
                    Layout.preferredHeight: root.linearGaugeHeight
                    orientation: Qt.Horizontal
                    ratio: Math.max(0.2, Services.SystemUsage.memPerc)
                    fillColor: root.usageColor(Services.SystemUsage.memPerc)
                }
            }

            // CPU Usage
            ColumnLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 1

                Icon {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: content.iconSize
                    Layout.preferredHeight: content.iconSize
                    name: "speed"
                    color: root.usageColor(Services.SystemUsage.cpuPerc)
                    size: content.iconSize
                }

                LinearGauge {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: content.iconSize
                    Layout.preferredHeight: root.linearGaugeHeight
                    orientation: Qt.Horizontal
                    ratio: Math.max(0.2, Services.SystemUsage.cpuPerc)
                    fillColor: root.usageColor(Services.SystemUsage.cpuPerc)
                }
            }

            // CPU Temperature
            ColumnLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 1

                Icon {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: content.iconSize
                    Layout.preferredHeight: content.iconSize
                    name: "heat"
                    color: root.tempColor(Services.SystemUsage.cpuTemp)
                    size: content.iconSize
                }

                LinearGauge {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: content.iconSize
                    Layout.preferredHeight: root.linearGaugeHeight
                    orientation: Qt.Horizontal
                    ratio: Services.SystemUsage.cpuTempPerc
                    fillColor: root.tempColor(Services.SystemUsage.cpuTemp)
                }
            }
        }
    }
}
