pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Bluetooth

Singleton {
    id: root

    readonly property bool bluetoothAvailable: Bluetooth.defaultAdapter !== null
    readonly property bool enabled: Bluetooth.defaultAdapter?.enabled ?? false
    readonly property bool blocked: Bluetooth.defaultAdapter?.state === BluetoothAdapterState.Blocked
    readonly property bool busy: Bluetooth.defaultAdapter?.state === BluetoothAdapterState.Enabling || Bluetooth.defaultAdapter?.state === BluetoothAdapterState.Disabling
    readonly property bool discovering: Bluetooth.defaultAdapter?.discovering ?? false
    readonly property bool discoverable: Bluetooth.defaultAdapter?.discoverable ?? false
    readonly property bool connected: connectedDevices.length > 0
    readonly property var devices: deviceSnapshots()
    readonly property var connectedDevices: devices.filter(device => device.connected)
    readonly property var pairedDevices: devices.filter(device => device.paired)
    readonly property var activeDevice: connectedDevices.length > 0 ? connectedDevices[0] : null
    readonly property string activeDeviceName: deviceName(activeDevice)

    function deviceSnapshots(): var {
        const adapter = Bluetooth.defaultAdapter;
        if (!adapter)
            return [];

        return adapter.devices.values.map(device => ({
                    address: device.address,
                    name: deviceName(device),
                    icon: device.icon || "",
                    state: device.state,
                    connected: device.connected,
                    paired: device.paired,
                    bonded: device.bonded,
                    pairing: device.pairing,
                    trusted: device.trusted,
                    blocked: device.blocked,
                    batteryAvailable: device.batteryAvailable,
                    battery: device.batteryAvailable ? device.battery : 0
                }));
    }

    function isDeviceAudio(params) {
        const icon = activeDevice?.icon ?? "";
        return icon.includes("audio") || icon.includes("headset") || icon.includes("headphone") || icon.includes("speaker");
    }

    function deviceName(device: var): string {
        if (!device)
            return "";

        return device.name || device.deviceName || device.address || "";
    }

    function isDeviceBusy(device: var): bool {
        if (!device)
            return false;

        return device.pairing || device.state === BluetoothDeviceState.Connecting || device.state === BluetoothDeviceState.Disconnecting;
    }
}
