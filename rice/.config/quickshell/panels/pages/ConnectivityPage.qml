import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell.Networking
import Quickshell.Bluetooth
import "../../components"

Item {
    id: root

    required property var theme
    property string mode: "wifi"
    property var pendingNetwork: null
    property string password: ""
    property int tick: 0

    readonly property var wifiDevice: {
        root.tick;
        const devices = Networking.devices.values;
        for (let i = 0; i < devices.length; i++) {
            if (devices[i].type === DeviceType.Wifi)
                return devices[i];
        }
        return null;
    }

    readonly property var wifiNetworks: wifiDevice ? wifiDevice.networks : null
    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property var btDevices: adapter ? adapter.devices : null
    readonly property bool wifiOn: Networking.wifiEnabled
    readonly property bool btOn: adapter ? adapter.enabled : false
    readonly property bool airplane: !wifiOn && !btOn

    function needsPassword(network) {
        if (!network)
            return false;
        return network.security !== WifiSecurityType.Open
            && network.security !== WifiSecurityType.Owe
            && network.security !== WifiSecurityType.Unknown;
    }

    function selectWifi(network) {
        if (!network || !wifiDevice)
            return;
        if (network.connected) {
            wifiDevice.disconnect();
            return;
        }
        if (network.known || !needsPassword(network)) {
            network.connect();
            return;
        }
        pendingNetwork = network;
        password = "";
        passwordField.forceActiveFocus();
    }

    function submitPassword() {
        if (!pendingNetwork || password === "")
            return;
        pendingNetwork.connectWithPsk(password);
        pendingNetwork = null;
        password = "";
    }

    function toggleBtDevice(device) {
        if (!device)
            return;
        if (device.connected)
            device.disconnect();
        else if (device.paired || device.bonded)
            device.connect();
        else
            device.pair();
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 10

        Card {
            theme: root.theme
            Layout.fillWidth: true

            RowLayout {
                width: parent.width
                spacing: 14

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 6

                    Text {
                        text: "\uf1eb"
                        color: root.wifiOn ? root.theme.primary : root.theme.onSurfaceVariant
                        font.family: root.theme.fontFamily
                        font.pixelSize: 18
                    }

                    Text {
                        text: "Wi-Fi"
                        color: root.theme.onSurface
                        font.family: root.theme.fontFamily
                        font.pixelSize: 12
                        font.weight: Font.DemiBold
                    }

                    ToggleSwitch {
                        theme: root.theme
                        checked: root.wifiOn
                        onToggled: (value) => Networking.wifiEnabled = value
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 6

                    Text {
                        text: "\uf293"
                        color: root.btOn ? root.theme.primary : root.theme.onSurfaceVariant
                        font.family: root.theme.fontFamily
                        font.pixelSize: 18
                    }

                    Text {
                        text: "Bluetooth"
                        color: root.theme.onSurface
                        font.family: root.theme.fontFamily
                        font.pixelSize: 12
                        font.weight: Font.DemiBold
                    }

                    ToggleSwitch {
                        theme: root.theme
                        checked: root.btOn
                        enabled: root.adapter !== null
                        onToggled: (value) => {
                            if (root.adapter)
                                root.adapter.enabled = value;
                        }
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 6

                    Text {
                        text: "\uf072"
                        color: root.airplane ? root.theme.tertiary : root.theme.onSurfaceVariant
                        font.family: root.theme.fontFamily
                        font.pixelSize: 18
                    }

                    Text {
                        text: "Avião"
                        color: root.theme.onSurface
                        font.family: root.theme.fontFamily
                        font.pixelSize: 12
                        font.weight: Font.DemiBold
                    }

                    ToggleSwitch {
                        theme: root.theme
                        checked: root.airplane
                        onToggled: (value) => {
                            Networking.wifiEnabled = !value;
                            if (root.adapter)
                                root.adapter.enabled = !value;
                        }
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 6

            PillButton {
                theme: root.theme
                label: "Wi-Fi"
                icon: "\uf1eb"
                compact: true
                active: root.mode === "wifi"
                onClicked: root.mode = "wifi"
            }

            PillButton {
                theme: root.theme
                label: "Bluetooth"
                icon: "\uf293"
                compact: true
                active: root.mode === "bluetooth"
                onClicked: root.mode = "bluetooth"
            }

            Item { Layout.fillWidth: true }
        }

        Card {
            visible: root.mode === "wifi" && root.pendingNetwork !== null
            theme: root.theme
            Layout.fillWidth: true

            ColumnLayout {
                width: parent.width
                spacing: 8

                Text {
                    text: "Senha de " + (root.pendingNetwork ? root.pendingNetwork.name : "")
                    color: root.theme.onSurface
                    font.family: root.theme.fontFamily
                    font.pixelSize: 11
                    font.weight: Font.DemiBold
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    TextField {
                        id: passwordField
                        Layout.fillWidth: true
                        placeholderText: "Senha"
                        echoMode: TextInput.Password
                        color: root.theme.onSurface
                        placeholderTextColor: root.theme.onSurfaceVariant
                        font.family: root.theme.fontFamily
                        font.pixelSize: 12
                        onAccepted: root.submitPassword()
                        background: Rectangle {
                            radius: 10
                            color: root.theme.alpha(root.theme.onSurface, 0.06)
                            border.width: 1
                            border.color: root.theme.alpha(root.theme.onSurface, 0.16)
                        }
                    }

                    PillButton {
                        theme: root.theme
                        label: "Conectar"
                        compact: true
                        onClicked: root.submitPassword()
                    }

                    PillButton {
                        theme: root.theme
                        label: "Cancelar"
                        compact: true
                        onClicked: {
                            root.pendingNetwork = null;
                            root.password = "";
                        }
                    }
                }
            }
        }

        SectionLabel {
            visible: root.mode === "wifi"
            theme: root.theme
            text: root.wifiOn ? "Redes disponíveis" : "Wi-Fi desligado"
        }

        ListView {
            visible: root.mode === "wifi"
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 4
            model: root.wifiNetworks

            delegate: Rectangle {
                id: wifiRow
                required property var modelData
                width: ListView.view.width
                height: 50
                radius: 10
                color: modelData.connected
                    ? root.theme.alpha(root.theme.primary, 0.12)
                    : wifiMouse.containsMouse
                        ? root.theme.alpha(root.theme.onSurface, 0.05)
                        : "transparent"

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    spacing: 10

                    Text {
                        text: "\uf1eb"
                        color: modelData.connected ? root.theme.primary : root.theme.onSurfaceVariant
                        opacity: 0.45 + (modelData.signalStrength || 0) * 0.0055
                        font.family: root.theme.fontFamily
                        font.pixelSize: 15
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 1

                        Text {
                            text: modelData.name || "Rede oculta"
                            color: root.theme.onSurface
                            font.family: root.theme.fontFamily
                            font.pixelSize: 12
                            font.weight: modelData.connected ? Font.DemiBold : Font.Normal
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }

                        Text {
                            text: modelData.connected
                                ? "Conectado"
                                : modelData.known
                                    ? "Rede salva"
                                    : WifiSecurityType.toString(modelData.security)
                            color: modelData.connected ? root.theme.primary : root.theme.onSurfaceVariant
                            font.family: root.theme.fontFamily
                            font.pixelSize: 9
                        }
                    }

                    Text {
                        visible: root.needsPassword(modelData)
                        text: "\uf023"
                        color: root.theme.onSurfaceVariant
                        font.family: root.theme.fontFamily
                        font.pixelSize: 10
                    }

                    Text {
                        visible: modelData.connected
                        text: "\uf00c"
                        color: root.theme.primary
                        font.family: root.theme.fontFamily
                        font.pixelSize: 12
                    }
                }

                MouseArea {
                    id: wifiMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.selectWifi(wifiRow.modelData)
                }
            }
        }

        Text {
            visible: root.mode === "wifi" && root.wifiOn && (root.wifiNetworks === null || root.wifiNetworks.values.length === 0)
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignCenter
            text: root.wifiNetworks === null ? "Nenhum adaptador Wi-Fi encontrado." : "Nenhuma rede encontrada. Ative a busca no sistema."
            color: root.theme.onSurfaceVariant
            font.family: root.theme.fontFamily
            font.pixelSize: 11
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
        }

        RowLayout {
            visible: root.mode === "bluetooth"
            Layout.fillWidth: true

            SectionLabel {
                theme: root.theme
                text: root.btOn ? "Dispositivos" : "Bluetooth desligado"
                Layout.fillWidth: true
            }

            PillButton {
                visible: root.adapter !== null
                theme: root.theme
                label: root.adapter && root.adapter.discovering ? "Parar busca" : "Buscar"
                icon: "\uf002"
                compact: true
                active: root.adapter && root.adapter.discovering
                onClicked: {
                    if (root.adapter)
                        root.adapter.discovering = !root.adapter.discovering;
                }
            }
        }

        ListView {
            visible: root.mode === "bluetooth"
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 4
            model: root.btDevices

            delegate: Rectangle {
                id: btRow
                required property var modelData
                width: ListView.view.width
                height: 54
                radius: 10
                color: modelData.connected
                    ? root.theme.alpha(root.theme.primary, 0.12)
                    : btMouse.containsMouse
                        ? root.theme.alpha(root.theme.onSurface, 0.05)
                        : "transparent"

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    spacing: 10

                    Text {
                        text: "\uf293"
                        color: modelData.connected ? root.theme.primary : root.theme.onSurfaceVariant
                        font.family: root.theme.fontFamily
                        font.pixelSize: 15
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 1

                        Text {
                            text: modelData.deviceName || modelData.name || modelData.address
                            color: root.theme.onSurface
                            font.family: root.theme.fontFamily
                            font.pixelSize: 12
                            font.weight: modelData.connected ? Font.DemiBold : Font.Normal
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }

                        Text {
                            text: modelData.connected
                                ? "Conectado" + (modelData.batteryAvailable ? " · " + Math.round(modelData.battery * 100) + "%" : "")
                                : modelData.paired || modelData.bonded
                                    ? "Pareado"
                                    : "Disponível"
                            color: modelData.connected ? root.theme.primary : root.theme.onSurfaceVariant
                            font.family: root.theme.fontFamily
                            font.pixelSize: 9
                        }
                    }

                    PillButton {
                        z: 1
                        theme: root.theme
                        compact: true
                        label: modelData.connected
                            ? "Desconectar"
                            : modelData.paired || modelData.bonded
                                ? "Conectar"
                                : "Parear"
                        enabled: !modelData.pairing
                        onClicked: root.toggleBtDevice(btRow.modelData)
                    }
                }

                MouseArea {
                    id: btMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.LeftButton
                    onClicked: root.toggleBtDevice(btRow.modelData)
                }
            }
        }

        Text {
            visible: root.mode === "bluetooth" && root.btOn && (root.btDevices === null || root.btDevices.values.length === 0)
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignCenter
            text: root.adapter === null ? "Nenhum adaptador Bluetooth encontrado." : "Nenhum dispositivo encontrado."
            color: root.theme.onSurfaceVariant
            font.family: root.theme.fontFamily
            font.pixelSize: 11
            horizontalAlignment: Text.AlignHCenter
        }
    }

    Timer {
        interval: 2500
        running: true
        repeat: true
        onTriggered: root.tick++
    }
}
