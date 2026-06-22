pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.Commons

// Simple stormy-style session screen: a dimmed fullscreen overlay with a row of
// large action cards (lock / logout / suspend / reboot / shutdown). Open it over
// IPC, e.g.  qs -c bar ipc call session toggle
// Mouse: hover + click. Keyboard: ←/→ to move, Enter to activate, Esc to close.
Scope {
    id: root

    // Emitted for the lock action so shell.qml can drive the Lock module
    // instead of this screen reaching across to it.
    signal lockRequested

    property bool shown: false
    property int selected: 0

    // Each card: icon, label, accent colour, and the action to run.
    readonly property var actions: [
        {
            "icon": "lock-2-line",
            "label": qsTr("Lock"),
            "color": Theme.blue,
            "kind": "lock"
        },
        {
            "icon": "logout-box-r-line",
            "label": qsTr("Logout"),
            "color": Theme.purple,
            "kind": "exec",
            "cmd": ["hyprctl", "dispatch", "exit"]
        },
        {
            "icon": "moon-line",
            "label": qsTr("Suspend"),
            "color": Theme.aqua,
            "kind": "exec",
            "cmd": ["systemctl", "suspend"]
        },
        {
            "icon": "restart-line",
            "label": qsTr("Reboot"),
            "color": Theme.yellow,
            "kind": "exec",
            "cmd": ["systemctl", "reboot"]
        },
        {
            "icon": "shut-down-line",
            "label": qsTr("Shutdown"),
            "color": Theme.red,
            "kind": "exec",
            "cmd": ["systemctl", "poweroff"]
        }
    ]

    function open(): void {
        selected = 0;
        shown = true;
    }
    function close(): void {
        shown = false;
    }
    function activate(index: int): void {
        const action = actions[index];
        if (!action)
            return;
        close();
        if (action.kind === "lock") {
            root.lockRequested();
            return;
        }
        Quickshell.execDetached(action.cmd);
    }

    IpcHandler {
        target: "session"

        function show(): void {
            root.open();
        }
        function hide(): void {
            root.close();
        }
        function toggle(): void {
            if (root.shown)
                root.close();
            else
                root.open();
        }
    }

    Variants {
        model: Quickshell.screens

        delegate: PanelWindow {
            id: window

            required property ShellScreen modelData

            // Card geometry / styling, built from the shared primitives.
            readonly property int cardSize: Tokens.space32
            readonly property int cardGap: Tokens.space5
            readonly property int iconSize: Tokens.text4XL

            screen: modelData
            color: "transparent"
            visible: root.shown || overlay.opacity > 0.01

            WlrLayershell.namespace: "quickshell-session-" + (screen ? screen.name : "unknown")
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: root.shown ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
            WlrLayershell.exclusionMode: ExclusionMode.Ignore

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }

            // Dimmed backdrop + content, faded together.
            Item {
                id: overlay

                anchors.fill: parent
                focus: true
                opacity: root.shown ? 1 : 0

                Behavior on opacity {
                    NumberAnimation {
                        duration: Tokens.duration200
                        easing.type: Easing.OutCubic
                    }
                }

                // Grab keyboard focus whenever the screen is shown.
                Connections {
                    target: root

                    function onShownChanged(): void {
                        if (root.shown)
                            overlay.forceActiveFocus();
                    }
                }

                Keys.onPressed: event => {
                    // Number keys 1..N activate the matching card directly.
                    if (event.key >= Qt.Key_1 && event.key <= Qt.Key_9) {
                        const index = event.key - Qt.Key_1;
                        if (index < root.actions.length) {
                            root.activate(index);
                            event.accepted = true;
                        }
                        return;
                    }

                    switch (event.key) {
                    case Qt.Key_Escape:
                        root.close();
                        break;
                    case Qt.Key_Left:
                    case Qt.Key_H:
                        root.selected = (root.selected - 1 + root.actions.length) % root.actions.length;
                        break;
                    case Qt.Key_Right:
                    case Qt.Key_L:
                        root.selected = (root.selected + 1) % root.actions.length;
                        break;
                    case Qt.Key_Return:
                    case Qt.Key_Enter:
                        root.activate(root.selected);
                        break;
                    default:
                        return;
                    }
                    event.accepted = true;
                }

                Rectangle {
                    anchors.fill: parent
                    // Dim kept below Hyprland's blur ignore_alpha (0.5) so the
                    // backdrop darkens but isn't blurred — only the cards, whose
                    // alpha sits above that threshold, get the compositor blur.
                    color: Theme.withAlpha(Theme.bg0, 0.4)

                    // Click outside the cards dismisses.
                    MouseArea {
                        anchors.fill: parent
                        onClicked: root.close()
                    }
                }

                RowLayout {
                    anchors.centerIn: parent
                    spacing: window.cardGap
                    scale: root.shown ? 1 : 0.94

                    Behavior on scale {
                        NumberAnimation {
                            duration: Tokens.duration200
                            easing.type: Easing.OutCubic
                        }
                    }

                    Repeater {
                        model: root.actions

                        delegate: Rectangle {
                            id: card

                            required property int index
                            required property var modelData

                            readonly property bool current: root.selected === index
                            readonly property bool active: current || hover.hovered

                            Layout.preferredWidth: window.cardSize
                            Layout.preferredHeight: window.cardSize
                            radius: Tokens.radius2XL
                            // Constant frosted fill (kept above the blur threshold
                            // of 0.5 so every card stays frosted); selection is
                            // shown via the accent border, icon, and number only.
                            color: Theme.withAlpha(Theme.bg2, 0.6)
                            border.width: Tokens.border1
                            border.color: active ? Theme.withAlpha(modelData.color, 0.5) : Theme.withAlpha(Theme.bg4, 0.35)

                            // Grow slightly when selected/hovered (scales about
                            // the centre, so it doesn't shift the row layout).
                            scale: active ? 1.08 : 1

                            Behavior on scale {
                                NumberAnimation {
                                    duration: Tokens.duration200
                                    easing.type: Easing.OutBack
                                }
                            }

                            Behavior on color {
                                ColorAnimation {
                                    duration: Tokens.duration140
                                    easing.type: Easing.InOutQuad
                                }
                            }
                            Behavior on border.color {
                                ColorAnimation {
                                    duration: Tokens.duration140
                                    easing.type: Easing.InOutQuad
                                }
                            }

                            HoverHandler {
                                id: hover

                                cursorShape: Qt.PointingHandCursor
                                onHoveredChanged: {
                                    if (hovered)
                                        root.selected = card.index;
                                }
                            }

                            TapHandler {
                                onTapped: root.activate(card.index)
                            }

                            // Shortcut number hint (1-based).
                            Text {
                                anchors.top: parent.top
                                anchors.left: parent.left
                                anchors.topMargin: Tokens.space3
                                anchors.leftMargin: Tokens.space3
                                text: card.index + 1
                                color: card.active ? card.modelData.color : Theme.withAlpha(Theme.fg, 0.35)
                                font.family: Style.defaultFontFamily
                                font.pixelSize: Tokens.textXS
                                font.weight: Tokens.fontBold

                                Behavior on color {
                                    ColorAnimation {
                                        duration: Tokens.duration140
                                        easing.type: Easing.InOutQuad
                                    }
                                }
                            }

                            ColumnLayout {
                                anchors.centerIn: parent
                                spacing: Tokens.space3

                                RemixIcon {
                                    Layout.alignment: Qt.AlignHCenter
                                    name: card.modelData.icon
                                    color: card.active ? card.modelData.color : Theme.fg
                                    size: window.iconSize

                                    Behavior on color {
                                        ColorAnimation {
                                            duration: Tokens.duration140
                                            easing.type: Easing.InOutQuad
                                        }
                                    }
                                }

                                Text {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: card.modelData.label
                                    color: card.active ? Theme.fg : Theme.grey2
                                    font.family: Style.defaultFontFamily
                                    font.pixelSize: Tokens.textSM
                                    font.weight: Tokens.fontMedium
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
