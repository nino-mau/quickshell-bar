pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    // Number of available package updates (repo + AUR when a helper is present).
    property int count: 0
    property string error: ""
    // True while an upgrade (pacman/paru/yay) is running on the system.
    property bool updating: false

    readonly property bool loading: updatesProcess.running
    readonly property bool hasUpdates: count > 0
    readonly property string countText: count > 99 ? "99+" : String(count)

    // How often to re-check the count, in milliseconds (default: 30 minutes).
    property int refreshInterval: 1800000
    // How often to poll for a running upgrade, in milliseconds.
    property int watchInterval: 3000

    Component.onCompleted: reload()

    function reload(): void {
        if (updatesProcess.running) {
            return;
        }
        error = "";
        updatesProcess.running = true;
    }

    function handleResponse(exitCode: int): void {
        // checkupdates exits 2 when there are no updates; treat that as zero.
        const parsed = parseInt(String(updatesProcess.stdout.text ?? "").trim(), 10);
        if (isNaN(parsed)) {
            error = cleanText(updatesProcess.stderr.text) || qsTr("Could not check updates");
            return;
        }
        count = parsed;
        error = "";
    }

    function handleWatchResponse(exitCode: int): void {
        // pgrep exits 0 when a matching process is found, 1 otherwise.
        const running = exitCode === 0;
        // When an upgrade finishes, refresh the count to reflect the result.
        if (root.updating && !running) {
            reload();
        }
        root.updating = running;
    }

    function cleanText(value: var): string {
        return String(value ?? "").replace(/(\r\n|\n|\r)/g, "").trim();
    }

    Process {
        id: updatesProcess

        // Sum repo updates (checkupdates, from pacman-contrib) with AUR updates
        // from the first available helper. Missing tools are silently skipped.
        command: ["sh", "-c", "count=$(checkupdates 2>/dev/null | wc -l); for h in paru yay; do if command -v $h >/dev/null 2>&1; then count=$((count + $($h -Qua 2>/dev/null | wc -l))); break; fi; done; echo $count"]

        stdout: StdioCollector {}
        stderr: StdioCollector {}

        onExited: code => root.handleResponse(code)
    }

    Process {
        id: watchProcess

        // Detect an upgrade by a running pacman/paru/yay process, for the whole
        // session (build, prompts, install) rather than just the brief lock window.
        // Filter out our own read-only check: `paru -Qua`/`yay -Qua` (any -Q query)
        // and checkupdates' pacman (uses a temp "checkup-db" path).
        command: ["sh", "-c", "pgrep -ax 'pacman|paru|yay' | grep -vqE 'checkup-db|[-]Q'"]

        onExited: code => root.handleWatchResponse(code)
    }

    Timer {
        interval: root.refreshInterval
        running: true
        repeat: true

        onTriggered: root.reload()
    }

    Timer {
        interval: root.watchInterval
        running: true
        repeat: true

        onTriggered: {
            if (!watchProcess.running) {
                watchProcess.running = true;
            }
        }
    }
}
