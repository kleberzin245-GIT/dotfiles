import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../components"

PanelWindow {
    id: bar

    required property var theme
    required property var state
    required property var modelData
    required property var audio
    required property var stats
    required property var notifications
    required property var media

    readonly property bool glassStyle: theme.glass

    screen: modelData
    anchors {
        top: true
        left: true
        right: true
    }
    margins {
        top: theme.barMarginTop
        left: theme.barMarginX
        right: theme.barMarginX
    }
    implicitHeight: theme.barHeight
    color: "transparent"
    exclusiveZone: implicitHeight + theme.barMarginTop

    WlrLayershell.namespace: "quickshell-bar"
    WlrLayershell.layer: WlrLayer.Top

    Item {
        anchors.fill: parent

        Rectangle {
            anchors.fill: parent
            visible: !bar.glassStyle
            radius: bar.theme.barRadius
            color: bar.theme.alpha(bar.theme.surface, bar.theme.barOpacity)
            border.width: bar.theme.barRadius > 0 ? 1 : 0
            border.color: bar.theme.alpha(bar.theme.onSurface, 0.12)
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: bar.glassStyle ? 0 : 10
            anchors.rightMargin: bar.glassStyle ? 0 : 10
            spacing: bar.glassStyle ? 8 : 8

            BarGroup {
                theme: bar.theme
                glass: bar.glassStyle
                Layout.alignment: Qt.AlignVCenter

                Workspaces {
                    theme: bar.theme
                    Layout.alignment: Qt.AlignVCenter
                }
            }

            Item { Layout.fillWidth: true }

            BarGroup {
                theme: bar.theme
                glass: bar.glassStyle
                spacing: 12
                Layout.alignment: Qt.AlignVCenter

                MediaMini {
                    theme: bar.theme
                    media: bar.media
                    state: bar.state
                    Layout.alignment: Qt.AlignVCenter
                }

                Clock {
                    id: clock
                    theme: bar.theme
                    opened: bar.state.calendarOpen
                    Layout.alignment: Qt.AlignVCenter
                    onClicked: bar.state.calendarOpen = !bar.state.calendarOpen
                }
            }

            Item { Layout.fillWidth: true }

            BarGroup {
                theme: bar.theme
                glass: bar.glassStyle
                spacing: 8
                Layout.alignment: Qt.AlignVCenter

                Tray {
                    theme: bar.theme
                    window: bar
                    Layout.alignment: Qt.AlignVCenter
                }

                Status {
                    theme: bar.theme
                    state: bar.state
                    audio: bar.audio
                    stats: bar.stats
                    notifications: bar.notifications
                    Layout.alignment: Qt.AlignVCenter
                }
            }
        }
    }

    CalendarPopup {
        theme: bar.theme
        state: bar.state
        window: bar
        anchorItem: clock
    }
}
