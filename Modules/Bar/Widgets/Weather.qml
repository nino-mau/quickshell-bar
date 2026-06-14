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
    topPadding: root.vertical ? Style.capsuleVerticalPadding : 0
    bottomPadding: root.vertical ? Style.capsuleVerticalPadding : 0
    leftPadding: root.vertical ? 0 : Style.capsuleVerticalPadding
    rightPadding: root.vertical ? 0 : Style.capsuleVerticalPadding
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

        baseColor: root.baseColor
        hovered: root.hovered || root.down
    }

    contentItem: Item {
        id: content

        readonly property int crossSize: root.vertical ? width : height
        readonly property int capsuleBaseSize: crossSize > 0 ? crossSize : capsule.implicitHeight
        readonly property int iconPadding: Math.round(capsuleBaseSize * Style.capsuleIconPaddingRatio)
        readonly property int iconSize: Math.max(0, capsuleBaseSize - iconPadding * 2)
        readonly property int textPadding: Math.round(capsuleBaseSize * Style.capsuleTextPaddingRatio)
        readonly property int textSize: Math.max(1, capsuleBaseSize - textPadding * 2)

        implicitWidth: layout.implicitWidth
        implicitHeight: layout.implicitHeight

        GridLayout {
            id: layout

            property real textSpacing: Services.Weather.hasWeather ? (root.vertical ? Style.defaultCapsuleSpacing : 6) : 0

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
            LucideIcon {
                Layout.alignment: Qt.AlignCenter
                Layout.preferredWidth: content.iconSize
                Layout.preferredHeight: content.iconSize
                name: Services.Weather.icon
                color: capsule.textColor
                size: content.iconSize
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
                    font.pixelSize: root.vertical ? content.textSize : capsule.horizontalTextSize
                    font.weight: Style.fontMedium
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
