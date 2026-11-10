import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.UPower
import "../../components"

Item {
    id: root

    required property var theme
    property string pendingAction: ""

    readonly property var dev: UPower.displayDevice
    readonly property string home: Quickshell.env("HOME")
    readonly property int percent: dev ? Math.round(dev.percentage * 100) : 0

    function stateText() {
        if (!dev)
            return "Bateria indisponível";
        switch (dev.state) {
        case UPowerDeviceState.Charging:
            return "Carregando";
        case UPowerDeviceState.Discharging:
            return "Descarregando";
        case UPowerDeviceState.Empty:
            return "Vazia";
        case UPowerDeviceState.FullyCharged:
            return "Carregada";
        case UPowerDeviceState.PendingCharge:
            return "Carregamento pendente";
        case UPowerDeviceState.PendingDischarge:
            return "Descarga pendente";
        default:
            return "Desconhecido";
        }
    }

    function timeText() {
        if (!dev)
            return "";
        const seconds = dev.state === UPowerDeviceState.Charging ? dev.timeToFull : dev.timeToEmpty;
        if (!seconds || seconds <= 0)
            return "";
        const hours = Math.floor(seconds / 3600);
        const minutes = Math.round((seconds % 3600) / 60);
        return (dev.state === UPowerDeviceState.Charging ? "Cheia em " : "Restante: ") + hours + "h " + minutes + "m";
    }

    function confirmAction(kind, command) {
        if (pendingAction === kind) {
            pendingAction = "";
            Quickshell.execDetached(command);
            return;
        }
        pendingAction = kind;
        confirmTimer.restart();
    }

    Flickable {
        anchors.fill: parent
        contentWidth: width
        contentHeight: content.implicitHeight
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        ColumnLayout {
            id: content
            width: parent.width
            spacing: 10

            Card {
                theme: root.theme
                Layout.fillWidth: true

                RowLayout {
                    width: parent.width
                    spacing: 16

                    Item {
                        width: 124
                        height: 124

                        Canvas {
                            id: gauge

                            anchors.fill: parent
                            onPaint: {
                                const ctx = getContext("2d");
                                ctx.clearRect(0, 0, width, height);
                                const cx = width / 2;
                                const cy = height / 2;
                                const radius = 50;
                                ctx.lineWidth = 9;
                                ctx.lineCap = "round";
                                ctx.strokeStyle = root.theme.alpha(root.theme.onSurface, 0.10);
                                ctx.beginPath();
                                ctx.arc(cx, cy, radius, 0, Math.PI * 2);
                                ctx.stroke();
                                ctx.strokeStyle = root.dev && root.dev.state === UPowerDeviceState.Charging
                                    ? root.theme.tertiary
                                    : root.percent <= 15
                                        ? root.theme.error
                                        : root.theme.primary;
                                ctx.beginPath();
                                ctx.arc(cx, cy, radius, -Math.PI / 2, -Math.PI / 2 + Math.PI * 2 * (root.percent / 100));
                                ctx.stroke();
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            text: root.dev ? root.percent + "%" : "—"
                            color: root.theme.onSurface
                            font.family: root.theme.fontFamily
                            font.pixelSize: 24
                            font.weight: Font.Bold
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4

                        Text {
                            text: root.dev ? root.dev.model || "Bateria" : "Bateria"
                            color: root.theme.onSurface
                            font.family: root.theme.fontFamily
                            font.pixelSize: 13
                            font.weight: Font.DemiBold
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }

                        Text {
                            text: root.stateText()
                            color: root.dev && root.dev.state === UPowerDeviceState.Charging ? root.theme.tertiary : root.theme.onSurfaceVariant
                            font.family: root.theme.fontFamily
                            font.pixelSize: 11
                        }

                        Text {
                            visible: root.timeText() !== ""
                            text: root.timeText()
                            color: root.theme.onSurfaceVariant
                            font.family: root.theme.fontFamily
                            font.pixelSize: 10
                        }

                        Text {
                            visible: root.dev && root.dev.healthSupported
                            text: "Saúde: " + (root.dev ? Math.round(root.dev.healthPercentage) : 0) + "%"
                            color: root.theme.onSurfaceVariant
                            font.family: root.theme.fontFamily
                            font.pixelSize: 10
                        }
                    }
                }
            }

            Card {
                theme: root.theme
                Layout.fillWidth: true

                ColumnLayout {
                    width: parent.width
                    spacing: 8

                    SectionLabel {
                        theme: root.theme
                        text: "Perfil de energia"
                    }

                    Text {
                        visible: !PowerProfiles.hasPerformanceProfile
                        Layout.fillWidth: true
                        text: "Perfis de energia indisponíveis (power-profiles-daemon não instalado)."
                        color: root.theme.onSurfaceVariant
                        font.family: root.theme.fontFamily
                        font.pixelSize: 10
                        wrapMode: Text.WordWrap
                    }

                    RowLayout {
                        visible: PowerProfiles.hasPerformanceProfile
                        Layout.fillWidth: true
                        spacing: 6

                        PillButton {
                            theme: root.theme
                            label: "Econômico"
                            compact: true
                            active: PowerProfiles.profile === PowerProfile.PowerSaver
                            onClicked: PowerProfiles.profile = PowerProfile.PowerSaver
                        }

                        PillButton {
                            theme: root.theme
                            label: "Equilibrado"
                            compact: true
                            active: PowerProfiles.profile === PowerProfile.Balanced
                            onClicked: PowerProfiles.profile = PowerProfile.Balanced
                        }

                        PillButton {
                            theme: root.theme
                            label: "Desempenho"
                            compact: true
                            active: PowerProfiles.profile === PowerProfile.Performance
                            onClicked: PowerProfiles.profile = PowerProfile.Performance
                        }
                    }
                }
            }

            Card {
                theme: root.theme
                Layout.fillWidth: true

                ColumnLayout {
                    width: parent.width
                    spacing: 8

                    SectionLabel {
                        theme: root.theme
                        text: "Energia"
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 6

                        PillButton {
                            theme: root.theme
                            icon: "\uf023"
                            label: "Bloquear"
                            compact: true
                            Layout.fillWidth: true
                            onClicked: Quickshell.execDetached([root.home + "/.config/hypr/scripts/hyprlock.sh"])
                        }

                        PillButton {
                            theme: root.theme
                            icon: "\uf186"
                            label: "Suspender"
                            compact: true
                            Layout.fillWidth: true
                            onClicked: Quickshell.execDetached(["systemctl", "suspend"])
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 6

                        PillButton {
                            theme: root.theme
                            icon: "\uf08b"
                            label: root.pendingAction === "logout" ? "Confirmar?" : "Sair"
                            compact: true
                            danger: true
                            Layout.fillWidth: true
                            onClicked: root.confirmAction("logout", ["hyprctl", "dispatch", "exit"])
                        }

                        PillButton {
                            theme: root.theme
                            icon: "\uf01e"
                            label: root.pendingAction === "reboot" ? "Confirmar?" : "Reiniciar"
                            compact: true
                            danger: true
                            Layout.fillWidth: true
                            onClicked: root.confirmAction("reboot", ["systemctl", "reboot"])
                        }

                        PillButton {
                            theme: root.theme
                            icon: "\uf011"
                            label: root.pendingAction === "shutdown" ? "Confirmar?" : "Desligar"
                            compact: true
                            danger: true
                            Layout.fillWidth: true
                            onClicked: root.confirmAction("shutdown", ["systemctl", "poweroff"])
                        }
                    }
                }
            }

            Timer {
                id: confirmTimer
                interval: 3500
                onTriggered: root.pendingAction = ""
            }

            Timer {
                interval: 2000
                running: true
                repeat: true
                onTriggered: gauge.requestPaint()
            }
        }
    }
}
