//@ pragma UseQApplication

import QtQuick
import Quickshell
import qs.Modules.Bar
import qs.Modules.Notifications
import qs.Modules.OSD

ShellRoot {
    BarScreens {}
    NotificationPopups {}
    Osd {}

    Connections {
        target: Quickshell
        // Hide config reload popup
        function onReloadCompleted() {
            Quickshell.inhibitReloadPopup();
        }
    }
}
