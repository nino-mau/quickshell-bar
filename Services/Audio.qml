pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

Singleton {
    id: root

    property list<PwNode> sinks: []
    property list<PwNode> sources: []

    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property PwNode source: Pipewire.defaultAudioSource
    readonly property bool muted: !!sink?.audio?.muted
    readonly property real volume: sink?.audio?.volume ?? 0
    readonly property int volumePercent: Math.round(volume * 100)
    readonly property string volumeText: volumePercent + '%'

    readonly property real step: 0.05
    readonly property real maxVolume: 1.0

    function setVolume(value: real): void {
        if (!sink?.ready || !sink?.audio)
            return;

        sink.audio.muted = false;
        sink.audio.volume = Math.max(0, Math.min(root.maxVolume, value));
    }

    function incrementVolume(): void {
        setVolume(volume + step);
    }

    function decrementVolume(): void {
        setVolume(volume - step);
    }

    function toggleMuted(): void {
        if (!sink?.ready || !sink?.audio)
            return;

        sink.audio.muted = !sink.audio.muted;
    }

    function setSink(node: PwNode): void {
        Pipewire.preferredDefaultAudioSink = node;
    }

    function cycleNextSink(): void {
        if (sinks.length === 0)
            return;

        const currentIndex = sinks.findIndex(node => node === sink);
        const nextIndex = (currentIndex + 1) % sinks.length;
        setSink(sinks[nextIndex]);
    }

    function updateDevices(): void {
        const nextSinks = [];
        const nextSources = [];

        for (const node of Pipewire.nodes.values) {
            if (node.isStream || !node.audio)
                continue;

            if (node.isSink)
                nextSinks.push(node);
            else
                nextSources.push(node);
        }

        root.sinks = nextSinks;
        root.sources = nextSources;
    }

    function getVolumeText(): string {
        return volumePercent + '%';
    }

    Component.onCompleted: updateDevices()

    Connections {
        target: Pipewire.nodes

        function onValuesChanged(): void {
            root.updateDevices();
        }
    }

    PwObjectTracker {
        objects: [root.sink, root.source, ...root.sinks, ...root.sources]
    }
}
