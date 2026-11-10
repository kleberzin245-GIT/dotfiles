import QtQuick
import Quickshell
import Quickshell.Io

Text {
    id: root

    required property var theme
    property bool opened: false

    signal clicked()

    text: Qt.formatDateTime(clock.date, "dddd HH:mm")
    color: opened ? theme.primary : mouse.containsMouse ? theme.onSurface : theme.onSurface
    font.family: theme.fontFamily
    font.pixelSize: 13
    font.weight: Font.DemiBold

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }
}
