import QtQuick
import Quickshell
import qs.Modules.Bar

/**
* Responsible for creating a bar on every screen
*/
Variants {
    model: Quickshell.screens

    delegate: Scope {
        id: barDelegate
        required property ShellScreen modelData

        BarWindow {
            screen: barDelegate.modelData
        }
    }
}
