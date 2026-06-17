pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons

Singleton {
    id: root

    // Number of cava bars, fixed by bar orientation: a slim 3-band visual on a
    // vertical bar, a wide 30-band one on a horizontal bar. Authoritative here
    // so nothing else can clobber the generated config.
    property int verticalBandCount: 3
    property int horizontalBandCount: 20
    readonly property int bandCount: Config.vertical ? verticalBandCount : horizontalBandCount
    property var values: []
    property bool idle: true
    property var registrations: ({})
    property bool processRunning: false

    readonly property bool enabled: Object.keys(registrations).length > 0
    readonly property int normalizedBandCount: Math.max(1, Math.round(bandCount))
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

        const nextValues = text.split(";").filter(value => value.length > 0).map(value => Math.min(1, Math.max(0, Number(value) / 1000)));

        if (nextValues.length === 0) {
            return;
        }

        values = nextValues;
        idle = nextValues.every(value => value <= 0);
    }

    function configText(): string {
        return ["[general]", "bars = " + normalizedBandCount, "framerate = 30", "autosens = 1", "lower_cutoff_freq = 50", "higher_cutoff_freq = 12000", "", "[input]", "method = pipewire", "source = auto", "channels = 1", "", "[output]", "method = raw", "raw_target = /dev/stdout", "data_format = ascii", "ascii_max_range = 1000", "bar_delimiter = 59", "frame_delimiter = 10", "", "[smoothing]", "noise_reduction = 77", ""].join("\n");
    }

    function writeConfig(): void {
        configFile.setText(configText());
    }

    function startIfEnabled(): void {
        if (enabled) {
            processRunning = true;
        }
    }

    function restart(): void {
        processRunning = false;
        values = [];
        idle = true;
        writeConfig();
        Qt.callLater(startIfEnabled);
    }

    onEnabledChanged: {
        if (enabled) {
            restart();
            return;
        }

        processRunning = false;
        values = [];
        idle = true;
    }

    onBandCountChanged: {
        if (enabled) {
            restart();
            return;
        }

        writeConfig();
    }

    Component.onCompleted: writeConfig()

    FileView {
        id: configFile

        path: root.configPath
        printErrors: false
    }

    Process {
        id: cavaProcess

        command: ["cava", "-p", root.configPath]
        running: root.processRunning

        stdout: SplitParser {
            onRead: data => root.parseFrame(data)
        }

        onExited: {
            root.values = [];
            root.idle = true;
        }
    }
}
