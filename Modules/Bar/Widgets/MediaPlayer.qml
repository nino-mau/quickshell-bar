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
            mediaPopup.toggle();
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
        contentWidth: 224
        contentHeight: popupBody.implicitHeight + popupPadding * 2

        ColumnLayout {
            id: popupBody

            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: mediaPopup.popupPadding
            spacing: 9

            // Album art
            Item {
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 196
                Layout.preferredHeight: 110

                Rectangle {
                    anchors.fill: parent
                    radius: Tokens.radiusLG
                    color: Theme.bg2

                    RemixIcon {
                        anchors.centerIn: parent
                        name: "music-line"
                        size: 36
                        color: Theme.withAlpha(Theme.fg, 0.5)
                    }
                }

                Image {
                    id: cover

                    anchors.fill: parent
                    source: Services.Media.artUrl
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
                                radius: Tokens.radiusLG
                                color: "white"
                            }
                        }
                    }
                }
            }

            // Title
            Text {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                text: Services.Media.title.length > 0 ? Services.Media.title : qsTr("Nothing playing")
                color: Theme.fg
                font.pixelSize: Tokens.textSM
                font.weight: Tokens.fontBold
                elide: Text.ElideRight
            }

            // Artist
            Text {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                visible: Services.Media.artist.length > 0
                text: Services.Media.artist
                color: Theme.withAlpha(Theme.fg, 0.7)
                font.pixelSize: Tokens.textXS
                font.weight: Tokens.fontMedium
                elide: Text.ElideRight
            }

            // Progress bar
            Item {
                Layout.fillWidth: true
                Layout.topMargin: 2
                Layout.preferredHeight: 4
                visible: Services.Media.hasProgress

                Rectangle {
                    anchors.fill: parent
                    radius: height / 2
                    color: Theme.withAlpha(Theme.fg, 0.16)
                }

                Rectangle {
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: parent.width * Services.Media.progress
                    radius: height / 2
                    color: Theme.blue

                    Behavior on width {
                        NumberAnimation {
                            duration: 200
                            easing.type: Easing.InOutQuad
                        }
                    }
                }
            }

            // Controls
            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: 2
                spacing: 16

                MouseArea {
                    id: prevButton

                    Layout.preferredWidth: 28
                    Layout.preferredHeight: 28
                    enabled: Services.Media.canGoPrevious
                    hoverEnabled: true
                    cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                    onClicked: Services.Media.previous()

                    RemixIcon {
                        anchors.centerIn: parent
                        name: "skip-back-line"
                        size: 18
                        color: prevButton.enabled ? Theme.fg : Theme.withAlpha(Theme.fg, 0.35)
                    }
                }

                MouseArea {
                    id: playButton

                    Layout.preferredWidth: 36
                    Layout.preferredHeight: 36
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Services.Media.togglePlaying()

                    Rectangle {
                        anchors.fill: parent
                        radius: width / 2
                        color: Theme.withAlpha(Theme.fg, playButton.containsMouse ? 0.16 : 0.10)

                        Behavior on color {
                            ColorAnimation {
                                duration: 140
                                easing.type: Easing.InOutQuad
                            }
                        }
                    }

                    RemixIcon {
                        anchors.centerIn: parent
                        name: Services.Media.isPlaying ? "pause-fill" : "play-fill"
                        size: 18
                        color: Theme.fg
                    }
                }

                MouseArea {
                    id: nextButton

                    Layout.preferredWidth: 28
                    Layout.preferredHeight: 28
                    enabled: Services.Media.canGoNext
                    hoverEnabled: true
                    cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                    onClicked: Services.Media.next()

                    RemixIcon {
                        anchors.centerIn: parent
                        name: "skip-forward-line"
                        size: 18
                        color: nextButton.enabled ? Theme.fg : Theme.withAlpha(Theme.fg, 0.35)
                    }
                }
            }
        }
    }
}
