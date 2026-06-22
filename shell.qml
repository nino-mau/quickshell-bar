//@ pragma UseQApplication

import QtQuick
import Quickshell
import qs.Modules.Bar
import qs.Modules.Notifications
import qs.Modules.OSD
import qs.Modules.Lock
import qs.Modules.Session

ShellRoot {
    BarScreens {}
    NotificationPopups {}
    Osd {}
    Lock {
        id: lock
    }
    Session {
        onLockRequested: lock.locked = true
    }

    Connections {
        target: Quickshell
        // Hide config reload popup
        function onReloadCompleted() {
            Quickshell.inhibitReloadPopup();
        }
    }
}
