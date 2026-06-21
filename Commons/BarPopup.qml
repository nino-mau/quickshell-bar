pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Hyprland
import qs.Commons

/**
* A lightweight popup that attaches to a bar widget. It opens below the widget
* on a horizontal bar and to the right of it on a vertical bar.
*/
PopupWindow {
    id: root

    default property alias content: contentArea.data

    property int contentWidth: 0
    property int contentHeight: 0
    property int shadowPadding: 16
    property int gap: 6
    property int radius: Style.defaultRadius
    property color backgroundColor: Theme.bg1
    property color borderColor: Theme.withAlpha(Theme.bg4, 0.6)
    property real openScale: 0.94
    property int openDuration: 200
    property int closeDuration: 140
    property bool popupOpen: false
    property bool closing: false
    // Click-opened popups grab focus so an outside click dismisses them. Hover
    // tooltips want to stay passive, so let callers turn the grab off.
    property bool grabsFocus: true

    readonly property bool vertical: Config.vertical
    readonly property bool hyprlandActive: {
        const signature = Quickshell.env("HYPRLAND_INSTANCE_SIGNATURE");
        return (signature !== undefined && signature !== null && signature.length > 0) || Hyprland.requestSocketPath.length > 0;
    }

    anchor.edges: vertical ? Edges.Right : Edges.Bottom
    anchor.gravity: vertical ? Edges.Right : Edges.Bottom
    anchor.margins.top: vertical ? 0 : root.gap
    anchor.margins.left: vertical ? root.gap : 0

    implicitWidth: contentWidth + shadowPadding * 2
    implicitHeight: contentHeight + shadowPadding * 2
    color: "transparent"
    visible: popupOpen || closing
    grabFocus: root.popupOpen && root.grabsFocus && !root.hyprlandActive

    function open(): void {
        if (closeAnim.running) {
            closeAnim.stop();
        }
        closing = false;
        popupOpen = true;
        surface.opacity = 0;
        surface.scale = root.openScale;
        openAnim.restart();
    }

    function close(): void {
        if (!popupOpen || closeAnim.running) {
            return;
        }
        closing = true;
        popupOpen = false;
        openAnim.stop();
        closeAnim.restart();
    }

    function toggle(): void {
        if (popupOpen) {
            close();
            return;
        }
        open();
    }

    HyprlandFocusGrab {
        active: root.popupOpen && root.grabsFocus && root.hyprlandActive
        windows: [QsWindow.window]

        onCleared: root.close()
    }

    Item {
        id: surface

        anchors.fill: parent
        opacity: 0
        scale: root.openScale
        transformOrigin: root.vertical ? Item.Left : Item.Top

        Rectangle {
            anchors.fill: parent
            anchors.margins: root.shadowPadding
            radius: root.radius
            color: root.backgroundColor
            border.color: root.borderColor
            border.width: 1
            antialiasing: true

            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowBlur: 0.7
                shadowOpacity: 0.35
                shadowColor: "black"
                shadowVerticalOffset: 2
                blurMax: 32
                autoPaddingEnabled: true
            }

            Item {
                id: contentArea

                anchors.fill: parent
            }
        }
    }

    ParallelAnimation {
        id: openAnim

        NumberAnimation {
            target: surface
            property: "opacity"
            from: 0
            to: 1
            duration: root.openDuration
            easing.type: Easing.OutCubic
        }

        NumberAnimation {
            target: surface
            property: "scale"
            from: root.openScale
            to: 1
            duration: root.openDuration
            easing.type: Easing.OutCubic
        }
    }

    SequentialAnimation {
        id: closeAnim

        ParallelAnimation {
            NumberAnimation {
                target: surface
                property: "opacity"
                from: surface.opacity
                to: 0
                duration: root.closeDuration
                easing.type: Easing.InCubic
            }

            NumberAnimation {
                target: surface
                property: "scale"
                from: surface.scale
                to: root.openScale
                duration: root.closeDuration
                easing.type: Easing.InCubic
            }
        }

        ScriptAction {
            script: root.closing = false
        }
    }
}
