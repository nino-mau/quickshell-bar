import QtQuick
import Quickshell
import qs.Commons

Item {
    id: root

    property string format: "dd MMM HH:mm:ss"

    implicitWidth: clockText.implicitWidth
    implicitHeight: Style.barHeight

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }

    Text {
        id: clockText
        anchors.centerIn: parent
        font.family: Style.defaultFontFamily
        text: Qt.formatDateTime(clock.date, root.format)
        color: Theme.text
        font.pixelSize: Tokens.textBase
        font.weight: Tokens.fontMedium
    }
}
