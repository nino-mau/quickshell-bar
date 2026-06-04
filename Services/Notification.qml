pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Notifications

Singleton {
    id: root

    property int maxPopups: 4
    property int maxHistory: 50
    property int defaultTimeoutMs: 6000
    property int criticalTimeoutMs: 10000
    property bool doNotDisturb: false

    property ListModel popupModel: ListModel {}
    property ListModel historyModel: ListModel {}

    property int nextId: 0
    property var popupState: ({})
    property var serverIdToPopupId: ({})

    signal animateAndRemove(string notificationId)

    NotificationServer {
        keepOnReload: false
        bodySupported: true
        bodyMarkupSupported: false
        actionsSupported: true
        imageSupported: true

        onNotification: notification => root.handleNotification(notification)
    }

    Timer {
        interval: 50
        repeat: true
        running: root.popupModel.count > 0

        onTriggered: root.updateTimeouts()
    }

    function handleNotification(notification: Notification): void {
        const notificationId = String(notification.id);
        const existingPopupId = root.serverIdToPopupId[notificationId] || "";
        const popupId = existingPopupId.length > 0 ? existingPopupId : root.createPopupId();
        const data = root.createData(notification, popupId);

        if (!notification.transient) {
            root.addToHistory(data);
        }

        if (root.doNotDisturb) {
            return;
        }

        if (existingPopupId.length > 0 && root.popupState[existingPopupId]) {
            root.updatePopup(existingPopupId, notification, data);
            return;
        }

        root.addPopup(notificationId, notification, data);
    }

    function createPopupId(): string {
        root.nextId += 1;
        return Date.now() + "-" + root.nextId;
    }

    function createData(notification: Notification, popupId: string): var {
        const appName = root.cleanText(notification.appName || notification.desktopEntry || qsTr("Application"));
        const urgency = Math.max(NotificationUrgency.Low, Math.min(NotificationUrgency.Critical, notification.urgency));

        return {
            notificationId: popupId,
            appName: appName,
            summary: root.cleanText(notification.summary || ""),
            body: root.cleanText(notification.body || ""),
            urgency: urgency,
            expireTimeout: notification.expireTimeout,
            image: notification.image || "",
            appIcon: notification.appIcon || "",
            timestamp: Date.now()
        };
    }

    function cleanText(value: string): string {
        return String(value ?? "").replace(/<[^>]*>/g, "").replace(/&amp;/g, "&").replace(/&lt;/g, "<").replace(/&gt;/g, ">").replace(/&quot;/g, "\"").trim();
    }

    function durationFor(data: var): int {
        if (data.expireTimeout === 0) {
            return -1;
        }
        if (data.expireTimeout > 0) {
            return data.expireTimeout;
        }
        if (data.urgency === NotificationUrgency.Critical) {
            return root.criticalTimeoutMs;
        }
        return root.defaultTimeoutMs;
    }

    function addPopup(serverId: string, notification: Notification, data: var): void {
        root.serverIdToPopupId[serverId] = data.notificationId;
        root.trackNotification(serverId, notification, data);
        root.popupModel.insert(0, data);

        while (root.popupModel.count > root.maxPopups) {
            const last = root.popupModel.get(root.popupModel.count - 1);
            root.dismissPopup(last.notificationId);
        }
    }

    function updatePopup(popupId: string, notification: Notification, data: var): void {
        const index = root.popupIndex(popupId);
        if (index < 0) {
            return;
        }

        const oldState = root.takeState(popupId);
        root.trackNotification(oldState?.serverId || String(notification.id), notification, data);

        root.popupModel.setProperty(index, "appName", data.appName);
        root.popupModel.setProperty(index, "summary", data.summary);
        root.popupModel.setProperty(index, "body", data.body);
        root.popupModel.setProperty(index, "urgency", data.urgency);
        root.popupModel.setProperty(index, "expireTimeout", data.expireTimeout);
        root.popupModel.setProperty(index, "image", data.image);
        root.popupModel.setProperty(index, "appIcon", data.appIcon);
        root.popupModel.setProperty(index, "timestamp", data.timestamp);
    }

    function trackNotification(serverId: string, notification: Notification, data: var): void {
        notification.tracked = true;

        const popupId = data.notificationId;
        const closedHandler = function () {
            root.removePopup(popupId);
        };

        notification.closed.connect(closedHandler);
        root.serverIdToPopupId[serverId] = popupId;
        root.popupState[popupId] = {
            serverId: serverId,
            notification: notification,
            closedHandler: closedHandler,
            timestamp: Date.now(),
            duration: root.durationFor(data),
            animatingRemoval: false
        };
    }

    function updateTimeouts(): void {
        const now = Date.now();

        for (let index = root.popupModel.count - 1; index >= 0; index--) {
            const item = root.popupModel.get(index);
            const state = root.popupState[item.notificationId];
            if (!state || state.duration < 0 || state.animatingRemoval) {
                continue;
            }

            const remainingRatio = Math.max(0, 1 - ((now - state.timestamp) / state.duration));

            if (remainingRatio <= 0) {
                root.requestAnimatedRemoval(item.notificationId);
            }
        }
    }

    function popupIndex(popupId: string): int {
        for (let index = 0; index < root.popupModel.count; index++) {
            if (root.popupModel.get(index).notificationId === popupId) {
                return index;
            }
        }
        return -1;
    }

    function requestAnimatedRemoval(popupId: string): void {
        const state = root.popupState[popupId];
        if (state) {
            if (state.animatingRemoval) {
                return;
            }
            state.animatingRemoval = true;
        }

        root.animateAndRemove(popupId);
    }

    function removePopup(popupId: string): var {
        const index = root.popupIndex(popupId);
        if (index >= 0) {
            root.popupModel.remove(index);
        }
        return root.takeState(popupId);
    }

    function takeState(popupId: string): var {
        const state = root.popupState[popupId];
        if (!state) {
            return null;
        }

        try {
            state.notification.closed.disconnect(state.closedHandler);
        } catch (error) {}

        delete root.popupState[popupId];
        if (state.serverId && root.serverIdToPopupId[state.serverId] === popupId) {
            delete root.serverIdToPopupId[state.serverId];
        }

        return state;
    }

    function dismissPopup(popupId: string): void {
        const state = root.removePopup(popupId);
        if (state?.notification) {
            state.notification.dismiss();
        }
    }

    function expirePopup(popupId: string): void {
        const state = root.removePopup(popupId);
        if (state?.notification) {
            state.notification.expire();
        }
    }

    function dismissAll(): void {
        while (root.popupModel.count > 0) {
            const item = root.popupModel.get(0);
            root.dismissPopup(item.notificationId);
        }
    }

    function addToHistory(data: var): void {
        root.historyModel.insert(0, data);
        while (root.historyModel.count > root.maxHistory) {
            root.historyModel.remove(root.historyModel.count - 1);
        }
    }

    function clearHistory(): void {
        root.historyModel.clear();
    }

    function invokeDefaultAction(popupId: string): bool {
        return root.invokeAction(popupId, "default");
    }

    function invokeAction(popupId: string, actionIdentifier: string): bool {
        const state = root.popupState[popupId];
        const actions = state?.notification?.actions || [];

        for (const action of actions) {
            if (action.identifier === actionIdentifier) {
                let closedHandlerDisconnected = false;

                if (state?.notification && state.closedHandler) {
                    try {
                        state.notification.closed.disconnect(state.closedHandler);
                        closedHandlerDisconnected = true;
                    } catch (error) {}
                }

                try {
                    action.invoke();
                } catch (error) {
                    if (closedHandlerDisconnected) {
                        try {
                            state.notification.closed.connect(state.closedHandler);
                        } catch (reconnectError) {}
                    }
                    return false;
                }

                return true;
            }
        }

        return false;
    }
}
