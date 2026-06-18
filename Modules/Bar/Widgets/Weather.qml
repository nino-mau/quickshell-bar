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

    Layout.fillWidth: root.vertical
    Layout.fillHeight: !root.vertical
    Layout.preferredHeight: Math.max(capsule.implicitHeight, implicitHeight)
    Layout.preferredWidth: Math.max(capsule.implicitHeight, implicitWidth)
    topPadding: root.vertical ? capsule.contentPadding : 0
    bottomPadding: root.vertical ? capsule.contentPadding : 0
    leftPadding: root.vertical ? 0 : capsule.contentPadding
    rightPadding: root.vertical ? 0 : capsule.contentPadding
    hoverEnabled: true
    Accessible.name: qsTr("Open launcher")

    function launch() {
        Quickshell.execDetached(["vicinae", "toggle"]);
    }

    onClicked: launch()

    HoverHandler {
        cursorShape: Qt.PointingHandCursor
    }

    TapHandler {
        acceptedButtons: Qt.RightButton
        onTapped: root.launch()
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

            property real textSpacing: Services.Weather.hasWeather ? (root.vertical ? capsule.contentSpacing : 6) : 0

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

            // Weather icon
            RemixIcon {
                Layout.alignment: Qt.AlignCenter
                Layout.preferredWidth: capsule.iconSize
                Layout.preferredHeight: capsule.iconSize
                name: Services.Weather.icon
                color: capsule.textColor
                size: capsule.iconSize
            }

            // Weather text
            Item {
                id: temperatureWrapper

                Layout.alignment: Qt.AlignCenter
                readonly property bool shown: Services.Weather.hasWeather
                property real textWidth: shown ? temperatureText.implicitWidth : 0
                Layout.preferredWidth: textWidth
                Layout.preferredHeight: temperatureText.implicitHeight
                clip: true
                opacity: shown ? 1 : 0

                Text {
                    id: temperatureText

                    anchors.verticalCenter: parent.verticalCenter
                    text: root.vertical ? Services.Weather.temperatureC : Services.Weather.temperatureText
                    color: capsule.textColor
                    font.pixelSize: root.vertical ? capsule.textSize : capsule.horizontalTextSize
                    font.weight: Tokens.fontMedium
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
