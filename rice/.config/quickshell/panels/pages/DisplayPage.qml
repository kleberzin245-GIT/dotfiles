import QtQuick
import QtQuick.Layouts
import "../../components"

Item {
    id: root

    required property var theme
    required property var brightness

    ColumnLayout {
        anchors.fill: parent
        spacing: 10

        Card {
            theme: root.theme
            Layout.fillWidth: true

            ColumnLayout {
                width: parent.width
                spacing: 10

                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        text: "\uf185"
                        color: root.brightness.available ? root.theme.primary : root.theme.onSurfaceVariant
                        font.family: root.theme.fontFamily
                        font.pixelSize: 17
                    }

                    SectionLabel {
                        theme: root.theme
                        text: "Brilho"
                        Layout.fillWidth: true
                    }

                    Text {
                        text: root.brightness.available ? root.brightness.percent + "%" : "—"
                        color: root.theme.onSurface
                        font.family: root.theme.fontFamily
                        font.pixelSize: 16
                        font.weight: Font.Bold
                    }
                }

                Slider {
                    theme: root.theme
                    Layout.fillWidth: true
                    enabled: root.brightness.available
                    value: root.brightness.percent / 100
                    onDragged: (value) => root.brightness.setPercent(value * 100)
                    onMoved: (value) => root.brightness.setPercent(value * 100)
                }

                Text {
                    Layout.fillWidth: true
                    visible: root.brightness.device !== ""
                    text: root.brightness.device
                    color: root.theme.onSurfaceVariant
                    font.family: root.theme.fontFamily
                    font.pixelSize: 9
                    elide: Text.ElideRight
                }

                Text {
                    Layout.fillWidth: true
                    visible: !root.brightness.available
                    text: "brightnessctl não encontrado ou nenhum backlight disponível."
                    color: root.theme.onSurfaceVariant
                    font.family: root.theme.fontFamily
                    font.pixelSize: 10
                    wrapMode: Text.WordWrap
                }
            }
        }

        Card {
            theme: root.theme
            Layout.fillWidth: true

            ColumnLayout {
                width: parent.width
                spacing: 6

                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        text: "\uf186"
                        color: root.theme.onSurfaceVariant
                        font.family: root.theme.fontFamily
                        font.pixelSize: 15
                    }

                    SectionLabel {
                        theme: root.theme
                        text: "Temperatura de cor"
                        Layout.fillWidth: true
                    }
                }

                Text {
                    Layout.fillWidth: true
                    text: "Nenhuma ferramenta de temperatura de cor instalada. Instale hyprsunset ou gammastep para habilitar este controle."
                    color: root.theme.onSurfaceVariant
                    font.family: root.theme.fontFamily
                    font.pixelSize: 10
                    wrapMode: Text.WordWrap
                }
            }
        }

        Item { Layout.fillHeight: true }
    }
}
