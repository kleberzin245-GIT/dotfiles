import QtQuick

Item {
    id: root

    required property var theme
    property real value: 0
    property color fillColor: theme.primary
    property bool enabled: true

    property bool dragging: false
    property real dragValue: 0

    readonly property real shownValue: dragging ? dragValue : Math.max(0, Math.min(1, value))
    readonly property real knobSize: 16

    signal dragged(real value)
    signal moved(real value)

    implicitHeight: 26
    opacity: enabled ? 1 : 0.4

    function valueAt(x) {
        const usable = Math.max(1, width - knobSize);
        return Math.max(0, Math.min(1, (x - knobSize / 2) / usable));
    }

    Rectangle {
        id: track
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        height: 5
        radius: 3
        color: root.theme.alpha(root.theme.onSurface, 0.12)

        Rectangle {
            width: Math.max(0, track.width * root.shownValue)
            height: parent.height
            radius: parent.radius
            color: root.enabled ? root.fillColor : root.theme.outline
        }
    }

    Rectangle {
        width: root.knobSize
        height: root.knobSize
        radius: root.knobSize / 2
        anchors.verticalCenter: parent.verticalCenter
        x: Math.max(0, Math.min(parent.width - width, root.shownValue * (parent.width - width)))
        color: root.enabled ? root.theme.onSurface : root.theme.outline
        border.width: 2
        border.color: root.enabled ? root.fillColor : root.theme.outline

        Behavior on x {
            enabled: !root.dragging
            NumberAnimation { duration: 90 }
        }
    }

    MouseArea {
        anchors.fill: parent
        enabled: root.enabled
        cursorShape: Qt.PointingHandCursor

        onPressed: (mouse) => {
            root.dragging = true;
            root.dragValue = root.valueAt(mouse.x);
            root.dragged(root.dragValue);
        }
        onPositionChanged: (mouse) => {
            if (!root.dragging)
                return;
            root.dragValue = root.valueAt(mouse.x);
            root.dragged(root.dragValue);
        }
        onReleased: {
            root.dragging = false;
            root.moved(root.dragValue);
        }
        onCanceled: root.dragging = false
    }
}
