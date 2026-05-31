pragma ComponentBehavior: Bound

import QtQuick
import qs.Commons
import qs.Services as Services

Item {
    id: root

    property bool active: true
    property string type: "mirrored"
    property int spectrumBandCount: 32
    property real minimumLevel: 0.04
    property color fillColor: Theme.withAlpha(Theme.blue, 0.35)

    readonly property string componentId: "bar:media:visualizer"
    readonly property bool needsSpectrum: visible && active
    readonly property bool mirrored: type === "mirrored"
    readonly property var values: Services.Spectrum.values
    readonly property int valuesCount: values && values.length !== undefined ? values.length : 0
    readonly property int sourceCount: valuesCount > 0 ? valuesCount : spectrumBandCount
    readonly property int totalBars: mirrored ? sourceCount * 2 : sourceCount

    opacity: active ? 1 : 0.25

    onNeedsSpectrumChanged: {
        if (needsSpectrum) {
            Services.Spectrum.bandCount = spectrumBandCount;
            Services.Spectrum.registerComponent(componentId);
            return;
        }
        Services.Spectrum.unregisterComponent(componentId);
    }

    onSpectrumBandCountChanged: {
        if (needsSpectrum) {
            Services.Spectrum.bandCount = spectrumBandCount;
        }
    }

    Component.onCompleted: {
        if (needsSpectrum) {
            Services.Spectrum.bandCount = spectrumBandCount;
            Services.Spectrum.registerComponent(componentId);
        }
    }

    Component.onDestruction: {
        Services.Spectrum.unregisterComponent(componentId);
    }

    Repeater {
        model: root.totalBars

        Rectangle {
            required property int index

            readonly property int valueIndex: root.mirrored ? (index < root.sourceCount ? root.sourceCount - 1 - index : index - root.sourceCount) : index
            readonly property real rawLevel: root.values[valueIndex] ?? 0
            readonly property real level: Math.min(1, Math.max(root.minimumLevel, rawLevel))
            readonly property real slotWidth: root.totalBars > 0 ? root.width / root.totalBars : 0

            width: Math.max(2, slotWidth * 0.55)
            height: Math.max(2, root.height * level)
            x: index * slotWidth + ((slotWidth - width) / 2)
            y: root.mirrored ? (root.height - height) / 2 : root.height - height
            radius: width / 2
            color: root.fillColor

            Behavior on height {
                NumberAnimation {
                    duration: 90
                    easing.type: Easing.OutQuad
                }
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
