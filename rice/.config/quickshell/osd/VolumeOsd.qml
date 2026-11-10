import QtQuick
import Quickshell

PanelWindow {
    id: root

    required property var theme
    required property var modelData

    screen: modelData
    anchors {
        bottom: true
        left: true
        right: true
    }
    margins { bottom: 48 }
    implicitHeight: 48
    visible: false
    color: "transparent"

    Rectangle {
        anchors.centerIn: parent
        width: 220
        height: 40
        radius: 20
        color: theme.alpha(theme.surface, 0.92)
        border.width: 1
        border.color: theme.alpha(theme.onSurface, 0.12)

        Text {
            anchors.centerIn: parent
            text: "Volume"
            color: theme.onSurface
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 13
        }
    }
}
