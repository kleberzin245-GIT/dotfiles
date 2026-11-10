import QtQuick
import QtQuick.Layouts
import "../../components"

Item {
    id: root

    required property var theme
    required property var media

    function formatTime(seconds) {
        if (!seconds || seconds <= 0)
            return "0:00";
        const total = Math.floor(seconds);
        const minutes = Math.floor(total / 60);
        const rest = total % 60;
        return minutes + ":" + (rest < 10 ? "0" : "") + rest;
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 10

        Card {
            visible: root.media.hasPlayer
            theme: root.theme
            Layout.fillWidth: true

            RowLayout {
                width: parent.width
                spacing: 14

                Rectangle {
                    width: 104
                    height: 104
                    radius: root.theme.sharp ? 0 : 14
                    color: root.theme.alpha(root.theme.surfaceContainerHigh, 0.8)
                    clip: true

                    Text {
                        anchors.centerIn: parent
                        text: "\uf001"
                        color: root.theme.onSurfaceVariant
                        font.family: root.theme.fontFamily
                        font.pixelSize: 28
                    }

                    Image {
                        anchors.fill: parent
                        source: root.media.artUrl
                        asynchronous: true
                        fillMode: Image.PreserveAspectCrop
                        visible: source !== "" && status === Image.Ready
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4

                    Text {
                        Layout.fillWidth: true
                        text: root.media.title !== "" ? root.media.title : "Sem título"
                        color: root.theme.onSurface
                        font.family: root.theme.fontFamily
                        font.pixelSize: 15
                        font.weight: Font.Bold
                        elide: Text.ElideRight
                    }

                    Text {
                        Layout.fillWidth: true
                        text: root.media.artist !== "" ? root.media.artist : "Artista desconhecido"
                        color: root.theme.onSurfaceVariant
                        font.family: root.theme.fontFamily
                        font.pixelSize: 11
                        elide: Text.ElideRight
                    }

                    Text {
                        Layout.fillWidth: true
                        visible: root.media.album !== ""
                        text: root.media.album
                        color: root.theme.onSurfaceVariant
                        font.family: root.theme.fontFamily
                        font.pixelSize: 10
                        elide: Text.ElideRight
                    }

                    Text {
                        Layout.fillWidth: true
                        text: root.media.player ? root.media.player.identity : ""
                        color: root.theme.alpha(root.theme.onSurfaceVariant, 0.75)
                        font.family: root.theme.fontFamily
                        font.pixelSize: 9
                        elide: Text.ElideRight
                    }
                }
            }
        }

        Card {
            visible: root.media.hasPlayer
            theme: root.theme
            Layout.fillWidth: true

            ColumnLayout {
                width: parent.width
                spacing: 8

                Slider {
                    theme: root.theme
                    Layout.fillWidth: true
                    enabled: root.media.player && root.media.player.canSeek && root.media.length > 0
                    value: root.media.length > 0 ? root.media.position / root.media.length : 0
                    onMoved: (value) => root.media.seek(value * root.media.length)
                }

                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        text: root.formatTime(root.media.position)
                        color: root.theme.onSurfaceVariant
                        font.family: root.theme.fontFamily
                        font.pixelSize: 9
                    }

                    Item { Layout.fillWidth: true }

                    Text {
                        text: root.formatTime(root.media.length)
                        color: root.theme.onSurfaceVariant
                        font.family: root.theme.fontFamily
                        font.pixelSize: 9
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 12

                    PillButton {
                        theme: root.theme
                        icon: "\uf048"
                        compact: false
                        enabled: root.media.canPrevious
                        onClicked: root.media.previous()
                    }

                    PillButton {
                        theme: root.theme
                        icon: root.media.playing ? "\uf04c" : "\uf04b"
                        compact: false
                        active: true
                        enabled: root.media.canToggle
                        onClicked: root.media.toggle()
                    }

                    PillButton {
                        theme: root.theme
                        icon: "\uf051"
                        compact: false
                        enabled: root.media.canNext
                        onClicked: root.media.next()
                    }
                }
            }
        }

        Text {
            visible: !root.media.hasPlayer
            Layout.fillWidth: true
            Layout.fillHeight: true
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            text: "Nenhum player MPRIS ativo."
            color: root.theme.onSurfaceVariant
            font.family: root.theme.fontFamily
            font.pixelSize: 12
        }
    }
}
