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
    }

    contentItem: Item {
        id: content

        implicitWidth: capsule.implicitHeight
        implicitHeight: capsule.implicitHeight

        readonly property int capsuleBaseSize: width > 0 ? width : capsule.implicitHeight
        readonly property int iconPadding: Math.round(capsuleBaseSize * Style.capsuleIconPaddingRatio)
        readonly property int iconSize: Math.max(0, capsuleBaseSize - iconPadding * 2)

        SvgIcon {
            anchors.centerIn: parent
            anchors.horizontalCenterOffset: 0.5
            source: Qt.resolvedUrl(Quickshell.shellDir + "/Assets/Icons/arch.svg")
            size: iconSize - 4
            color: capsule.textColor
            sourceColor: "#1793d1"
        }

        // Icon {
        //     Layout.alignment: Qt.AlignHCenter
        //     anchors.centerIn: parent
        //     name: "memory"
        //     color: capsule.textcolor
        //     size: content.iconSize
        // }
    }
}
