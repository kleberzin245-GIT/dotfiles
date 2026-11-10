import QtQuick
import QtQuick.Layouts
import "../../components"

Item {
    id: root

    required property var theme
    required property var desktop

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
                    spacing: 8

                    RowLayout {
                        Layout.fillWidth: true

                        SectionLabel {
                            theme: root.theme
                            text: "Estilo"
                            Layout.fillWidth: true
                        }

                        Text {
                            text: root.theme.styleName
                            color: root.theme.onSurfaceVariant
                            font.family: root.theme.fontFamily
                            font.pixelSize: 10
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 6

                        Repeater {
                            model: root.desktop.styles

                            delegate: PillButton {
                                required property var modelData
                                theme: root.theme
                                label: modelData.name
                                compact: true
                                active: root.theme.styleId === modelData.id
                                Layout.fillWidth: true
                                onClicked: root.desktop.applyStyle(modelData.name)
                            }
                        }
                    }

                    Text {
                        Layout.fillWidth: true
                        text: "Trocar o estilo reinicia a barra (Waybar ou Quickshell) e aplica as configurações do Hyprland, Kitty, Mako, Fuzzel e Rofi."
                        color: root.theme.onSurfaceVariant
                        font.family: root.theme.fontFamily
                        font.pixelSize: 9
                        wrapMode: Text.WordWrap
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
                        text: "Tema"
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 6

                        PillButton {
                            theme: root.theme
                            label: "Escuro"
                            compact: true
                            active: root.desktop.mode === "dark"
                            Layout.fillWidth: true
                            onClicked: root.desktop.setMode("dark")
                        }

                        PillButton {
                            theme: root.theme
                            label: "Claro"
                            compact: true
                            active: root.desktop.mode === "light"
                            Layout.fillWidth: true
                            onClicked: root.desktop.setMode("light")
                        }
                    }

                    SectionLabel {
                        theme: root.theme
                        text: "Fonte de cor"
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 6

                        Repeater {
                            model: [0, 1, 2, 3]

                            delegate: PillButton {
                                required property int modelData
                                theme: root.theme
                                label: String(modelData + 1)
                                compact: true
                                active: root.desktop.colorIndex === modelData
                                Layout.fillWidth: true
                                onClicked: root.desktop.setColorIndex(modelData)
                            }
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

                    RowLayout {
                        Layout.fillWidth: true

                        SectionLabel {
                            theme: root.theme
                            text: "Wallpaper"
                            Layout.fillWidth: true
                        }

                        PillButton {
                            theme: root.theme
                            icon: "\uf021"
                            compact: true
                            onClicked: root.desktop.refreshWallpapers()
                        }
                    }

                    GridView {
                        Layout.fillWidth: true
                        height: 190
                        clip: true
                        cellWidth: 88
                        cellHeight: 66
                        model: root.desktop.wallpapers

                        delegate: Item {
                            id: wallpaperCell
                            required property var modelData
                            width: 84
                            height: 62

                            Rectangle {
                                anchors.fill: parent
                                radius: root.theme.sharp ? 0 : 10
                                color: root.theme.alpha(root.theme.surfaceContainerHigh, 0.8)
                                border.width: root.desktop.currentWallpaper === modelData.path ? 2 : 1
                                border.color: root.desktop.currentWallpaper === modelData.path
                                    ? root.theme.primary
                                    : root.theme.alpha(root.theme.onSurface, 0.12)
                                clip: true

                                Image {
                                    anchors.fill: parent
                                    anchors.margins: 2
                                    source: "file://" + modelData.path
                                    asynchronous: true
                                    fillMode: Image.PreserveAspectCrop
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.desktop.applyWallpaper(wallpaperCell.modelData.path)
                            }
                        }
                    }

                    Text {
                        visible: root.desktop.wallpapers.length === 0
                        Layout.fillWidth: true
                        text: "Nenhum wallpaper encontrado em ~/Pictures/Wallpapers."
                        color: root.theme.onSurfaceVariant
                        font.family: root.theme.fontFamily
                        font.pixelSize: 10
                    }

                    Text {
                        Layout.fillWidth: true
                        text: "Aplicar um wallpaper também regenera as cores Matugen de todo o sistema."
                        color: root.theme.onSurfaceVariant
                        font.family: root.theme.fontFamily
                        font.pixelSize: 9
                        wrapMode: Text.WordWrap
                    }
                }
            }

            Item { Layout.fillHeight: true }
        }
    }
}
