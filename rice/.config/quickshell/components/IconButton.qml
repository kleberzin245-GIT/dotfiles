import QtQuick

Item {
    id: root

    required property var theme
    property string icon: ""
    property string suffix: ""
    property bool active: false
    property bool dim: false
    property bool danger: false
    property int badge: 0
    signal clicked()

    implicitWidth: 28
    implicitHeight: 28

    Rectangle {
        anchors.fill: parent
        radius: 8
        color: root.active
            ? root.theme.alpha(root.danger ? root.theme.error : root.theme.primary, 0.16)
            : mouse.containsMouse
                ? root.theme.alpha(root.theme.onSurface, 0.08)
                : "transparent"
    }

    Text {
        anchors.centerIn: parent
        text: root.icon + (root.suffix !== "" ? " " + root.suffix : "")
        color: root.danger
            ? root.theme.error
            : root.dim
                ? root.theme.alpha(root.theme.onSurface, 0.42)
                : root.active
                    ? root.theme.primary
                    : root.theme.onSurface
        font.family: root.theme.fontFamily
        font.pixelSize: root.suffix !== "" ? 10 : 14
        font.weight: root.active ? Font.DemiBold : Font.Normal
    }

    Rectangle {
        visible: root.badge > 0
        width: 14
        height: 14
        radius: 7
        anchors.right: parent.right
        anchors.top: parent.top
        color: root.theme.error

        Text {
            anchors.centerIn: parent
            text: root.badge > 9 ? "9+" : root.badge
            color: root.theme.onPrimary
            font.family: root.theme.fontFamily
            font.pixelSize: 8
            font.weight: Font.Bold
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
