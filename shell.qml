//@ pragma UseQApplication

import QtQuick
import Quickshell
import qs.Modules.Bar
import qs.Modules.Notifications

ShellRoot {
    BarScreens {}
    NotificationPopups {}

    Connections {
        target: Quickshell
        // Hide config reload popup
        function onReloadCompleted() {
            Quickshell.inhibitReloadPopup();
        }
    }
}
