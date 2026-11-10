import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../components"
import "pages"

PanelWindow {
    id: root

    required property var theme
    required property var state
    required property var modelData
    required property var audio
    required property var brightness
    required property var stats
    required property var notifications
    required property var media
    required property var desktop

    readonly property var tabIds: ["connectivity", "audio", "display", "power", "media", "system", "appearance", "notifications"]
    readonly property int tabIndex: Math.max(0, tabIds.indexOf(state.page))

    screen: modelData
    anchors {
        top: true
        right: true
    }
    margins {
        top: theme.barHeight + theme.barMarginTop + 8
        right: theme.barMarginX
    }
    implicitWidth: Math.min(440, modelData.width - 24)
    implicitHeight: Math.min(632, modelData.height - margins.top - 24)
    visible: state.controlCenterOpen
    color: "transparent"

    WlrLayershell.namespace: "quickshell-control"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

    onVisibleChanged: {
        if (visible)
            state.calendarOpen = false;
    }

    Rectangle {
        anchors.fill: parent
        radius: root.theme.panelRadius
        color: root.theme.alpha(root.theme.surface, 0.95)
        border.width: 1
        border.color: root.theme.alpha(root.theme.onSurface, 0.14)

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 10

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 1

                    Text {
                        text: "Central de Controle"
                        color: root.theme.onSurface
                        font.family: root.theme.fontFamily
                        font.pixelSize: 15
                        font.weight: Font.Bold
                    }

                    Text {
                        text: root.theme.styleName + " · SUPER + M"
                        color: root.theme.onSurfaceVariant
                        font.family: root.theme.fontFamily
                        font.pixelSize: 9
                    }
                }

                IconButton {
                    theme: root.theme
                    icon: "\uf00d"
                    onClicked: root.state.controlCenterOpen = false
                }
            }

            Flow {
                Layout.fillWidth: true
                spacing: 5

                Repeater {
                    model: [
                        { id: "connectivity", label: "Rede", icon: "\uf1eb" },
                        { id: "audio", label: "Áudio", icon: "\uf028" },
                        { id: "display", label: "Tela", icon: "\uf185" },
                        { id: "power", label: "Energia", icon: "\uf0e7" },
                        { id: "media", label: "Mídia", icon: "\uf001" },
                        { id: "system", label: "Sistema", icon: "\uf2db" },
                        { id: "appearance", label: "Aparência", icon: "\uf53f" },
                        { id: "notifications", label: "Avisos", icon: "\uf0f3" }
                    ]

                    delegate: PillButton {
                        required property var modelData
                        theme: root.theme
                        label: modelData.label
                        icon: modelData.icon
                        compact: true
                        active: root.state.page === modelData.id
                        onClicked: root.state.page = modelData.id
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: root.theme.alpha(root.theme.onSurface, 0.10)
            }

            StackLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                currentIndex: root.tabIndex

                ConnectivityPage {
                    theme: root.theme
                }

                AudioPage {
                    theme: root.theme
                    audio: root.audio
                }

                DisplayPage {
                    theme: root.theme
                    brightness: root.brightness
                }

                PowerPage {
                    theme: root.theme
                }

                MediaPage {
                    theme: root.theme
                    media: root.media
                }

                SystemPage {
                    theme: root.theme
                    stats: root.stats
                }

                AppearancePage {
                    theme: root.theme
                    desktop: root.desktop
                }

                NotificationsPage {
                    theme: root.theme
                    notifications: root.notifications
                }
            }
        }
    }
}
