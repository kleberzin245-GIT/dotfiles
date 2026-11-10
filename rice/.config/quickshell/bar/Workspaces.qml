import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland

RowLayout {
    id: root

    required property var theme
    spacing: 4

    Repeater {
        model: Hyprland.workspaces

        delegate: Rectangle {
            id: item

            required property var modelData

            implicitWidth: 18
            implicitHeight: 18
            radius: root.theme.sharp ? 0 : 9
            color: modelData.focused
                ? root.theme.primary
                : root.theme.alpha(root.theme.onSurface, modelData.active ? 0.12 : 0.04)
            border.width: modelData.focused ? 0 : 1
            border.color: modelData.focused
                ? "transparent"
                : root.theme.alpha(root.theme.onSurface, 0.28)

            Behavior on color {
                ColorAnimation { duration: 120 }
            }

            Text {
                anchors.centerIn: parent
                text: modelData.id
                color: modelData.focused ? root.theme.onPrimary : root.theme.onSurface
                font.family: root.theme.fontFamily
                font.pixelSize: 10
                font.weight: modelData.focused ? Font.Bold : Font.Normal
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: Hyprland.dispatch("workspace " + modelData.id)
            }
        }
    }
}
