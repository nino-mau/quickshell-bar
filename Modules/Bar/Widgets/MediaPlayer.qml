pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Effects
import QtQuick.Layouts
import qs.Commons
import qs.Modules.Bar
import qs.Services as Services

AbstractButton {
    id: root

    property color baseColor
    property bool square: false
    property bool vertical: true

    // Hover-driven popup (open while either the widget or the popup is hovered).
    property bool popupHovered: false
    readonly property bool shouldShowPopup: Services.Media.hasPlayer && (root.hovered || root.popupHovered)

    onShouldShowPopupChanged: {
        if (shouldShowPopup) {
            popupCloseTimer.stop();
            mediaPopup.open();
        } else {
            popupCloseTimer.restart();
        }
    }

    Timer {
        id: popupCloseTimer
        interval: 150
        onTriggered: {
            if (!root.shouldShowPopup) {
                mediaPopup.close();
            }
        }
    }

    readonly property int visualizerClipPadding: 4

    // Visualizer fill opacity, per orientation and playback state.
    readonly property real visualizerVerticalOpacity: 0.15
    readonly property real visualizerVerticalPauseOpacity: 0.28
    readonly property real visualizerHorizontalOpacity: 0.45
    readonly property real visualizerHorizontalPauseOpacity: 0.28

    readonly property int textSize: Tokens.textSM
    readonly property int textWeight: Tokens.fontDemiBold

    readonly property string pausePrefix: " "

    // Horizontal "title pill" sizing
    readonly property int titlePadding: 30
    readonly property int titleMinWidth: 200
    readonly property int titleMaxTextWidth: 100
    readonly property real titleTextWidth: Math.max(titleMetrics.width, artistMetrics.width)
    readonly property real titleContentWidth: Math.max(titleMinWidth, Math.min(titleTextWidth, titleMaxTextWidth) + titlePadding * 2)

    Layout.fillWidth: root.vertical
    Layout.fillHeight: !root.vertical
    Layout.preferredHeight: root.vertical ? (root.square ? (root.width > 0 ? root.width : capsule.implicitHeight) : capsule.implicitHeight) : capsule.implicitHeight
    Layout.preferredWidth: root.vertical ? (root.square ? (root.height > 0 ? root.height : capsule.implicitHeight) : capsule.implicitHeight) : root.titleContentWidth
    visible: root.vertical || Services.Media.hasPlayer
    topPadding: 0
    bottomPadding: 0
    hoverEnabled: true
    Accessible.name: Services.Media.displayText.length > 0 ? Services.Media.displayText : qsTr("Media player")

    onClicked: {
        if (Services.Media.hasPlayer) {
            Services.Media.togglePlaying();
        }
    }

    onDoubleClicked: {
        if (Services.Media.hasPlayer && Services.Media.isPlaying) {
            Services.Media.pause();
        }
    }

    HoverHandler {
        cursorShape: Services.Media.hasPlayer ? Qt.PointingHandCursor : Qt.ArrowCursor
    }

    TapHandler {
        acceptedButtons: Qt.RightButton
        onTapped: Services.Media.next()
    }

    TapHandler {
        acceptedButtons: Qt.MiddleButton
        onTapped: Services.Media.previous()
    }

    TextMetrics {
        id: titleMetrics
        text: Services.Media.title
        font.pixelSize: root.textSize
        font.weight: root.textWeight
    }

    TextMetrics {
        id: artistMetrics
        text: Services.Media.artist
        font.pixelSize: root.textSize
        font.weight: root.textWeight
    }

    background: Capsule {
        id: capsule

        vertical: root.vertical
        baseColor: root.baseColor
        hovered: root.hovered || root.down
        square: root.vertical && root.square
        clip: true
    }

    contentItem: Item {
        id: content

        implicitWidth: capsule.implicitHeight
        implicitHeight: capsule.implicitHeight

        // Vertical: square visualizer with a pause glyph
        Item {
            id: visualizerClipBounds

            anchors.fill: parent
            anchors.margins: root.visualizerClipPadding
            clip: true
            visible: root.vertical

            AudioVisualizer {
                id: visualizer

                anchors.fill: parent
                componentId: "bar:media:visualizer:vertical"
                visible: root.vertical && Services.Media.hasPlayer
                active: Services.Media.isPlaying
                type: "mirrored"
                minimumLevel: Services.Media.isPlaying ? 0.06 : 0.10
                maximumLevel: 0.62
                levelScale: 0.9
                barWidthRatio: 0.68
                colorOpacity: Services.Media.isPlaying ? root.visualizerVerticalOpacity : root.visualizerVerticalPauseOpacity
                barColor: capsule.textColor
            }

            RemixIcon {
                anchors.centerIn: parent
                name: "pause-fill"
                opacity: Services.Media.isPlaying ? 0 : 1
                color: capsule.textColor
                size: capsule.iconSize
            }
        }

        // Horizontal: title pill with a visualizer behind the track text
        Item {
            anchors.fill: parent
            visible: !root.vertical

            AudioVisualizer {
                anchors.fill: parent
                anchors.margins: 3
                componentId: "bar:media:visualizer:horizontal"
                visible: !root.vertical && Services.Media.hasPlayer
                active: Services.Media.isPlaying
                type: "mirrored"
                minimumLevel: 0.04
                maximumLevel: 0.7
                colorOpacity: Services.Media.isPlaying ? root.visualizerHorizontalOpacity : root.visualizerHorizontalPauseOpacity
                barColor: capsule.textColor
            }

            // Track title that slides down, alternating between title and artist
            Item {
                id: titleClip

                anchors.fill: parent
                anchors.leftMargin: root.titlePadding
                anchors.rightMargin: root.titlePadding
                clip: true

                readonly property bool hasTitle: Services.Media.title.length > 0
                readonly property bool hasArtist: Services.Media.artist.length > 0
                readonly property bool canAlternate: hasTitle && hasArtist && Services.Media.title !== Services.Media.artist
                readonly property string firstText: hasTitle ? Services.Media.title : Services.Media.artist
                readonly property string secondText: hasArtist ? Services.Media.artist : Services.Media.title
                property bool showingFirstText: true
                property real slideProgress: 0
                property string currentText: firstText
                property string nextText: ""

                onFirstTextChanged: resetText()
                onSecondTextChanged: resetText()

                function resetText(): void {
                    slideAnimation.stop();
                    showingFirstText = true;
                    currentText = firstText;
                    nextText = "";
                    slideProgress = 0;
                }

                function showNextText(): void {
                    if (!canAlternate || slideAnimation.running) {
                        return;
                    }
                    nextText = showingFirstText ? secondText : firstText;
                    showingFirstText = !showingFirstText;
                    slideProgress = 0;
                    slideAnimation.start();
                }

                Text {
                    id: currentMediaText

                    width: parent.width
                    y: (parent.height - implicitHeight) / 2 + titleClip.slideProgress * parent.height
                    text: Services.Media.isPlaying ? titleClip.currentText : root.pausePrefix + titleClip.currentText
                    color: capsule.textColor
                    font.pixelSize: capsule.horizontalTextSize
                    font.styleName: ''
                    font.weight: root.textWeight
                    horizontalAlignment: Text.AlignHCenter
                    elide: Text.ElideRight
                }

                Text {
                    id: nextMediaText

                    visible: slideAnimation.running
                    width: parent.width
                    y: (parent.height - implicitHeight) / 2 - (1 - titleClip.slideProgress) * parent.height
                    text: Services.Media.isPlaying ? titleClip.currentText : root.pausePrefix + titleClip.currentText
                    color: capsule.textColor
                    font.pixelSize: capsule.horizontalTextSize
                    font.styleName: ''
                    font.weight: root.textWeight
                    horizontalAlignment: Text.AlignHCenter
                    elide: Text.ElideRight
                }

                Timer {
                    interval: 7000
                    repeat: true
                    running: titleClip.canAlternate && !root.vertical && root.visible
                    onTriggered: titleClip.showNextText()
                }

                SequentialAnimation {
                    id: slideAnimation

                    NumberAnimation {
                        target: titleClip
                        property: "slideProgress"
                        from: 0
                        to: 1
                        duration: 520
                        easing.type: Easing.InOutQuad
                    }

                    ScriptAction {
                        script: {
                            titleClip.currentText = titleClip.nextText;
                            titleClip.nextText = "";
                            titleClip.slideProgress = 0;
                        }
                    }
                }
            }
        }
    }

    // Media controls popup
    BarPopup {
        id: mediaPopup

        readonly property int popupPadding: 14

        anchor.item: root
        grabsFocus: false
        radius: Tokens.radius2XL
        contentWidth: 372
        contentHeight: 156

        function formatTime(seconds: real): string {
            if (!isFinite(seconds) || seconds < 0) {
                return "0:00";
            }
            const total = Services.Media.trackLength;
            const showHours = total >= 3600;
            const h = Math.floor(seconds / 3600);
            const m = Math.floor((seconds % 3600) / 60);
            const s = Math.floor(seconds % 60);
            const pad = (n) => (n < 10 ? "0" + n : "" + n);
            return showHours ? (h + ":" + pad(m) + ":" + pad(s)) : (m + ":" + pad(s));
        }

        // Blurred album-art backdrop (masked to the popup's rounded corners).
        Item {
            id: backdrop

            anchors.fill: parent
            visible: backdropImage.status === Image.Ready

            Image {
                id: backdropImage

                anchors.fill: parent
                source: Services.Media.artUrl
                // Heavily blurred, so a small decode is indistinguishable from a
                // full-res one — cap it to keep MPRIS art (often 1000px+) from
                // sitting in VRAM at native size.
                sourceSize.width: 256
                sourceSize.height: 256
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                cache: false
                layer.enabled: true
                layer.effect: MultiEffect {
                    blurEnabled: true
                    blur: 1.0
                    blurMax: 32
                }
            }

            Rectangle {
                anchors.fill: parent
                color: Qt.rgba(0, 0, 0, 0.45)
            }

            layer.enabled: true
            layer.effect: MultiEffect {
                maskEnabled: true
                maskThresholdMin: 0.5
                maskSource: ShaderEffectSource {
                    sourceItem: Rectangle {
                        width: backdrop.width
                        height: backdrop.height
                        radius: mediaPopup.radius
                        color: "white"
                    }
                }
            }
        }

        RowLayout {
            id: popupBody

            anchors.fill: parent
            anchors.margins: mediaPopup.popupPadding
            spacing: 14

            // Album art — fills the full content height so its top/bottom
            // margins match the rest of the popup.
            Rectangle {
                Layout.fillHeight: true
                Layout.preferredWidth: height
                radius: Tokens.radiusXL
                color: Theme.withAlpha(Theme.bg2, 0.8)

                RemixIcon {
                    anchors.centerIn: parent
                    name: "music-line"
                    size: 40
                    color: Theme.withAlpha(Theme.fg, 0.5)
                    visible: cover.status !== Image.Ready
                }

                Image {
                    id: cover

                    anchors.fill: parent
                    source: Services.Media.artUrl
                    // Rendered ~128px square; 256 keeps it crisp on HiDPI while
                    // capping the decoded texture.
                    sourceSize.width: 256
                    sourceSize.height: 256
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    cache: false
                    visible: status === Image.Ready
                    layer.enabled: true
                    layer.smooth: true
                    layer.effect: MultiEffect {
                        maskEnabled: true
                        maskThresholdMin: 0.5
                        maskSource: ShaderEffectSource {
                            sourceItem: Rectangle {
                                width: cover.width
                                height: cover.height
                                radius: Tokens.radiusXL
                                color: "white"
                            }
                        }
                    }
                }

                // Hairline border over the art.
                Rectangle {
                    anchors.fill: parent
                    radius: Tokens.radiusXL
                    color: "transparent"
                    border.width: 1
                    border.color: Theme.withAlpha(Theme.fg, 0.1)
                }
            }

            // Info + controls
            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.alignment: Qt.AlignVCenter
                spacing: 3

                Text {
                    Layout.fillWidth: true
                    text: Services.Media.title.length > 0 ? Services.Media.title : qsTr("Nothing playing")
                    color: Theme.fg
                    font.pixelSize: Tokens.textBase
                    font.weight: Tokens.fontBold
                    elide: Text.ElideRight
                    maximumLineCount: 1
                }

                Text {
                    Layout.fillWidth: true
                    visible: Services.Media.artist.length > 0
                    text: Services.Media.artist
                    color: Theme.withAlpha(Theme.fg, 0.7)
                    font.pixelSize: Tokens.textXS
                    font.weight: Tokens.fontMedium
                    elide: Text.ElideRight
                    maximumLineCount: 1
                }

                Item {
                    Layout.fillHeight: true
                }

                // Time labels
                RowLayout {
                    Layout.fillWidth: true
                    visible: Services.Media.hasProgress

                    Text {
                        text: mediaPopup.formatTime(Services.Media.currentPosition)
                        color: Theme.withAlpha(Theme.fg, 0.6)
                        font.pixelSize: Tokens.textXS
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    Text {
                        text: mediaPopup.formatTime(Services.Media.trackLength)
                        color: Theme.withAlpha(Theme.fg, 0.6)
                        font.pixelSize: Tokens.textXS
                    }
                }

                // Seek bar
                Rectangle {
                    id: seekTrack

                    Layout.fillWidth: true
                    Layout.preferredHeight: 6
                    Layout.bottomMargin: 4
                    visible: Services.Media.hasProgress
                    radius: height / 2
                    color: Theme.withAlpha(Theme.fg, 0.18)

                    Rectangle {
                        id: seekFill

                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        width: parent.width * Services.Media.progress
                        radius: height / 2
                        color: root.baseColor

                        Behavior on width {
                            NumberAnimation {
                                duration: 200
                                easing.type: Easing.InOutQuad
                            }
                        }
                    }

                    Rectangle {
                        x: seekFill.width - width / 2
                        anchors.verticalCenter: parent.verticalCenter
                        width: 13
                        height: 13
                        radius: width / 2
                        color: root.baseColor
                        visible: seekArea.containsMouse || seekArea.pressed
                    }

                    MouseArea {
                        id: seekArea

                        anchors.fill: parent
                        anchors.margins: -8
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor

                        function seek(mouseX: real): void {
                            const player = Services.Media.player;
                            if (!player || !player.canSeek) {
                                return;
                            }
                            const ratio = Math.max(0, Math.min(1, mouseX / seekTrack.width));
                            player.position = ratio * Services.Media.trackLength;
                        }

                        onPressed: mouse => seek(mouse.x)
                        onPositionChanged: mouse => {
                            if (pressed) {
                                seek(mouse.x);
                            }
                        }
                    }
                }

                // Controls
                RowLayout {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 12

                    MouseArea {
                        id: prevButton

                        Layout.preferredWidth: 36
                        Layout.preferredHeight: 36
                        enabled: Services.Media.canGoPrevious
                        hoverEnabled: true
                        cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                        onClicked: Services.Media.previous()

                        Rectangle {
                            anchors.fill: parent
                            radius: width / 2
                            color: Theme.withAlpha(Theme.fg, prevButton.containsMouse && prevButton.enabled ? 0.12 : 0)

                            Behavior on color {
                                ColorAnimation {
                                    duration: 140
                                }
                            }
                        }

                        RemixIcon {
                            anchors.centerIn: parent
                            name: "skip-back-fill"
                            size: 18
                            color: prevButton.enabled ? Theme.fg : Theme.withAlpha(Theme.fg, 0.35)
                        }
                    }

                    MouseArea {
                        id: playButton

                        Layout.preferredWidth: 44
                        Layout.preferredHeight: 44
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Services.Media.togglePlaying()

                        Rectangle {
                            anchors.fill: parent
                            radius: width / 2
                            color: Theme.withAlpha(root.baseColor, playButton.containsMouse ? 0.30 : 0.20)

                            Behavior on color {
                                ColorAnimation {
                                    duration: 140
                                }
                            }
                        }

                        RemixIcon {
                            anchors.centerIn: parent
                            name: Services.Media.isPlaying ? "pause-fill" : "play-fill"
                            size: 20
                            color: Theme.fg
                        }
                    }

                    MouseArea {
                        id: nextButton

                        Layout.preferredWidth: 36
                        Layout.preferredHeight: 36
                        enabled: Services.Media.canGoNext
                        hoverEnabled: true
                        cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                        onClicked: Services.Media.next()

                        Rectangle {
                            anchors.fill: parent
                            radius: width / 2
                            color: Theme.withAlpha(Theme.fg, nextButton.containsMouse && nextButton.enabled ? 0.12 : 0)

                            Behavior on color {
                                ColorAnimation {
                                    duration: 140
                                }
                            }
                        }

                        RemixIcon {
                            anchors.centerIn: parent
                            name: "skip-forward-fill"
                            size: 18
                            color: nextButton.enabled ? Theme.fg : Theme.withAlpha(Theme.fg, 0.35)
                        }
                    }
                }
            }
        }

        // Keep the popup open while the pointer is over it.
        HoverHandler {
            id: popupHoverHandler
            onHoveredChanged: root.popupHovered = hovered
        }
    }
}
