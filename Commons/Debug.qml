pragma Singleton

import QtQuick
import Quickshell

Singleton {
    function stringify(value: var, indentation: int): string {
        const seen = [];

        try {
            const json = JSON.stringify(value, function(key, entry) {
                if (typeof entry === "function") {
                    return "[Function]";
                }

                if (entry && typeof entry === "object") {
                    if (seen.indexOf(entry) !== -1) {
                        return "[Circular]";
                    }

                    seen.push(entry);
                }

                return entry;
            }, indentation);

            return json === undefined ? String(value) : json;
        } catch (error) {
            return String(value);
        }
    }

    function logObject(label: string, value: var): void {
        console.log(label + ":", stringify(value, 2));
    }
}
