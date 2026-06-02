import QtQuick
import QtQuick.Effects
import QtQuick.Shapes
import Quickshell
import qs.Commons as Commons

PopupWindow {
    id: root

    default property alias content: popupContentArea.data

    property int popupContentWidth: 0
    property int popupContentHeight: 0
    property int shadowPadding: Commons.Tokens.space3
    property int attachOverlap: Commons.Tokens.space2
    property int reverseRadius: Commons.Style.radiusDefault
    property color backgroundColor: Commons.Style.barBackground
    property color borderColor: Commons.Theme.withAlpha(Commons.Theme.bg4, 0.65)
    property real openScale: 0.94

    readonly property real effectiveReverseRadius: Math.min(reverseRadius, popupContentWidth / 2, popupContentHeight / 2)
    readonly property real effectiveBottomRadius: Math.min(Commons.Style.radiusDefault, popupContentWidth / 2, popupContentHeight / 2)

    anchor.edges: Edges.Bottom
    anchor.gravity: Edges.Bottom
    anchor.margins.top: -attachOverlap
    implicitWidth: popupContentWidth + effectiveReverseRadius * 2 + shadowPadding * 2
    implicitHeight: popupContentHeight + shadowPadding
    color: "transparent"
    visible: false
    grabFocus: true

    onVisibleChanged: {
        if (visible) {
            popupOpenAnimation.restart();
        }
    }

    function open(): void {
        visible = true;
    }

    function close(): void {
        visible = false;
    }

    function toggle(): void {
        visible = !visible;
    }

    Item {
        id: popupSurface

        anchors.fill: parent
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
                    shadowVerticalOffset: Commons.Tokens.space1
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
                width: Commons.Style.borderWidth
                height: root.popupContentHeight - root.effectiveReverseRadius - root.effectiveBottomRadius
                color: root.borderColor
            }

            Rectangle {
                x: root.effectiveReverseRadius + root.popupContentWidth - Commons.Style.borderWidth
                y: root.effectiveReverseRadius
                width: Commons.Style.borderWidth
                height: root.popupContentHeight - root.effectiveReverseRadius - root.effectiveBottomRadius
                color: root.borderColor
            }

            Rectangle {
                x: root.effectiveReverseRadius + root.effectiveBottomRadius
                y: root.popupContentHeight - Commons.Style.borderWidth
                width: root.popupContentWidth - root.effectiveBottomRadius * 2
                height: Commons.Style.borderWidth
                color: root.borderColor
            }
        }

        ParallelAnimation {
            id: popupOpenAnimation

            OpacityAnimator {
                target: popupSurface
                from: 0
                to: 1
                duration: Commons.Style.animationFast
                easing.type: Easing.OutCubic
            }

            ScaleAnimator {
                target: popupSurface
                from: root.openScale
                to: 1
                duration: Commons.Style.animationFast
                easing.type: Easing.OutCubic
            }
        }
    }
}
