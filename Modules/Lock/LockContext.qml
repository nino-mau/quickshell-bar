pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Services.Pam

// Minimal PAM-backed authentication for the lock screen. Holds the typed
// password and the current status text; emits unlocked() on success.
Scope {
    id: root

    signal unlocked

    property string currentText: ""
    property bool authenticating: false
    // Short message shown under the field (a prompt or an error).
    property string status: ""

    function reset(): void {
        pam.abort();
        currentText = "";
        authenticating = false;
        status = "";
    }

    function tryUnlock(): void {
        if (authenticating || currentText.length === 0)
            return;
        authenticating = true;
        status = "";
        pam.start();
    }

    PamContext {
        id: pam

        // PAM service used to verify the password. "login" works on most
        // distros (on Arch it pulls in system-auth); override with the env var
        // if your setup needs a different one.
        config: Quickshell.env("BAR_PAM_SERVICE") || "login"
        configDirectory: "/etc/pam.d"
        user: Quickshell.env("USER")

        onPamMessage: {
            if (responseRequired) {
                pam.respond(root.currentText);
            } else if (messageIsError && message.length > 0) {
                root.status = message;
            }
        }

        onCompleted: result => {
            root.authenticating = false;
            if (result === PamResult.Success) {
                root.unlocked();
            } else {
                root.currentText = "";
                root.status = qsTr("Incorrect password");
            }
        }

        onError: {
            root.authenticating = false;
            root.currentText = "";
            root.status = qsTr("Authentication error");
        }
    }
}
