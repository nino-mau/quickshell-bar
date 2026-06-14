pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import Quickshell
import qs.Commons

AbstractButton {
    id: root

    property color baseColor
    property bool square: false
    property bool vertical: true
    // Override to set a fixed launcher icon size; defaults to the capsule-derived size.
    property int iconSize: capsule.iconSize + 1

    Layout.fillWidth: root.vertical
    Layout.fillHeight: !root.vertical
    Layout.preferredHeight: root.square ? (root.width > 0 ? root.width : capsule.implicitHeight) : capsule.implicitHeight
    Layout.preferredWidth: root.square ? (root.height > 0 ? root.height : capsule.implicitHeight) : capsule.implicitHeight
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
        square: root.square
        vertical: root.vertical
    }

    contentItem: Item {
        id: content

        implicitWidth: capsule.implicitHeight
        implicitHeight: capsule.implicitHeight

        SvgIcon {
            anchors.centerIn: parent
            source: Qt.resolvedUrl(Quickshell.shellDir + "/Assets/Icons/arch.svg")
            size: root.iconSize
            color: capsule.textColor
            sourceColor: "#1793d1"
        }
    }
}
