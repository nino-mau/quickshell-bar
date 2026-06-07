pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons as Commons

Singleton {
    id: root

    property string loc: ""
    property int weatherCode: -1
    property bool isDay: true
    property int temperatureC: 0
    property string error: ""

    readonly property bool loading: locationProcess.running || weatherProcess.running
    readonly property bool hasWeather: weatherCode >= 0
    readonly property string icon: hasWeather ? weatherIcon(weatherCode, isDay) : Commons.Icons.get("weatherAlert")
    readonly property string temperatureText: hasWeather ? temperatureC + "°C" : "--"
    readonly property string temperatureTextSimple: hasWeather ? temperatureC + "°" : "--"

    Component.onCompleted: reload()

    function reload(): void {
        error = "";
        locationProcess.command = ["curl", "--fail", "--silent", "--show-error", "--location", "--max-time", "12", "https://ipinfo.io/json"];
        locationProcess.running = true;
    }

    function fetchWeather(): void {
        if (!isCoords(loc)) {
            return;
        }

        const parts = loc.split(",").map(part => part.trim());
        const params = ["latitude=" + parts[0], "longitude=" + parts[1], "current=temperature_2m,is_day,weather_code", "timezone=auto"];

        weatherProcess.command = ["curl", "--fail", "--silent", "--show-error", "--location", "--max-time", "12", "https://api.open-meteo.com/v1/forecast?" + params.join("&")];
        weatherProcess.running = true;
    }

    function handleLocationResponse(exitCode: int): void {
        if (exitCode !== 0) {
            error = cleanText(locationProcess.stderr.text) || qsTr("Could not fetch location");
            return;
        }

        try {
            const response = JSON.parse(String(locationProcess.stdout.text ?? ""));
            if (!response.loc || !isCoords(response.loc)) {
                error = qsTr("Could not resolve location");
                return;
            }

            loc = response.loc;
            fetchWeather();
        } catch (exception) {
            error = qsTr("Location response was invalid");
        }
    }

    function handleWeatherResponse(exitCode: int): void {
        if (exitCode !== 0) {
            error = cleanText(weatherProcess.stderr.text) || qsTr("Could not fetch weather");
            return;
        }

        try {
            const response = JSON.parse(String(weatherProcess.stdout.text ?? ""));
            if (!response.current) {
                error = qsTr("Weather response was incomplete");
                return;
            }

            weatherCode = response.current.weather_code;
            isDay = response.current.is_day === 1;
            temperatureC = Math.round(response.current.temperature_2m);
            error = "";
        } catch (exception) {
            error = qsTr("Weather response was invalid");
        }
    }

    function weatherIcon(code: int, day: bool): string {
        if (code === 0 || code === 1) {
            return Commons.Icons.get(day ? "weatherSunny" : "weatherNight");
        }
        if (code === 2) {
            return Commons.Icons.get("weatherPartlyCloudy");
        }
        if (code === 3) {
            return Commons.Icons.get("weatherCloudy");
        }
        if (code === 45 || code === 48) {
            return Commons.Icons.get("weatherFog");
        }
        if ((code >= 51 && code <= 67) || (code >= 80 && code <= 82)) {
            return Commons.Icons.get(code >= 65 || code === 82 ? "weatherPouring" : "weatherRainy");
        }
        if ((code >= 71 && code <= 77) || code === 85 || code === 86) {
            return Commons.Icons.get("weatherSnowy");
        }
        if (code === 95) {
            return Commons.Icons.get("weatherLightning");
        }
        if (code === 96 || code === 99) {
            return Commons.Icons.get("weatherHail");
        }
        return Commons.Icons.get("weatherAlert");
    }

    function isCoords(value: string): bool {
        const parts = value.split(",");
        if (parts.length !== 2) {
            return false;
        }

        const lat = Number(parts[0].trim());
        const lon = Number(parts[1].trim());
        return !isNaN(lat) && !isNaN(lon);
    }

    function cleanText(value: var): string {
        return String(value ?? "").replace(/(\r\n|\n|\r)/g, "").trim();
    }

    Process {
        id: locationProcess

        stdout: StdioCollector {}
        stderr: StdioCollector {}

        onExited: code => root.handleLocationResponse(code)
    }

    Process {
        id: weatherProcess

        stdout: StdioCollector {}
        stderr: StdioCollector {}

        onExited: code => root.handleWeatherResponse(code)
    }

    Timer {
        interval: 3600000
        running: true
        repeat: true

        onTriggered: root.reload()
    }
}
