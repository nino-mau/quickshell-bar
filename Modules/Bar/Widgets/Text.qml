import QtQuick
import qs.Commons

Item {
    id: root

    property string text: ""

    implicitWidth: capsule.implicitWidth
    implicitHeight: Style.barHeight

    Capsule {
        id: capsule
        anchors.centerIn: parent

        Text {
            anchors.centerIn: parent
            text: root.text
            color: Style.mutedText
            font.pixelSize: Style.fontSizeM
            font.weight: Font.Medium
        }
    }
}
