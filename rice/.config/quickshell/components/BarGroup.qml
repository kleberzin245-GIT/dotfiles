import QtQuick
import QtQuick.Layouts

Item {
    id: root

    required property var theme
    property bool glass: false
    property real spacing: 6
    property real horizontalPadding: glass ? 12 : 0
    property real verticalPadding: glass ? 5 : 0

    default property alias content: row.data

    implicitWidth: row.implicitWidth + horizontalPadding * 2
    implicitHeight: row.implicitHeight + verticalPadding * 2

    Rectangle {
        anchors.fill: parent
        visible: root.glass
        radius: root.theme.barRadius
        color: root.theme.alpha(root.theme.surface, 0.42)
        border.width: 1
        border.color: root.theme.alpha(root.theme.onSurface, 0.14)
    }

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: root.spacing
    }
}
