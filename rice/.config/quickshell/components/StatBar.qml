import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: root

    required property var theme
    property string label: ""
    property string valueText: ""
    property real value: 0
    property color fillColor: theme.primary
    spacing: 6

    RowLayout {
        Layout.fillWidth: true
        spacing: 8

        Text {
            text: root.label
            color: root.theme.onSurfaceVariant
            font.family: root.theme.fontFamily
            font.pixelSize: root.theme.smallSize
            Layout.fillWidth: true
        }

        Text {
            text: root.valueText
            color: root.theme.onSurface
            font.family: root.theme.fontFamily
            font.pixelSize: root.theme.smallSize
            font.weight: Font.DemiBold
        }
    }

    Rectangle {
        Layout.fillWidth: true
        height: 5
        radius: 3
        color: root.theme.alpha(root.theme.onSurface, 0.10)

        Rectangle {
            width: parent.width * Math.max(0, Math.min(1, root.value))
            height: parent.height
            radius: parent.radius
            color: root.fillColor

            Behavior on width {
                NumberAnimation { duration: 220; easing.type: Easing.OutCubic }
            }
        }
    }
}
