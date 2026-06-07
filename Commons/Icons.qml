pragma Singleton

import Quickshell

Singleton {
    readonly property var icons: ({
            launcher: "rocket_launch",
            settings: "settings",
            power: "power_settings_new",
            volumeHigh: "volume_up",
            volumeMedium: "volume_down",
            volumeLow: "volume_mute",
            volumeMuted: "no_sound",
            wifiStrength4: "network_wifi",
            wifiStrength3: "network_wifi_3_bar",
            wifiStrength2: "network_wifi_2_bar",
            wifiStrength1: "network_wifi_1_bar",
            wifiStrengthOff: "signal_wifi_off",
            mediaPause: "pause",
            mediaPlay: "play_arrow",
            mediaNext: "skip_next",
            mediaPrev: "skip_previous",
            memory: "memory",
            cpuTemp: "device_thermostat",
            cpuPerc: "speed",
            bluetoothOn: "bluetooth",
            bluetoothOff: "bluetooth_disabled",
            bluetoothSettings: "settings_bluetooth",
            weatherAlert: "cloud",
            weatherSunny: "clear_day",
            weatherNight: "moon_stars",
            weatherPartlyCloudy: "partly_cloudy_day",
            weatherCloudy: "cloud",
            weatherFog: "foggy",
            weatherRainy: "rainy",
            weatherPouring: "rainy_heavy",
            weatherSnowy: "weather_snowy",
            weatherLightning: "thunderstorm",
            weatherHail: "weather_hail"
        })

    function get(name) {
        if (!name) {
            return "";
        }

        return icons[name] || name;
    }
}
