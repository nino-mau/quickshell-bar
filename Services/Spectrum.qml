pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

Singleton {
    id: root

    property int bandCount: 32
    property var values: []
    property bool idle: true
    property var registrations: ({})

    readonly property bool enabled: Object.keys(registrations).length > 0

    function registerComponent(componentId: string): void {
        registrations[componentId] = true;
        registrations = Object.assign({}, registrations);
    }

    function unregisterComponent(componentId: string): void {
        delete registrations[componentId];
        registrations = Object.assign({}, registrations);
    }

    function applyBandCount(): void {
        if (spectrum.bandCount !== undefined) {
            spectrum.bandCount = bandCount;
            return;
        }
        if (spectrum.barCount !== undefined) {
            spectrum.barCount = bandCount;
        }
    }

    onBandCountChanged: applyBandCount()
    Component.onCompleted: applyBandCount()

    PwAudioSpectrum {
        id: spectrum

        node: Pipewire.defaultAudioSink
        enabled: root.enabled
        frameRate: 30
        lowerCutoff: 50
        upperCutoff: 12000
        noiseReduction: 0.77
        smoothing: true

        onValuesChanged: root.values = spectrum.values
        onIdleChanged: root.idle = spectrum.idle
    }
}
