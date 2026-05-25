import QtQuick
import qs.Commons

Rectangle {
    id: root

    default property alias content: contentItem.data

    property bool hovered: false
    property int horizontalPadding: Style.marginL

    implicitWidth: contentItem.childrenRect.width + horizontalPadding * 2
    implicitHeight: Style.capsuleHeight

    radius: Style.radiusL
    color: hovered ? Style.capsuleHover : Style.capsuleBackground
    border.color: Style.border
    border.width: 1

    Item {
        id: contentItem
        anchors.centerIn: parent
    }
}
