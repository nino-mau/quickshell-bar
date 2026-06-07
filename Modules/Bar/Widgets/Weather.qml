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

    Layout.fillWidth: true
    Layout.preferredHeight: Math.max(capsule.implicitHeight, implicitHeight)
    topPadding: Style.capsuleVerticalPadding
    bottomPadding: Style.capsuleVerticalPadding
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

        readonly property int capsuleBaseSize: width > 0 ? width : capsule.implicitHeight
        readonly property int iconPadding: Math.round(capsuleBaseSize * Style.capsuleIconPaddingRatio)
        readonly property int iconSize: Math.max(0, capsuleBaseSize - iconPadding * 2)
        readonly property int textPadding: Math.round(capsuleBaseSize * Style.capsuleTextPaddingRatio)
        readonly property int textSize: Math.max(1, capsuleBaseSize - textPadding * 2)

        implicitWidth: layout.implicitWidth
        implicitHeight: layout.implicitHeight

        ColumnLayout {
            id: layout

            property real textSpacing: Services.Weather.hasWeather ? Style.defaultCapsuleSpacing : 0

            anchors.centerIn: parent
            spacing: textSpacing

            Behavior on textSpacing {
                NumberAnimation {
                    duration: 260
                    easing.type: Easing.InOutQuad
                }
            }

            // Weather icon
            Icon {
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: content.iconSize
                Layout.preferredHeight: content.iconSize
                name: Services.Weather.icon
                color: capsule.textColor
                size: content.iconSize
            }

            // Weather text
            Item {
                id: temperatureWrapper

                Layout.alignment: Qt.AlignHCenter
                readonly property bool shown: Services.Weather.hasWeather
                property real textWidth: shown ? temperatureText.implicitWidth : 0
                Layout.preferredWidth: textWidth
                Layout.preferredHeight: temperatureText.implicitHeight
                clip: true
                opacity: shown ? 1 : 0

                Text {
                    id: temperatureText

                    anchors.verticalCenter: parent.verticalCenter
                    text: Services.Weather.temperatureC
                    color: capsule.textColor
                    font.pixelSize: content.textSize
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
