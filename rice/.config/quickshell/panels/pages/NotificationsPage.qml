import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Notifications
import "../../components"

Item {
    id: root

    required property var theme
    required property var notifications

    ColumnLayout {
        anchors.fill: parent
        spacing: 10

        Card {
            theme: root.theme
            Layout.fillWidth: true

            RowLayout {
                width: parent.width
                spacing: 8

                Text {
                    text: "\uf0f3"
                    color: root.theme.primary
                    font.family: root.theme.fontFamily
                    font.pixelSize: 16
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 1

                    Text {
                        text: root.notifications.count === 1 ? "1 notificação" : root.notifications.count + " notificações"
                        color: root.theme.onSurface
                        font.family: root.theme.fontFamily
                        font.pixelSize: 12
                        font.weight: Font.DemiBold
                    }

                    Text {
                        text: "Central de notificações do Quickshell"
                        color: root.theme.onSurfaceVariant
                        font.family: root.theme.fontFamily
                        font.pixelSize: 9
                    }
                }

                PillButton {
                    theme: root.theme
                    label: "Limpar tudo"
                    compact: true
                    enabled: root.notifications.count > 0
                    onClicked: root.notifications.clearAll()
                }
            }
        }

        ListView {
            visible: root.notifications.count > 0
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 6
            model: root.notifications.trackedNotifications

            delegate: Rectangle {
                id: notificationRow
                required property var modelData
                width: ListView.view.width
                height: Math.max(62, content.implicitHeight + 22)
                radius: 12
                color: root.theme.alpha(root.theme.surfaceContainer, 0.62)
                border.width: 1
                border.color: modelData.urgency === NotificationUrgency.Critical
                    ? root.theme.alpha(root.theme.error, 0.6)
                    : root.theme.alpha(root.theme.onSurface, 0.10)

                RowLayout {
                    id: content
                    anchors.fill: parent
                    anchors.margins: 11
                    spacing: 10

                    Rectangle {
                        width: 4
                        height: parent.height
                        radius: 2
                        color: modelData.urgency === NotificationUrgency.Critical
                            ? root.theme.error
                            : modelData.urgency === NotificationUrgency.Low
                                ? root.theme.outline
                                : root.theme.primary
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 3

                        Text {
                            Layout.fillWidth: true
                            text: modelData.appName || "Notificação"
                            color: root.theme.onSurfaceVariant
                            font.family: root.theme.fontFamily
                            font.pixelSize: 9
                            font.weight: Font.DemiBold
                            elide: Text.ElideRight
                        }

                        Text {
                            Layout.fillWidth: true
                            text: modelData.summary || ""
                            color: root.theme.onSurface
                            font.family: root.theme.fontFamily
                            font.pixelSize: 12
                            font.weight: Font.DemiBold
                            elide: Text.ElideRight
                        }

                        Text {
                            Layout.fillWidth: true
                            visible: modelData.body !== ""
                            text: modelData.body || ""
                            color: root.theme.onSurfaceVariant
                            font.family: root.theme.fontFamily
                            font.pixelSize: 10
                            wrapMode: Text.Wrap
                            maximumLineCount: 3
                            elide: Text.ElideRight
                        }
                    }

                    IconButton {
                        theme: root.theme
                        icon: "\uf00d"
                        danger: true
                        onClicked: root.notifications.dismiss(notificationRow.modelData)
                    }
                }
            }
        }

        Text {
            visible: root.notifications.count === 0
            Layout.fillWidth: true
            Layout.fillHeight: true
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            text: "Nenhuma notificação."
            color: root.theme.onSurfaceVariant
            font.family: root.theme.fontFamily
            font.pixelSize: 11
        }
    }
}
