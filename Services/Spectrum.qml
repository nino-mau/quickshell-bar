pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property int bandCount: 30
    property var values: []
    property bool idle: true
    property var registrations: ({})

    readonly property bool enabled: Object.keys(registrations).length > 0
    readonly property string configPath: Quickshell.shellDir + "/Services/cava-spectrum.ini"

    function registerComponent(componentId: string): void {
        registrations[componentId] = true;
        registrations = Object.assign({}, registrations);
    }

    function unregisterComponent(componentId: string): void {
        delete registrations[componentId];
        registrations = Object.assign({}, registrations);
    }

    function parseFrame(frame: string): void {
        const text = frame.trim();
        if (text.length === 0) {
            return;
        }

        const nextValues = text.split(";")
            .filter(value => value.length > 0)
            .map(value => Math.min(1, Math.max(0, Number(value) / 1000)));

        if (nextValues.length === 0) {
            return;
        }

        values = nextValues;
        idle = nextValues.every(value => value <= 0);
    }

    onEnabledChanged: {
        if (!enabled) {
            values = [];
            idle = true;
        }
    }

    Process {
        command: ["cava", "-p", root.configPath]
        running: root.enabled

        stdout: SplitParser {
            onRead: data => root.parseFrame(data)
        }

        onExited: {
            root.values = [];
            root.idle = true;
        }
    }
}
