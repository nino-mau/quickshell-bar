pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.UPower

Singleton {
    id: root

    readonly property var device: UPower.displayDevice
    // A desktop without a battery still exposes a display device, so gate the
    // widget on a present laptop battery rather than the device merely existing.
    readonly property bool available: device?.ready && device?.isLaptopBattery && device?.isPresent
    readonly property real percentage: device?.percentage ?? 0
    readonly property int state: device?.state ?? UPowerDeviceState.Unknown
    readonly property bool charging: state === UPowerDeviceState.Charging || state === UPowerDeviceState.PendingCharge
    readonly property bool full: state === UPowerDeviceState.FullyCharged
    readonly property bool low: !charging && percentage <= 0.20
    // Seconds until empty/full; 0 means UPower has no estimate yet.
    readonly property real timeToEmpty: device?.timeToEmpty ?? 0
    readonly property real timeToFull: device?.timeToFull ?? 0

    readonly property string displayPercentage: Math.round(percentage * 100) + "%"
    readonly property string displayTime: formatTime(charging ? timeToFull : timeToEmpty)

    function formatTime(seconds: real): string {
        if (seconds <= 0) {
            return "";
        }

        const totalMinutes = Math.round(seconds / 60);
        const hours = Math.floor(totalMinutes / 60);
        const minutes = totalMinutes % 60;

        if (hours > 0) {
            return hours + "h " + minutes + "m";
        }
        return minutes + "m";
    }
}
