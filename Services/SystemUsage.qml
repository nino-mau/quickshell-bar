pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property int updateInterval: 2000
    property string manualGpuType: ""
    property var registrations: ({})

    property string cpuName: ""
    property real cpuPerc: 0
    property real cpuTemp: 0
    property real lastCpuIdle: 0
    property real lastCpuTotal: 0
    readonly property string displayCpuTemp: cpuTemp > 0 ? Math.round(cpuTemp) + "°" : "--"
    readonly property string displayCpuPerc: Math.round(cpuPerc * 100) + "%"

    readonly property string gpuType: manualGpuType.length > 0 ? manualGpuType.toUpperCase() : autoGpuType
    property string autoGpuType: "NONE"
    property string gpuName: ""
    property real gpuPerc: 0
    property real gpuTemp: 0
    readonly property string displayGpuTemp: gpuTemp > 0 ? Math.round(gpuTemp) + "°C" : "--"

    property real memUsed: 0
    property real memTotal: 0
    readonly property real memPerc: memTotal > 0 ? memUsed / memTotal : 0
    readonly property string displayMemPerc: Math.round(memPerc * 100) + "%"

    property var disks: []
    readonly property real storagePerc: {
        let totalUsed = 0;
        let totalSize = 0;

        for (const disk of disks) {
            totalUsed += disk.used;
            totalSize += disk.total;
        }

        return totalSize > 0 ? totalUsed / totalSize : 0;
    }

    readonly property bool enabled: Object.keys(registrations).length > 0

    function registerComponent(componentId: string): void {
        registrations[componentId] = true;
        registrations = Object.assign({}, registrations);
    }

    function unregisterComponent(componentId: string): void {
        delete registrations[componentId];
        registrations = Object.assign({}, registrations);
    }

    function update(): void {
        stat.reload();
        meminfo.reload();
        storage.running = true;
        gpuUsage.running = true;
        sensors.running = true;
    }

    function cleanCpuName(name: string): string {
        return name.replace(/\(R\)|\(TM\)|CPU|\d+(?:th|nd|rd|st) Gen |Core |Processor/gi, "").replace(/\s+/g, " ").trim();
    }

    function cleanGpuName(name: string): string {
        return name.replace(/\(R\)|\(TM\)|Graphics|Corporation|Integrated/gi, "").replace(/\s+/g, " ").trim();
    }

    function formatKib(kib: real): var {
        const mib = 1024;
        const gib = 1024 ** 2;
        const tib = 1024 ** 3;

        if (kib >= tib) {
            return {
                value: kib / tib,
                unit: "TiB"
            };
        }
        if (kib >= gib) {
            return {
                value: kib / gib,
                unit: "GiB"
            };
        }
        if (kib >= mib) {
            return {
                value: kib / mib,
                unit: "MiB"
            };
        }
        return {
            value: kib,
            unit: "KiB"
        };
    }

    onEnabledChanged: {
        if (enabled) {
            update();
        }
    }

    FileView {
        id: cpuinfo

        path: "/proc/cpuinfo"

        onLoaded: {
            const match = text().match(/model name\s*:\s*(.+)/);
            if (match) {
                root.cpuName = root.cleanCpuName(match[1]);
            }
        }
    }

    FileView {
        id: stat

        path: "/proc/stat"

        onLoaded: {
            const match = text().match(/^cpu\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)/);
            if (!match) {
                return;
            }

            const stats = match.slice(1).map(value => parseInt(value, 10));
            const total = stats.reduce((sum, value) => sum + value, 0);
            const idle = stats[3] + (stats[4] ?? 0);

            if (root.lastCpuTotal > 0) {
                const totalDiff = total - root.lastCpuTotal;
                const idleDiff = idle - root.lastCpuIdle;
                root.cpuPerc = totalDiff > 0 ? Math.max(0, Math.min(1, 1 - idleDiff / totalDiff)) : 0;
            }

            root.lastCpuTotal = total;
            root.lastCpuIdle = idle;
        }
    }

    FileView {
        id: meminfo

        path: "/proc/meminfo"

        onLoaded: {
            const data = text();
            const totalMatch = data.match(/MemTotal:\s*(\d+)/);
            const availableMatch = data.match(/MemAvailable:\s*(\d+)/);

            if (!totalMatch || !availableMatch) {
                return;
            }

            root.memTotal = parseInt(totalMatch[1], 10) || 0;
            root.memUsed = root.memTotal - (parseInt(availableMatch[1], 10) || 0);
        }
    }

    Process {
        id: storage

        command: ["lsblk", "-J", "-b", "-o", "NAME,SIZE,TYPE,FSUSED,FSSIZE,MOUNTPOINT"]

        stdout: StdioCollector {
            onStreamFinished: {
                let data = null;
                try {
                    data = JSON.parse(text);
                } catch (exception) {
                    root.disks = [];
                    return;
                }

                const diskList = [];
                const seenDevices = new Set();

                const aggregateUsage = dev => {
                    let used = 0;
                    let size = 0;
                    let hasRoot = dev.mountpoint === "/";

                    if (!seenDevices.has(dev.name)) {
                        used = parseInt(dev.fsused) || 0;
                        size = parseInt(dev.fssize) || 0;
                        seenDevices.add(dev.name);
                    }

                    if (dev.children) {
                        for (const child of dev.children) {
                            const stats = aggregateUsage(child);
                            used += stats.used;
                            size += stats.size;
                            hasRoot = hasRoot || stats.hasRoot;
                        }
                    }

                    return {
                        used,
                        size,
                        hasRoot
                    };
                };

                for (const dev of data.blockdevices ?? []) {
                    if (dev.type !== "disk" || dev.name.startsWith("zram")) {
                        continue;
                    }

                    const stats = aggregateUsage(dev);
                    if (stats.size === 0) {
                        continue;
                    }

                    diskList.push({
                        mount: dev.name,
                        used: stats.used / 1024,
                        total: stats.size / 1024,
                        free: (stats.size - stats.used) / 1024,
                        perc: stats.size > 0 ? stats.used / stats.size : 0,
                        hasRoot: stats.hasRoot
                    });
                }

                root.disks = diskList.sort((a, b) => {
                    if (a.hasRoot && !b.hasRoot) {
                        return -1;
                    }
                    if (!a.hasRoot && b.hasRoot) {
                        return 1;
                    }
                    return a.mount.localeCompare(b.mount);
                });
            }
        }
    }

    Process {
        id: gpuTypeCheck

        running: true
        command: ["sh", "-c", "if command -v nvidia-smi >/dev/null 2>&1 && nvidia-smi -L >/dev/null 2>&1; then echo NVIDIA; elif ls /sys/class/drm/card*/device/gpu_busy_percent >/dev/null 2>&1; then echo GENERIC; else echo NONE; fi"]

        stdout: StdioCollector {
            onStreamFinished: root.autoGpuType = text.trim()
        }
    }

    Process {
        id: gpuNameDetect

        running: true
        command: ["sh", "-c", "nvidia-smi --query-gpu=name --format=csv,noheader 2>/dev/null || lspci 2>/dev/null | grep -i 'vga\\|3d controller\\|display' | head -1 || true"]

        stdout: StdioCollector {
            onStreamFinished: {
                const output = text.trim();
                if (output.length === 0) {
                    return;
                }

                const bracketMatch = output.match(/\[([^\]]+)\][^\[]*$/);
                const colonMatch = output.match(/:\s*(.+)/);
                root.gpuName = root.cleanGpuName(bracketMatch ? bracketMatch[1] : colonMatch ? colonMatch[1] : output);
            }
        }
    }

    Process {
        id: gpuUsage

        command: root.gpuType === "GENERIC" ? ["sh", "-c", "cat /sys/class/drm/card*/device/gpu_busy_percent 2>/dev/null || true"] : root.gpuType === "NVIDIA" ? ["nvidia-smi", "--query-gpu=utilization.gpu,temperature.gpu", "--format=csv,noheader,nounits"] : ["sh", "-c", "true"]

        stdout: StdioCollector {
            onStreamFinished: {
                if (root.gpuType === "GENERIC") {
                    const values = text.trim().split("\n").filter(value => value.length > 0).map(value => parseInt(value, 10)).filter(value => !isNaN(value));
                    const sum = values.reduce((total, value) => total + value, 0);
                    root.gpuPerc = values.length > 0 ? sum / values.length / 100 : 0;
                    return;
                }

                if (root.gpuType === "NVIDIA") {
                    const parts = text.trim().split(",");
                    root.gpuPerc = Math.max(0, Math.min(1, (parseInt(parts[0], 10) || 0) / 100));
                    root.gpuTemp = parseInt(parts[1], 10) || 0;
                    return;
                }

                root.gpuPerc = 0;
                root.gpuTemp = 0;
            }
        }
    }

    Process {
        id: sensors

        command: ["sh", "-c", "command -v sensors >/dev/null 2>&1 && sensors || true"]
        environment: ({
                LANG: "C.UTF-8",
                LC_ALL: "C.UTF-8"
            })

        stdout: StdioCollector {
            onStreamFinished: {
                let cpuTemp = text.match(/(?:Package id [0-9]+|Tdie|Tctl):\s+((\+|-)[0-9.]+)(°| )C/);
                if (cpuTemp) {
                    root.cpuTemp = parseFloat(cpuTemp[1]);
                }

                if (root.gpuType !== "GENERIC") {
                    return;
                }

                let eligible = false;
                let sum = 0;
                let count = 0;

                for (const line of text.trim().split("\n")) {
                    if (line === "Adapter: PCI adapter") {
                        eligible = true;
                    } else if (line === "") {
                        eligible = false;
                    } else if (eligible) {
                        const match = line.match(/^(temp[0-9]+|GPU core|edge|junction|mem):\s+\+([0-9]+\.[0-9]+)(°| )C/);
                        if (match) {
                            sum += parseFloat(match[2]);
                            count++;
                        }
                    }
                }

                root.gpuTemp = count > 0 ? sum / count : root.gpuTemp;
            }
        }
    }

    Timer {
        interval: root.updateInterval
        running: root.enabled
        repeat: true
        triggeredOnStart: true

        onTriggered: root.update()
    }
}
