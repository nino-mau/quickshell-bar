pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import Quickshell
import qs.Commons
import qs.Services as Services

AbstractButton {
    id: root

    property color baseColor
    property bool vertical: true

    readonly property bool hasUpdates: Services.Updates.hasUpdates
    readonly property bool updating: Services.Updates.updating
    readonly property color accentColor: updating ? Theme.blue : (hasUpdates ? Theme.purple : capsule.textColor)

    Layout.fillWidth: root.vertical
    Layout.fillHeight: !root.vertical
    Layout.preferredHeight: Math.max(capsule.implicitHeight, implicitHeight)
    Layout.preferredWidth: Math.max(capsule.implicitHeight, implicitWidth)
    topPadding: root.vertical ? capsule.contentPadding : 0
    bottomPadding: root.vertical ? capsule.contentPadding : 0
    leftPadding: root.vertical ? 0 : capsule.contentPadding
    rightPadding: root.vertical ? 0 : capsule.contentPadding
    hoverEnabled: true
    Accessible.name: qsTr("System updates")

    function launch(): void {
        // Open a terminal running the first available helper (or pacman) and
        // keep the shell open afterwards.
        Quickshell.execDetached(["ghostty", "-e", "sh", "-c", "if command -v paru >/dev/null 2>&1; then paru; elif command -v yay >/dev/null 2>&1; then yay; else sudo pacman -Syu; fi; exec $SHELL"]);
    }

    onClicked: launch()

    HoverHandler {
        cursorShape: Qt.PointingHandCursor
    }

    TapHandler {
        acceptedButtons: Qt.RightButton
        onTapped: Services.Updates.reload()
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

            property real textSpacing: root.hasUpdates ? (root.vertical ? capsule.contentSpacing : 6) : 0

            anchors.centerIn: parent
            columns: root.vertical ? 1 : 2
            rowSpacing: textSpacing
            columnSpacing: textSpacing

            Behavior on textSpacing {
                NumberAnimation {
                    duration: 260
                    easing.type: Easing.InOutQuad
                }
            }

            // Updates icon
            LucideIcon {
                Layout.alignment: Qt.AlignCenter
                Layout.preferredWidth: capsule.iconSize
                Layout.preferredHeight: capsule.iconSize
                name: root.updating ? "cloud-upload" : (root.hasUpdates ? "cloud-download" : "cloud-check")
                color: root.accentColor
                size: capsule.iconSize

                Behavior on color {
                    ColorAnimation {
                        duration: 140
                        easing.type: Easing.InOutQuad
                    }
                }
            }

            // Update count
            Item {
                id: countWrapper

                Layout.alignment: Qt.AlignCenter
                readonly property bool shown: root.hasUpdates
                property real textWidth: shown ? countText.implicitWidth : 0
                Layout.preferredWidth: textWidth
                Layout.preferredHeight: countText.implicitHeight
                clip: true
                opacity: shown ? 1 : 0

                Text {
                    id: countText

                    anchors.verticalCenter: parent.verticalCenter
                    text: Services.Updates.countText
                    color: root.accentColor
                    font.pixelSize: root.vertical ? capsule.textSize : capsule.horizontalTextSize
                    font.weight: Tokens.fontMedium

                    Behavior on color {
                        ColorAnimation {
                            duration: 140
                            easing.type: Easing.InOutQuad
                        }
                    }
                }

                Behavior on textWidth {
                    NumberAnimation {
                        duration: 260
                        easing.type: Easing.InOutQuad
                    }
                }

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
