import QtQuick

Item {
    id: root

    required property var theme
    property bool checked: false
    property bool enabled: true
    signal toggled(bool value)

    implicitWidth: 42
    implicitHeight: 24
    opacity: enabled ? 1 : 0.4

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: root.checked
            ? root.theme.alpha(root.theme.primary, 0.75)
            : root.theme.alpha(root.theme.surfaceContainerHigh, 0.9)
        border.width: 1
        border.color: root.checked
            ? root.theme.alpha(root.theme.primary, 0.9)
            : root.theme.alpha(root.theme.onSurface, 0.12)

        Behavior on color {
            ColorAnimation { duration: 130 }
        }

        Rectangle {
            width: 18
            height: 18
            radius: 9
            y: 3
            x: root.checked ? parent.width - width - 3 : 3
            color: root.checked ? root.theme.onPrimary : root.theme.onSurface

            Behavior on x {
                NumberAnimation { duration: 130; easing.type: Easing.OutCubic }
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        enabled: root.enabled
        onClicked: root.toggled(!root.checked)
    }
}
