pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import qs.Commons
import qs.Services as Services

Variants {
    model: Quickshell.screens

    delegate: PanelWindow {
        id: window

        required property ShellScreen modelData

        readonly property int popupWidth: 360
        readonly property int topOffset: Config.edge === "top" ? Style.barHeight + Style.barMarginTop + Tokens.space3 : Tokens.space5
        property bool keepVisible: Services.Notification.popupModel.count > 0
        property var animateConnection: null

        // Notification-toast styling (widget-specific; built from primitives).
        QtObject {
            id: toast

            readonly property int radius: Tokens.radius3XL
            readonly property int contentPadding: Tokens.space4
            readonly property int horizontalGap: Tokens.space3
            readonly property int verticalGap: Tokens.space2
            readonly property int headerGap: Tokens.space2
            readonly property int visualSize: Tokens.space12
            readonly property int iconSize: Tokens.space8
            readonly property int imageSourceSize: Tokens.space24
            readonly property int visualRadius: Tokens.radiusLG
            readonly property color visualBackground: "transparent"
            readonly property real backgroundOpacity: 0.6
            readonly property int borderWidth: Tokens.border1
            readonly property color border: Theme.border
            readonly property color background: Theme.bg1
            readonly property color color: Theme.withAlpha(background, backgroundOpacity)
            readonly property int closeButtonSize: Tokens.space5
            readonly property int closeTextSize: Tokens.textLG
            readonly property color closeColor: Theme.grey2
            readonly property color closeHoverColor: Theme.red
            readonly property color appColor: Theme.grey2
            readonly property int appTextSize: Tokens.textXS
            readonly property int appFontWeight: Tokens.fontMedium
            readonly property color summaryColor: Theme.fg
            readonly property int summaryTextSize: Tokens.textSM
            readonly property int summaryFontWeight: Tokens.fontBold
            readonly property color bodyColor: Theme.fg
            readonly property real bodyOpacity: 0.78
            readonly property int bodyTextSize: Tokens.textXS
            readonly property int bodyMaxLines: 3
        }

        screen: modelData
        color: "transparent"
        visible: keepVisible
        implicitWidth: popupWidth
        implicitHeight: notificationStack.implicitHeight + Tokens.space3

        WlrLayershell.namespace: "quickshell-notifications-" + (screen ? screen.name : "unknown")
        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.exclusionMode: ExclusionMode.Ignore
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

        anchors {
            top: true
            right: true
        }

        margins {
            top: window.topOffset
            right: Style.barMarginX
        }

        Connections {
            target: Services.Notification.popupModel

            function onCountChanged(): void {
                if (Services.Notification.popupModel.count > 0) {
                    hideTimer.stop();
                    window.keepVisible = true;
                    return;
                }
                hideTimer.restart();
            }
        }

        Timer {
            id: hideTimer

            interval: Tokens.duration450 + Tokens.duration200
            repeat: false

            onTriggered: window.keepVisible = Services.Notification.popupModel.count > 0
        }

        Component.onCompleted: {
            animateConnection = function (notificationId) {
                let delegate = null;
                for (let index = 0; index < notificationRepeater.count; index++) {
                    const item = notificationRepeater.itemAt(index);
                    if (item?.notificationId === notificationId) {
                        delegate = item;
                        break;
                    }
                }

                try {
                    if (delegate && typeof delegate.animateOut === "function" && !delegate.isRemoving) {
                        delegate.animateOut("expire");
                    }
                } catch (error) {
                    Services.Notification.expirePopup(notificationId);
                }
            };

            Services.Notification.animateAndRemove.connect(animateConnection);
        }

        Component.onDestruction: {
            if (animateConnection) {
                Services.Notification.animateAndRemove.disconnect(animateConnection);
                animateConnection = null;
            }
        }

        ColumnLayout {
            id: notificationStack

            anchors.top: parent.top
            anchors.right: parent.right
            width: window.popupWidth
            spacing: Tokens.space2

            Behavior on implicitHeight {
                SpringAnimation {
                    spring: 2.0
                    damping: 0.4
                    epsilon: 0.01
                    mass: 0.8
                }
            }

            Repeater {
                id: notificationRepeater

                model: Services.Notification.popupModel

                delegate: Item {
                    id: wrapper

                    required property int index
                    required property string notificationId
                    required property string appName
                    required property string summary
                    required property string body
                    required property string image
                    required property string appIcon

                    readonly property bool hasImage: image.length > 0
                    readonly property string defaultIconSource: iconSourceFor(appIcon)
                    readonly property bool hasVisual: notificationImage.visible || defaultAppIcon.visible
                    readonly property int animationDelay: index * Tokens.duration100
                    readonly property int slideDistance: 300
                    readonly property real enterSlideOffsetX: slideDistance
                    readonly property real exitSlideOffsetY: -slideDistance

                    Layout.fillWidth: true
                    implicitHeight: card.implicitHeight

                    property bool isRemoving: false
                    property string removalMode: "dismiss"
                    property real slideOffsetX: 0
                    property real slideOffsetY: 0
                    property real scaleValue: 0.8
                    property real opacityValue: 0.0

                    scale: scaleValue
                    opacity: opacityValue
                    transform: Translate {
                        x: wrapper.slideOffsetX
                        y: wrapper.slideOffsetY
                    }

                    function iconSourceFor(value: string): string {
                        const source = String(value ?? "").trim();
                        if (source.length === 0) {
                            return "";
                        }
                        if (source.startsWith("file:") || source.startsWith("image:") || source.startsWith("qrc:")) {
                            return source;
                        }
                        if (source.startsWith("/")) {
                            return "file://" + source;
                        }
                        return "image://icon/" + source;
                    }

                    function triggerEntryAnimation(): void {
                        animInDelayTimer.stop();
                        removalTimer.stop();
                        isRemoving = false;
                        removalMode = "dismiss";
                        slideOffsetX = enterSlideOffsetX;
                        slideOffsetY = 0;
                        scaleValue = 0.8;
                        opacityValue = 0.0;
                        animInDelayTimer.interval = animationDelay;
                        animInDelayTimer.start();
                    }

                    Component.onCompleted: triggerEntryAnimation()

                    onNotificationIdChanged: triggerEntryAnimation()

                    Timer {
                        id: animInDelayTimer

                        interval: 0
                        repeat: false

                        onTriggered: {
                            if (wrapper.isRemoving) {
                                return;
                            }
                            wrapper.slideOffsetX = 0;
                            wrapper.scaleValue = 1.0;
                            wrapper.opacityValue = 1.0;
                        }
                    }

                    function animateOut(mode) {
                        if (isRemoving) {
                            return;
                        }
                        animInDelayTimer.stop();
                        removalTimer.stop();
                        removalMode = mode && mode.length > 0 ? mode : "dismiss";
                        isRemoving = true;
                        slideOffsetX = 0;
                        slideOffsetY = exitSlideOffsetY;
                        scaleValue = 0.8;
                        opacityValue = 0.0;
                    }

                    Timer {
                        id: removalTimer

                        interval: Tokens.duration450
                        repeat: false

                        onTriggered: wrapper.finishRemoval()
                    }

                    onIsRemovingChanged: {
                        if (isRemoving) {
                            removalTimer.start();
                        }
                    }

                    function finishRemoval(): void {
                        if (removalMode === "expire") {
                            Services.Notification.expirePopup(notificationId);
                            return;
                        }
                        Services.Notification.dismissPopup(notificationId);
                    }

                    Behavior on scale {
                        SpringAnimation {
                            spring: 3.0
                            damping: 0.4
                            epsilon: 0.01
                            mass: 0.8
                        }
                    }

                    Behavior on opacity {
                        NumberAnimation {
                            duration: Tokens.duration300
                            easing.type: Easing.OutCubic
                        }
                    }

                    Behavior on slideOffsetX {
                        SpringAnimation {
                            spring: 3.2
                            damping: 0.22
                            epsilon: 0.01
                            mass: 0.55
                        }
                    }

                    Behavior on slideOffsetY {
                        SpringAnimation {
                            spring: 2.5
                            damping: 0.3
                            epsilon: 0.01
                            mass: 0.6
                        }
                    }

                    Rectangle {
                        id: card

                        readonly property int contentPadding: toast.contentPadding

                        width: parent.width
                        implicitHeight: content.implicitHeight + contentPadding * 2
                        radius: toast.radius
                        color: toast.color
                        border.width: toast.borderWidth
                        border.color: toast.border

                        MouseArea {
                            anchors.fill: parent
                            acceptedButtons: Qt.LeftButton | Qt.RightButton
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor

                            onClicked: event => {
                                if (event.button === Qt.RightButton) {
                                    wrapper.animateOut("dismiss");
                                    return;
                                }
                                Services.Notification.invokeDefaultAction(wrapper.notificationId);
                                wrapper.animateOut("dismiss");
                            }
                        }

                        RowLayout {
                            id: content

                            anchors.fill: parent
                            anchors.margins: card.contentPadding
                            spacing: toast.horizontalGap

                            Item {
                                visible: wrapper.hasVisual
                                Layout.preferredWidth: visible ? toast.visualSize : 0
                                Layout.preferredHeight: visible ? toast.visualSize : 0
                                Layout.alignment: Qt.AlignVCenter

                                ClippingRectangle {
                                    width: toast.visualSize
                                    height: toast.visualSize
                                    anchors.centerIn: parent
                                    radius: toast.visualRadius
                                    color: toast.visualBackground

                                    Image {
                                        id: notificationImage

                                        visible: wrapper.hasImage && status !== Image.Error
                                        anchors.fill: parent
                                        source: wrapper.image
                                        sourceSize.width: toast.imageSourceSize
                                        sourceSize.height: toast.imageSourceSize
                                        fillMode: Image.PreserveAspectCrop
                                        asynchronous: true
                                        cache: false
                                    }

                                    Item {
                                        id: appIconLayer

                                        visible: !notificationImage.visible && wrapper.defaultIconSource.length > 0
                                        anchors.fill: parent

                                        IconImage {
                                            id: defaultAppIcon

                                            visible: wrapper.defaultIconSource.length > 0 && status === Image.Ready
                                            anchors.centerIn: parent
                                            width: toast.iconSize
                                            height: toast.iconSize
                                            source: wrapper.defaultIconSource
                                            asynchronous: true
                                        }
                                    }
                                }
                            }

                            ColumnLayout {
                                id: textContent

                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignVCenter
                                spacing: toast.verticalGap

                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: toast.headerGap

                                    Text {
                                        Layout.fillWidth: true
                                        text: wrapper.appName
                                        color: toast.appColor
                                        elide: Text.ElideRight
                                        font.family: Style.defaultFontFamily
                                        font.pixelSize: toast.appTextSize
                                        font.styleName: ""
                                        font.weight: toast.appFontWeight
                                    }

                                    MouseArea {
                                        id: closeBtn

                                        Layout.preferredWidth: toast.closeButtonSize
                                        Layout.preferredHeight: toast.closeButtonSize
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor

                                        onClicked: event => {
                                            wrapper.animateOut("dismiss");
                                            event.accepted = true;
                                        }

                                        Text {
                                            anchors.centerIn: parent
                                            text: "×"
                                            color: closeBtn.containsMouse ? toast.closeHoverColor : toast.closeColor
                                            font.family: Style.defaultFontFamily
                                            font.pixelSize: toast.closeTextSize

                                            Behavior on color {
                                                ColorAnimation {
                                                    duration: Tokens.duration140
                                                    easing.type: Easing.InOutQuad
                                                }
                                            }
                                        }
                                    }
                                }

                                Text {
                                    Layout.fillWidth: true
                                    text: wrapper.summary.length > 0 ? wrapper.summary : qsTr("Notification")
                                    color: toast.summaryColor
                                    elide: Text.ElideRight
                                    font.family: Style.defaultFontFamily
                                    font.pixelSize: toast.summaryTextSize
                                    font.styleName: ""
                                    font.weight: toast.summaryFontWeight
                                }

                                Text {
                                    Layout.fillWidth: true
                                    visible: wrapper.body.length > 0
                                    text: wrapper.body
                                    color: toast.bodyColor
                                    opacity: toast.bodyOpacity
                                    wrapMode: Text.WordWrap
                                    elide: Text.ElideRight
                                    maximumLineCount: toast.bodyMaxLines
                                    font.family: Style.defaultFontFamily
                                    font.pixelSize: toast.bodyTextSize
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
