import QtQuick
import QtQuick.Layouts
import Quickshell.Networking
import Quickshell.Bluetooth
import Quickshell.Services.UPower
import "../components"

RowLayout {
    id: root

    required property var theme
    required property var state
    required property var audio
    required property var stats
    required property var notifications

    spacing: 4
    property int tick: 0

    readonly property var wifiDevice: {
        root.tick;
        const items = Networking.devices.values;
        for (let i = 0; i < items.length; i++) {
            if (items[i].type === DeviceType.Wifi)
                return items[i];
        }
        return null;
    }

    readonly property bool wifiConnected: {
        root.tick;
        if (!wifiDevice)
            return false;
        const networks = wifiDevice.networks.values;
        for (let i = 0; i < networks.length; i++) {
            if (networks[i].connected)
                return true;
        }
        return false;
    }

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool btConnected: {
        if (!adapter)
            return false;
        const devices = adapter.devices.values;
        for (let i = 0; i < devices.length; i++) {
            if (devices[i].connected)
                return true;
        }
        return false;
    }

    readonly property var battery: UPower.displayDevice

    function batteryIcon() {
        if (!battery)
            return "\uf244";
        if (battery.state === UPowerDeviceState.Charging)
            return "\uf0e7";
        const percent = battery.percentage * 100;
        if (percent >= 90)
            return "\uf240";
        if (percent >= 65)
            return "\uf241";
        if (percent >= 40)
            return "\uf242";
        if (percent >= 15)
            return "\uf243";
        return "\uf244";
    }

    IconButton {
        theme: root.theme
        icon: Bluetooth.defaultAdapter ? "\uf293" : "\uf294"
        dim: !Bluetooth.defaultAdapter || !Bluetooth.defaultAdapter.enabled
        active: root.btConnected
        onClicked: root.state.open("connectivity")
    }

    IconButton {
        theme: root.theme
        icon: root.wifiConnected ? "\uf1eb" : "\uf071"
        dim: !Networking.wifiEnabled
        active: root.wifiConnected
        onClicked: root.state.open("connectivity")
    }

    IconButton {
        theme: root.theme
        icon: root.audio.muted ? "\uf026" : (root.audio.volume > 50 ? "\uf028" : "\uf027")
        active: root.audio.muted
        danger: root.audio.muted
        onClicked: root.state.open("audio")
    }

    IconButton {
        theme: root.theme
        icon: "\uf2db"
        suffix: root.stats.cpuPercent + "%"
        onClicked: root.state.open("system")
    }

    IconButton {
        theme: root.theme
        icon: "\uf538"
        suffix: root.stats.memPercent + "%"
        onClicked: root.state.open("system")
    }

    IconButton {
        visible: root.battery !== null
        theme: root.theme
        icon: root.batteryIcon()
        suffix: root.battery ? Math.round(root.battery.percentage * 100) + "%" : ""
        active: root.battery && root.battery.state === UPowerDeviceState.Charging
        danger: root.battery && root.battery.percentage <= 0.10 && root.battery.state === UPowerDeviceState.Discharging
        onClicked: root.state.open("power")
    }

    IconButton {
        theme: root.theme
        icon: root.notifications.count > 0 ? "\uf0f3" : "\uf0a2"
        active: root.notifications.count > 0
        badge: root.notifications.count
        onClicked: root.state.open("notifications")
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: root.tick++
    }
}
