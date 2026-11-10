import QtQuick
import QtQuick.Layouts
import Quickshell
import "../../components"

Item {
    id: root

    required property var theme
    required property var stats

    function temperatureText() {
        if (!root.stats || root.stats.temp < 0)
            return "—";
        return Math.round(root.stats.temp) + " °C";
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

                ColumnLayout {
                    width: parent.width
                    spacing: 12

                    StatBar {
                        theme: root.theme
                        Layout.fillWidth: true
                        label: "CPU"
                        valueText: root.stats.cpuPercent + "%"
                        value: root.stats.cpuPercent / 100
                    }

                    StatBar {
                        theme: root.theme
                        Layout.fillWidth: true
                        label: "Memória"
                        valueText: root.stats.memPercent + "% · " + root.stats.memUsedGb.toFixed(1) + "/" + root.stats.memTotalGb.toFixed(1) + " GB"
                        value: root.stats.memPercent / 100
                        fillColor: root.theme.secondary
                    }

                    StatBar {
                        theme: root.theme
                        Layout.fillWidth: true
                        label: "Disco"
                        valueText: root.stats.diskPercent + "% · " + root.stats.diskUsedGb.toFixed(1) + "/" + root.stats.diskTotalGb.toFixed(1) + " GB"
                        value: root.stats.diskPercent / 100
                        fillColor: root.theme.tertiary
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
                        text: "Sistema"
                    }

                    RowLayout {
                        Layout.fillWidth: true

                        Text {
                            Layout.fillWidth: true
                            text: "Temperatura"
                            color: root.theme.onSurfaceVariant
                            font.family: root.theme.fontFamily
                            font.pixelSize: 11
                        }

                        Text {
                            text: root.temperatureText()
                            color: root.stats.temp >= 80 ? root.theme.error : root.theme.onSurface
                            font.family: root.theme.fontFamily
                            font.pixelSize: 11
                            font.weight: Font.DemiBold
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true

                        Text {
                            Layout.fillWidth: true
                            text: "Load (1 min)"
                            color: root.theme.onSurfaceVariant
                            font.family: root.theme.fontFamily
                            font.pixelSize: 11
                        }

                        Text {
                            text: root.stats.load1.toFixed(2)
                            color: root.theme.onSurface
                            font.family: root.theme.fontFamily
                            font.pixelSize: 11
                            font.weight: Font.DemiBold
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true

                        Text {
                            Layout.fillWidth: true
                            text: "Uptime"
                            color: root.theme.onSurfaceVariant
                            font.family: root.theme.fontFamily
                            font.pixelSize: 11
                        }

                        Text {
                            text: root.stats.uptimeText
                            color: root.theme.onSurface
                            font.family: root.theme.fontFamily
                            font.pixelSize: 11
                            font.weight: Font.DemiBold
                        }
                    }
                }
            }

            PillButton {
                theme: root.theme
                Layout.fillWidth: true
                icon: "\uf120"
                label: "Abrir monitor de processos"
                onClicked: Quickshell.execDetached(["kitty", "-e", "btop"])
            }

            Item { Layout.fillHeight: true }
        }
    }
}
