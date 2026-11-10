import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets

Row {
    id: root

    required property var theme
    property var window: null
    spacing: 6

    Repeater {
        model: SystemTray.items

        delegate: Item {
            id: trayItem

            required property var modelData

            implicitWidth: 18
            implicitHeight: 18
            opacity: modelData.status === Status.Passive ? 0.62 : 1

            IconImage {
                anchors.centerIn: parent
                implicitSize: 15
                source: Quickshell.iconPath(modelData.icon, true)
            }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                cursorShape: Qt.PointingHandCursor
                onClicked: (event) => {
                    if (event.button === Qt.RightButton && trayItem.modelData.hasMenu)
                        trayItem.modelData.display(root.window, event.x, event.y);
                    else
                        trayItem.modelData.activate();
                }
            }
        }
    }
}
