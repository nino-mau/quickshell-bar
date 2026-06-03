pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Services as Services

MouseArea {
    id: root

    implicitWidth: pill.implicitWidth
    implicitHeight: Style.barHeight
    acceptedButtons: Qt.LeftButton
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor

    onClicked: Services.Weather.reload()

    Pill {
        id: pill

        anchors.centerIn: parent
        implicitWidth: layout.implicitWidth + Tokens.space4
        hovered: root.containsMouse

        RowLayout {
            id: layout
            property real textSpacing: Services.Weather.hasWeather ? Style.pillGap : 0

            anchors.centerIn: parent
            spacing: textSpacing

            Behavior on textSpacing {
                NumberAnimation {
                    duration: Tokens.duration260
                    easing.type: Easing.InOutQuad
                }
            }

            Text {
                text: Services.Weather.icon
                color: Style.pillText
                font.family: Style.iconFontFamily
                font.pixelSize: Style.pillIconSize
            }

            Item {
                id: temperatureWrapper

                readonly property bool shown: Services.Weather.hasWeather
                property real textWidth: shown ? temperatureText.implicitWidth : 0

                Layout.preferredWidth: textWidth
                Layout.preferredHeight: temperatureText.implicitHeight
                Layout.alignment: Qt.AlignVCenter
                clip: true
                opacity: shown ? 1 : 0

                Text {
                    id: temperatureText

                    anchors.verticalCenter: parent.verticalCenter
                    text: Services.Weather.temperatureText
                    color: Style.pillText
                    font.family: Style.defaultFontFamily
                    font.pixelSize: Tokens.textSM
                    font.weight: Tokens.fontMedium
                }

                Behavior on textWidth {
                    NumberAnimation {
                        duration: Tokens.duration260
                        easing.type: Easing.InOutQuad
                    }
                }

                Behavior on opacity {
                    NumberAnimation {
                        duration: Tokens.duration140
                        easing.type: Easing.InOutQuad
                    }
                }
            }
        }
    }
}
