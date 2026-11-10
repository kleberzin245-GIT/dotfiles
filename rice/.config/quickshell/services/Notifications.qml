import Quickshell.Services.Notifications

NotificationServer {
    id: root

    property int count: 0

    keepOnReload: true

    onTrackedNotificationsChanged: {
        root.count = root.trackedNotifications.values.length;
    }

    function clearAll() {
        const list = root.trackedNotifications.values;
        for (let i = 0; i < list.length; i++)
            list[i].dismiss();
    }

    function dismiss(notification) {
        if (notification)
            notification.dismiss();
    }
}
