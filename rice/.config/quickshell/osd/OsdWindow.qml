import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: root

    required property var theme
    required property var osd
    required property var modelData

    screen: modelData
    anchors {
        bottom: true
    }
    margins { bottom: 44 }
    implicitWidth: 300
    implicitHeight: 58
    visible: osd.visible
    color: "transparent"

    Component.onCompleted: {
        if (WlrLayershell != null)
            WlrLayershell.namespace = "quickshell-osd";
    }
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    Rectangle {
        anchors.fill: parent
        radius: root.theme.panelRadius
        color: root.theme.alpha(root.theme.surface, 0.94)
        border.width: 1
        border.color: root.theme.alpha(root.theme.onSurface, 0.14)

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 16
            anchors.rightMargin: 16
            spacing: 12

            Text {
                text: root.osd.kind === "brightness"
                    ? "\uf185"
                    : root.osd.muted
                        ? "\uf026"
                        : root.osd.value > 50
                            ? "\uf028"
                            : "\uf027"
                color: root.theme.primary
                font.family: root.theme.fontFamily
                font.pixelSize: 17
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 5

                Rectangle {
                    Layout.fillWidth: true
                    height: 6
                    radius: 3
                    color: root.theme.alpha(root.theme.onSurface, 0.12)

                    Rectangle {
                        width: parent.width * Math.max(0, Math.min(1, root.osd.value / 100))
                        height: parent.height
                        radius: parent.radius
                        color: root.osd.muted ? root.theme.error : root.theme.primary

                        Behavior on width {
                            NumberAnimation { duration: 100 }
                        }
                    }
                }

                Text {
                    text: root.osd.muted ? "Mudo" : root.osd.value + "%"
                    color: root.theme.onSurfaceVariant
                    font.family: root.theme.fontFamily
                    font.pixelSize: 9
                }
            }
        }
    }
}
