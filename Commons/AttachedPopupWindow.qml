import QtQuick
import QtQuick.Effects
import QtQuick.Shapes
import Quickshell
import Quickshell.Hyprland
import qs.Commons

PopupWindow {
    id: root

    default property alias content: popupContentArea.data

    property int popupContentWidth: 0
    property int popupContentHeight: 0
    property int shadowPadding: Tokens.space3
    property int attachOverlap: Tokens.space2
    property int reverseRadius: Style.popupRadius
    property color backgroundColor: Theme.surface
    property color borderColor: Theme.withAlpha(Commons.Theme.bg4, 0.65)
    property real openScale: 0.94
    property real slideDistance: Tokens.space3
    property int openAnimationDuration: Tokens.duration200
    property int closeAnimationDuration: Tokens.duration140
    property bool popupOpen: false
    property bool closing: false

    readonly property real effectiveReverseRadius: Math.min(reverseRadius, popupContentWidth / 2, popupContentHeight / 2)
    readonly property real effectiveBottomRadius: Math.min(Style.popupRadius, popupContentWidth / 2, popupContentHeight / 2)

    anchor.edges: Edges.Bottom
    anchor.gravity: Edges.Bottom
    anchor.margins.top: -attachOverlap
    implicitWidth: popupContentWidth + effectiveReverseRadius * 2 + shadowPadding * 2
    implicitHeight: popupContentHeight + shadowPadding
    color: "transparent"
    visible: popupOpen || closing
    grabFocus: false

    function open(): void {
        if (popupCloseAnimation.running) {
            popupCloseAnimation.stop();
        }

        closing = false;
        popupOpen = true;
        popupSurface.opacity = 0;
        popupSurface.scale = root.openScale;
        popupSurface.y = -root.slideDistance;
        popupOpenAnimation.restart();
    }

    function close(): void {
        if (!popupOpen || popupCloseAnimation.running) {
            return;
        }

        closing = true;
        popupOpen = false;
        popupOpenAnimation.stop();
        popupCloseAnimation.restart();
    }

    function toggle(): void {
        if (popupOpen) {
            close();
            return;
        }

        open();
    }

    function finishClose(): void {
        closing = false;
        popupSurface.opacity = 0;
        popupSurface.scale = root.openScale;
        popupSurface.y = -root.slideDistance;
    }

    HyprlandFocusGrab {
        active: root.popupOpen
        windows: [QsWindow.window]

        onCleared: root.close()
    }

    Item {
        id: popupSurface

        x: 0
        y: -root.slideDistance
        width: parent.width
        height: parent.height
        opacity: 0
        scale: root.openScale
        transformOrigin: Item.Top

        Item {
            id: popupBackground

            anchors.fill: parent
            anchors.leftMargin: root.shadowPadding
            anchors.rightMargin: root.shadowPadding
            anchors.topMargin: 0
            anchors.bottomMargin: root.shadowPadding

            Shape {
                id: popupShape

                anchors.fill: parent
                preferredRendererType: Shape.CurveRenderer
                layer.enabled: true
                layer.effect: MultiEffect {
                    shadowEnabled: true
                    shadowBlur: 0.75
                    shadowOpacity: 0.35
                    shadowColor: "black"
                    shadowHorizontalOffset: 0
                    shadowVerticalOffset: Tokens.space1
                    blurMax: 32
                    autoPaddingEnabled: true
                }

                ShapePath {
                    id: popupShapePath

                    readonly property real r: root.effectiveReverseRadius
                    readonly property real br: root.effectiveBottomRadius
                    readonly property real bodyWidth: root.popupContentWidth
                    readonly property real bodyHeight: root.popupContentHeight

                    strokeWidth: -1
                    fillColor: root.backgroundColor
                    startX: 0
                    startY: 0

                    PathLine {
                        relativeX: popupShapePath.bodyWidth + popupShapePath.r * 2
                        relativeY: 0
                    }

                    PathArc {
                        relativeX: -popupShapePath.r
                        relativeY: popupShapePath.r
                        radiusX: popupShapePath.r
                        radiusY: popupShapePath.r
                        direction: PathArc.Counterclockwise
                    }

                    PathLine {
                        relativeX: 0
                        relativeY: popupShapePath.bodyHeight - popupShapePath.r - popupShapePath.br
                    }

                    PathArc {
                        relativeX: -popupShapePath.br
                        relativeY: popupShapePath.br
                        radiusX: popupShapePath.br
                        radiusY: popupShapePath.br
                    }

                    PathLine {
                        relativeX: -(popupShapePath.bodyWidth - popupShapePath.br * 2)
                        relativeY: 0
                    }

                    PathArc {
                        relativeX: -popupShapePath.br
                        relativeY: -popupShapePath.br
                        radiusX: popupShapePath.br
                        radiusY: popupShapePath.br
                    }

                    PathLine {
                        relativeX: 0
                        relativeY: -(popupShapePath.bodyHeight - popupShapePath.br - popupShapePath.r)
                    }

                    PathArc {
                        relativeX: -popupShapePath.r
                        relativeY: -popupShapePath.r
                        radiusX: popupShapePath.r
                        radiusY: popupShapePath.r
                        direction: PathArc.Counterclockwise
                    }
                }
            }

            Item {
                id: popupContentArea

                x: root.effectiveReverseRadius
                width: root.popupContentWidth
                height: root.popupContentHeight
            }

            Rectangle {
                x: root.effectiveReverseRadius
                y: root.effectiveReverseRadius
                width: Style.popupBorderWidth
                height: root.popupContentHeight - root.effectiveReverseRadius - root.effectiveBottomRadius
                color: root.borderColor
            }

            Rectangle {
                x: root.effectiveReverseRadius + root.popupContentWidth - Style.popupBorderWidth
                y: root.effectiveReverseRadius
                width: Style.popupBorderWidth
                height: root.popupContentHeight - root.effectiveReverseRadius - root.effectiveBottomRadius
                color: root.borderColor
            }

            Rectangle {
                x: root.effectiveReverseRadius + root.effectiveBottomRadius
                y: root.popupContentHeight - Style.popupBorderWidth
                width: root.popupContentWidth - root.effectiveBottomRadius * 2
                height: Style.popupBorderWidth
                color: root.borderColor
            }
        }

        ParallelAnimation {
            id: popupOpenAnimation

            NumberAnimation {
                target: popupSurface
                property: "opacity"
                from: 0
                to: 1
                duration: root.openAnimationDuration
                easing.type: Easing.OutCubic
            }

            NumberAnimation {
                target: popupSurface
                property: "y"
                from: -root.slideDistance
                to: 0
                duration: root.openAnimationDuration
                easing.type: Easing.OutCubic
            }

            NumberAnimation {
                target: popupSurface
                property: "scale"
                from: root.openScale
                to: 1
                duration: root.openAnimationDuration
                easing.type: Easing.OutCubic
            }
        }

        SequentialAnimation {
            id: popupCloseAnimation

            ParallelAnimation {
                NumberAnimation {
                    target: popupSurface
                    property: "opacity"
                    from: popupSurface.opacity
                    to: 0
                    duration: root.closeAnimationDuration
                    easing.type: Easing.InCubic
                }

                NumberAnimation {
                    target: popupSurface
                    property: "y"
                    from: popupSurface.y
                    to: -root.slideDistance
                    duration: root.closeAnimationDuration
                    easing.type: Easing.InCubic
                }

                NumberAnimation {
                    target: popupSurface
                    property: "scale"
                    from: popupSurface.scale
                    to: root.openScale
                    duration: root.closeAnimationDuration
                    easing.type: Easing.InCubic
                }
            }

            ScriptAction {
                script: root.finishClose()
            }
        }
    }
}
