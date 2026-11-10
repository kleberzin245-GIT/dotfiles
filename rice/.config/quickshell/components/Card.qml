import QtQuick

Rectangle {
    id: root

    required property var theme
    property color tint: theme.surfaceContainer
    property real tintAlpha: 0.55
    property int padding: 14
    property int borderWidth: 1

    default property alias content: content.data

    implicitHeight: content.childrenRect.height + padding * 2
    radius: theme.panelRadius
    color: theme.alpha(tint, tintAlpha)
    border.width: borderWidth
    border.color: theme.alpha(theme.onSurface, 0.10)

    Item {
        id: content
        anchors.fill: parent
        anchors.margins: root.padding
    }
}
