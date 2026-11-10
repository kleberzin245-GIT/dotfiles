import QtQuick

Item {
    id: root

    required property var theme
    required property var media
    required property var state

    visible: media.hasPlayer
    implicitWidth: row.implicitWidth
    implicitHeight: 20

    Row {
        id: row
        anchors.verticalCenter: parent.verticalCenter
        spacing: 6

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: root.media.playing ? "\uf04c" : "\uf04b"
            color: mouse.containsMouse ? root.theme.primary : root.theme.onSurfaceVariant
            font.family: root.theme.fontFamily
            font.pixelSize: 11
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            width: Math.min(implicitWidth, 210)
            text: {
                if (!root.media.hasPlayer)
                    return "";
                if (root.media.artist !== "")
                    return root.media.artist + " — " + root.media.title;
                return root.media.title;
            }
            color: root.theme.onSurface
            elide: Text.ElideRight
            font.family: root.theme.fontFamily
            font.pixelSize: 11
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        cursorShape: Qt.PointingHandCursor
        onClicked: (event) => {
            if (event.button === Qt.RightButton)
                root.state.open("media");
            else
                root.media.toggle();
        }
    }
}
