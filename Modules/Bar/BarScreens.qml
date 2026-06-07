import QtQuick
import Quickshell
import qs.Modules.Bar

Variants {
    model: Quickshell.screens

    delegate: Scope {
        id: barDelegate
        required property ShellScreen modelData

        Bar {
            screen: barDelegate.modelData
        }
    }
}
