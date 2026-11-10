import QtQuick

Rectangle {
    id: root

    required property var theme
    property string icon: ""
    property string label: ""
    property bool active: false
    property bool danger: false
    property bool compact: false
    property bool enabled: true
    signal clicked()

    implicitWidth: row.implicitWidth + (compact ? 16 : 22)
    implicitHeight: compact ? 26 : 32
    radius: height / 2
    opacity: enabled ? 1 : 0.45
    color: !enabled
        ? theme.alpha(theme.surfaceContainerHigh, 0.25)
        : danger
            ? theme.alpha(theme.error, active ? 0.32 : 0.14)
            : active
                ? theme.alpha(theme.primary, 0.22)
                : mouse.containsMouse
                    ? theme.alpha(theme.onSurface, 0.10)
                    : theme.alpha(theme.surfaceContainerHigh, 0.55)
    border.width: 1
    border.color: active
        ? theme.alpha(danger ? theme.error : theme.primary, 0.65)
        : theme.alpha(theme.onSurface, 0.10)

    Behavior on color {
        ColorAnimation { duration: 120 }
    }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 6

        Text {
            visible: root.icon !== ""
            anchors.verticalCenter: parent.verticalCenter
            text: root.icon
            color: root.danger ? root.theme.error : root.theme.onSurface
            font.family: root.theme.fontFamily
            font.pixelSize: root.compact ? 11 : 12
        }

        Text {
            visible: root.label !== ""
            anchors.verticalCenter: parent.verticalCenter
            text: root.label
            color: root.danger ? root.theme.error : root.theme.onSurface
            font.family: root.theme.fontFamily
            font.pixelSize: root.compact ? 11 : 12
            font.weight: root.active ? Font.DemiBold : Font.Normal
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        enabled: root.enabled
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
