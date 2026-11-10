import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Pipewire
import "../../components"

Item {
    id: root

    required property var theme
    required property var audio

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
                    spacing: 8

                    PillButton {
                        theme: root.theme
                        icon: root.audio.muted ? "\uf026" : "\uf028"
                        label: root.audio.muted ? "Mudo" : "Som"
                        compact: true
                        active: !root.audio.muted
                        danger: root.audio.muted
                        onClicked: root.audio.toggleMute()
                    }

                    Item { Layout.fillWidth: true }

                    Text {
                        text: root.audio.volume + "%"
                        color: root.theme.onSurface
                        font.family: root.theme.fontFamily
                        font.pixelSize: 18
                        font.weight: Font.Bold
                    }
                }

                Slider {
                    theme: root.theme
                    Layout.fillWidth: true
                    value: root.audio.volume / 100
                    onDragged: (value) => root.audio.setVolume(value)
                    onMoved: (value) => root.audio.setVolume(value)
                }

                Text {
                    Layout.fillWidth: true
                    text: root.audio.sinkName !== "" ? root.audio.sinkName : "Saída de áudio indisponível"
                    color: root.theme.onSurfaceVariant
                    font.family: root.theme.fontFamily
                    font.pixelSize: 10
                    elide: Text.ElideRight
                }
            }
        }

        SectionLabel {
            theme: root.theme
            text: "Saídas"
        }

        ListView {
            Layout.fillWidth: true
            height: Math.min(contentHeight, 132)
            clip: true
            spacing: 3
            model: root.audio.sinks

            delegate: Rectangle {
                id: sinkRow
                required property var modelData
                width: ListView.view.width
                height: 40
                radius: 9
                color: Pipewire.defaultAudioSink === modelData
                    ? root.theme.alpha(root.theme.primary, 0.14)
                    : sinkMouse.containsMouse
                        ? root.theme.alpha(root.theme.onSurface, 0.05)
                        : "transparent"

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    spacing: 8

                    Text {
                        text: "\uf028"
                        color: Pipewire.defaultAudioSink === modelData ? root.theme.primary : root.theme.onSurfaceVariant
                        font.family: root.theme.fontFamily
                        font.pixelSize: 13
                    }

                    Text {
                        Layout.fillWidth: true
                        text: modelData.description || modelData.nickname || ("Saída " + modelData.id)
                        color: root.theme.onSurface
                        font.family: root.theme.fontFamily
                        font.pixelSize: 11
                        elide: Text.ElideRight
                    }

                    Text {
                        visible: Pipewire.defaultAudioSink === modelData
                        text: "\uf00c"
                        color: root.theme.primary
                        font.family: root.theme.fontFamily
                        font.pixelSize: 11
                    }
                }

                MouseArea {
                    id: sinkMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.audio.setSink(sinkRow.modelData)
                }
            }
        }

        SectionLabel {
            theme: root.theme
            text: "Entradas"
        }

        ListView {
            Layout.fillWidth: true
            height: Math.min(contentHeight, 132)
            clip: true
            spacing: 3
            model: root.audio.sources

            delegate: Rectangle {
                id: sourceRow
                required property var modelData
                width: ListView.view.width
                height: 40
                radius: 9
                color: Pipewire.defaultAudioSource === modelData
                    ? root.theme.alpha(root.theme.primary, 0.14)
                    : sourceMouse.containsMouse
                        ? root.theme.alpha(root.theme.onSurface, 0.05)
                        : "transparent"

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    spacing: 8

                    Text {
                        text: "\uf130"
                        color: Pipewire.defaultAudioSource === modelData ? root.theme.primary : root.theme.onSurfaceVariant
                        font.family: root.theme.fontFamily
                        font.pixelSize: 13
                    }

                    Text {
                        Layout.fillWidth: true
                        text: modelData.description || modelData.nickname || ("Entrada " + modelData.id)
                        color: root.theme.onSurface
                        font.family: root.theme.fontFamily
                        font.pixelSize: 11
                        elide: Text.ElideRight
                    }

                    Text {
                        visible: Pipewire.defaultAudioSource === modelData
                        text: "\uf00c"
                        color: root.theme.primary
                        font.family: root.theme.fontFamily
                        font.pixelSize: 11
                    }
                }

                MouseArea {
                    id: sourceMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.audio.setSource(sourceRow.modelData)
                }
            }
        }

        Item { Layout.fillHeight: true }
    }
}
