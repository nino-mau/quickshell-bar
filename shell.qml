//@ pragma UseQApplication

import QtQuick
import Quickshell
import qs.Modules.Bar

ShellRoot {
    BarScreens {}

    Connections {
        target: Quickshell
        // Hide config reload popup
        function onReloadCompleted() {
            Quickshell.inhibitReloadPopup();
        }
    }
}
