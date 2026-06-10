pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Networking

Singleton {
    id: root

    readonly property var wifiDevice: findWifiDevice()
    readonly property var activeWifiNetwork: findActiveWifiNetwork()
    readonly property bool wifiAvailable: wifiDevice !== null
    readonly property bool wifiEnabled: Networking.wifiHardwareEnabled && Networking.wifiEnabled
    readonly property bool connected: activeWifiNetwork !== null
    readonly property string networkName: activeWifiNetwork?.name ?? ""
    readonly property real signalStrength: activeWifiNetwork?.signalStrength ?? 0

    function findWifiDevice(): var {
        const devices = Networking.devices.values;
        let firstWifiDevice = null;

        for (const device of devices) {
            if (device?.type !== DeviceType.Wifi) {
                continue;
            }

            if (firstWifiDevice === null) {
                firstWifiDevice = device;
            }

            if (device.connected) {
                return device;
            }
        }

        return firstWifiDevice;
    }

    function findActiveWifiNetwork(): var {
        if (wifiDevice === null) {
            return null;
        }

        for (const network of wifiDevice.networks.values) {
            if (network?.connected) {
                return network;
            }
        }

        return null;
    }
}
