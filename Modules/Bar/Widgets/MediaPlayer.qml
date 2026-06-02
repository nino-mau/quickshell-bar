pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import qs.Commons
import qs.Services as Services

MouseArea {
    id: root

    readonly property bool hasMedia: Services.Media.displayText.length > 0
    // Interval at which the displayed title will change (alternate between title and artist)
    readonly property int mediaTitleChangeInterval: 15000

    // Style propreties

    readonly property int horizontalPadding: Tokens.space10
    readonly property int minWidth: 150

    readonly property int controlButtonSize: Tokens.textXLHalf + 1
    readonly property int controlsGap: Tokens.space2

    readonly property real audioVisualizerOpacity: 0.5
    readonly property color audioVisualizerColor: Theme.aqua

    readonly property int maxTextWidth: 150
    readonly property string titleTextSize: Tokens.textXSHalf
    readonly property string titleTextFontWeight: Tokens.fontBold

    readonly property int popupHorizontalPadding: Tokens.space4
    readonly property int popupVerticalPadding: Tokens.space2
    readonly property int popupShadowPadding: Tokens.space3
    readonly property int popupAttachOverlap: Tokens.space2
    readonly property int popupReverseRadius: Style.radiusDefault
    readonly property url popupImageSource: Services.Media.artUrl
    readonly property color popupBackgroundColor: Theme.bg1
    readonly property color popupBorderColor: 'transparent'

    implicitWidth: hasMedia ? pill.implicitWidth : 0
    implicitHeight: Style.barHeight
    acceptedButtons: Qt.LeftButton
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    visible: hasMedia

    onHasMediaChanged: {
        if (!hasMedia) {
            controlsPopup.close();
        }
    }

    onClicked: controlsPopup.toggle()

    // Media pill
    Rectangle {
        id: pill

        readonly property real textWidth: Math.min(Math.max(titleMetrics.width, artistMetrics.width), root.maxTextWidth) + root.horizontalPadding * 2
        readonly property real preferredWidth: Math.max(root.minWidth, textWidth)

        anchors.centerIn: parent
        implicitWidth: preferredWidth
        implicitHeight: Style.pillSize
        radius: Style.pillRadius
        color: Theme.withAlpha(Theme.aqua, 0.15)
        // color: 'transparent'
        clip: true

        // Media audio visualizer in background
        AudioVisualizer {
            anchors.fill: parent
            anchors.margins: Tokens.space1
            active: Services.Media.isPlaying
            colorOpacity: root.audioVisualizerOpacity
            barColor: root.audioVisualizerColor
        }

        // Media title
        Item {
            anchors.fill: parent
            anchors.leftMargin: root.horizontalPadding
            anchors.rightMargin: root.horizontalPadding

            Item {
                id: titleClip

                anchors.fill: parent

                readonly property bool hasTitleText: Services.Media.title.length > 0
                readonly property bool hasArtistText: Services.Media.artist.length > 0
                readonly property bool canAlternate: hasTitleText && hasArtistText && Services.Media.title !== Services.Media.artist
                readonly property bool textVisible: root.hasMedia
                readonly property string firstText: hasTitleText ? Services.Media.title : Services.Media.artist
                readonly property string secondText: hasArtistText ? Services.Media.artist : Services.Media.title
                readonly property real scrollDistance: Math.max(0, currentMediaText.implicitWidth - width)
                readonly property int scrollPixelsPerSecond: 30
                readonly property int scrollDuration: Math.round(scrollDistance / scrollPixelsPerSecond * 1000)
                readonly property bool overflowing: scrollDistance > 0
                property bool showingFirstText: true
                property real scrollOffset: 0
                property real slideProgress: 0
                property string currentText: firstText
                property string nextText: ""

                clip: true
                opacity: textVisible ? 1 : 0

                onCanAlternateChanged: resetText()
                onFirstTextChanged: resetText()
                onOverflowingChanged: scrollOffset = 0
                onSecondTextChanged: resetText()
                onTextVisibleChanged: scrollOffset = 0
                onWidthChanged: scrollOffset = 0

                function resetText(): void {
                    textSlideAnimation.stop();
                    showingFirstText = true;
                    currentText = firstText;
                    nextText = "";
                    slideProgress = 0;
                    scrollOffset = 0;
                }

                function showNextText(): void {
                    if (!canAlternate || textSlideAnimation.running) {
                        return;
                    }

                    nextText = showingFirstText ? secondText : firstText;
                    showingFirstText = !showingFirstText;
                    slideProgress = 0;
                    scrollOffset = 0;
                    textSlideAnimation.start();
                }

                TextMetrics {
                    id: titleMetrics

                    text: Services.Media.title
                    font.family: Style.defaultFontFamily
                    font.pixelSize: root.titleTextSize
                    font.weight: root.titleTextFontWeight
                }

                TextMetrics {
                    id: artistMetrics

                    text: Services.Media.artist
                    font.family: Style.defaultFontFamily
                    font.pixelSize: root.titleTextSize
                    font.weight: root.titleTextFontWeight
                }

                Text {
                    id: currentMediaText

                    x: titleClip.overflowing ? -titleClip.scrollOffset : (titleClip.width - implicitWidth) / 2
                    y: (titleClip.height - implicitHeight) / 2 + titleClip.slideProgress * titleClip.height
                    text: titleClip.currentText
                    color: Style.pillText
                    font.family: Style.defaultFontFamily
                    font.pixelSize: root.titleTextSize
                    font.weight: root.titleTextFontWeight
                }

                Text {
                    id: nextMediaText

                    visible: textSlideAnimation.running
                    x: implicitWidth > titleClip.width ? 0 : (titleClip.width - implicitWidth) / 2
                    y: (titleClip.height - implicitHeight) / 2 - (1 - titleClip.slideProgress) * titleClip.height
                    text: titleClip.nextText
                    color: Style.pillText
                    font.family: Style.defaultFontFamily
                    font.pixelSize: root.titleTextSize
                    font.weight: root.titleTextFontWeight
                }

                Timer {
                    id: textSlideTimer
                    interval: root.mediaTitleChangeInterval
                    repeat: true
                    running: titleClip.canAlternate && titleClip.textVisible && root.visible

                    onTriggered: titleClip.showNextText()
                }

                // Slide animation
                SequentialAnimation {
                    id: textSlideAnimation

                    NumberAnimation {
                        target: titleClip
                        property: "slideProgress"
                        from: 0
                        to: 1
                        duration: Style.animationVerySlow + 150
                        easing.type: Easing.InOutQuad
                    }

                    ScriptAction {
                        script: {
                            titleClip.currentText = titleClip.nextText;
                            titleClip.nextText = "";
                            titleClip.slideProgress = 0;
                            titleClip.scrollOffset = 0;
                        }
                    }
                }

                Behavior on opacity {
                    NumberAnimation {
                        duration: Style.animationFast
                        easing.type: Easing.InOutQuad
                    }
                }
            }
        }

        Behavior on color {
            ColorAnimation {
                duration: Style.animationFast
                easing.type: Easing.InOutQuad
            }
        }
    }

    // Media popup
    AttachedPopupWindow {
        id: controlsPopup

        popupContentWidth: popupContent.implicitWidth + root.popupHorizontalPadding * 2
        popupContentHeight: popupContent.implicitHeight + root.popupVerticalPadding * 2
        shadowPadding: root.popupShadowPadding
        attachOverlap: root.popupAttachOverlap
        reverseRadius: root.popupReverseRadius
        backgroundColor: root.popupBackgroundColor
        borderColor: root.popupBorderColor
        anchor.item: root

        ColumnLayout {
            id: popupContent

            anchors.centerIn: parent

            // Media art
            Image {
                id: cover

                Layout.preferredWidth: 190
                Layout.preferredHeight: 108
                Layout.alignment: Qt.AlignHCenter
                source: root.popupImageSource
                sourceSize.width: 280
                sourceSize.height: 156
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                cache: false
                layer.enabled: true
                layer.smooth: true
                layer.effect: MultiEffect {
                    maskEnabled: true
                    maskThresholdMin: 0
                    maskSpreadAtMin: 0
                    maskThresholdMax: 1
                    maskSpreadAtMax: 0
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

            // Media progress bar
            Item {
                id: progressBar

                Layout.topMargin: 8
                Layout.fillWidth: true
                Layout.preferredHeight: Tokens.space1
                visible: Services.Media.hasProgress

                Rectangle {
                    anchors.fill: parent
                    radius: height / 2
                    color: Theme.withAlpha(Style.pillText, 0.16)
                }

                Rectangle {
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: parent.width * Services.Media.progress
                    radius: height / 2
                    color: Theme.aqua

                    Behavior on width {
                        NumberAnimation {
                            duration: Style.animationFast
                            easing.type: Easing.InOutQuad
                        }
                    }
                }
            }

            // Media controls
            RowLayout {
                id: controlsLayout

                Layout.topMargin: 2
                Layout.alignment: Qt.AlignHCenter
                spacing: root.controlsGap

                // Prev button
                MouseArea {
                    id: prevButton

                    Layout.preferredWidth: root.controlButtonSize
                    Layout.preferredHeight: root.controlButtonSize
                    Layout.alignment: Qt.AlignVCenter
                    enabled: Services.Media.canGoPrevious
                    hoverEnabled: true
                    cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor

                    onClicked: Services.Media.previous()

                    Text {
                        id: prevLabel

                        anchors.centerIn: parent
                        text: Icons.mediaPrevFilled
                        font.family: Style.iconFontFamily
                        font.pixelSize: root.controlButtonSize - 4
                        color: Style.pillText
                        opacity: Services.Media.canGoPrevious ? 1 : 0.35
                    }
                }

                // Pause button
                MouseArea {
                    id: pauseButton

                    Layout.preferredWidth: root.controlButtonSize
                    Layout.preferredHeight: root.controlButtonSize
                    Layout.alignment: Qt.AlignVCenter
                    enabled: Services.Media.canTogglePlaying || Services.Media.canPlay || Services.Media.canPause
                    hoverEnabled: true
                    cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor

                    onClicked: Services.Media.togglePlaying()

                    Text {
                        id: pauseLabel

                        anchors.centerIn: parent
                        text: Services.Media.isPlaying ? Icons.mediaPause : Icons.mediaPlay
                        font.family: Style.iconFontFamily
                        font.pixelSize: root.controlButtonSize
                        color: Style.pillText
                        opacity: Services.Media.canTogglePlaying || Services.Media.canPlay || Services.Media.canPause ? 1 : 0.35
                    }
                }

                // Next button
                MouseArea {
                    id: nextButton

                    Layout.preferredWidth: root.controlButtonSize
                    Layout.preferredHeight: root.controlButtonSize
                    Layout.alignment: Qt.AlignVCenter
                    enabled: Services.Media.canGoNext
                    hoverEnabled: true
                    cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor

                    onClicked: Services.Media.next()

                    Text {
                        id: nextLabel

                        anchors.centerIn: parent
                        text: Icons.mediaNextFilled
                        font.family: Style.iconFontFamily
                        font.pixelSize: root.controlButtonSize - 4
                        color: Style.pillText
                        opacity: Services.Media.canGoNext ? 1 : 0.35
                    }
                }
            }
        }
    }
}
