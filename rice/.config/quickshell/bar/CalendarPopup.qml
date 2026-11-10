import QtQuick
import QtQuick.Layouts
import Quickshell
import "../components"

PopupWindow {
    id: root

    required property var theme
    required property var state
    required property var window
    required property var anchorItem

    visible: state.calendarOpen
    implicitWidth: 304
    implicitHeight: 356
    color: "transparent"

    anchor.window: window
    anchor.item: anchorItem
    anchor.rect.y: anchorItem.height + 8
    anchor.rect.x: anchorItem.width / 2 - implicitWidth / 2

    property date today: new Date()
    property int viewYear: today.getFullYear()
    property int viewMonth: today.getMonth()

    readonly property var monthDate: new Date(viewYear, viewMonth, 1)
    readonly property string monthLabel: {
        const raw = Qt.formatDate(monthDate, "MMMM yyyy");
        return raw.charAt(0).toUpperCase() + raw.slice(1);
    }
    readonly property int firstWeekday: new Date(viewYear, viewMonth, 1).getDay()
    readonly property int daysInMonth: new Date(viewYear, viewMonth + 1, 0).getDate()

    function resetToToday() {
        today = new Date();
        viewYear = today.getFullYear();
        viewMonth = today.getMonth();
    }

    function dayAt(index) {
        const day = index - firstWeekday + 1;
        return day >= 1 && day <= daysInMonth ? day : 0;
    }

    function isToday(day) {
        return day === today.getDate() && viewMonth === today.getMonth() && viewYear === today.getFullYear();
    }

    function previousMonth() {
        if (viewMonth === 0) {
            viewMonth = 11;
            viewYear -= 1;
        } else {
            viewMonth -= 1;
        }
    }

    function nextMonth() {
        if (viewMonth === 11) {
            viewMonth = 0;
            viewYear += 1;
        } else {
            viewMonth += 1;
        }
    }

    onVisibleChanged: {
        if (visible)
            resetToToday();
    }

    Rectangle {
        anchors.fill: parent
        radius: root.theme.panelRadius
        color: root.theme.alpha(root.theme.surface, 0.96)
        border.width: 1
        border.color: root.theme.alpha(root.theme.onSurface, 0.13)

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            RowLayout {
                Layout.fillWidth: true

                IconButton {
                    theme: root.theme
                    icon: "\uf053"
                    onClicked: root.previousMonth()
                }

                Text {
                    Layout.fillWidth: true
                    text: root.monthLabel
                    color: root.theme.onSurface
                    font.family: root.theme.fontFamily
                    font.pixelSize: 14
                    font.weight: Font.DemiBold
                    horizontalAlignment: Text.AlignHCenter
                }

                IconButton {
                    theme: root.theme
                    icon: "\uf054"
                    onClicked: root.nextMonth()
                }
            }

            Grid {
                Layout.fillWidth: true
                columns: 7
                columnSpacing: 2
                rowSpacing: 2

                Repeater {
                    model: ["D", "S", "T", "Q", "Q", "S", "S"]

                    delegate: Item {
                        required property var modelData
                        width: 38
                        height: 24

                        Text {
                            anchors.centerIn: parent
                            text: modelData
                            color: root.theme.onSurfaceVariant
                            font.family: root.theme.fontFamily
                            font.pixelSize: 10
                            font.weight: Font.DemiBold
                        }
                    }
                }
            }

            Grid {
                Layout.fillWidth: true
                Layout.fillHeight: true
                columns: 7
                columnSpacing: 2
                rowSpacing: 2

                Repeater {
                    model: 42

                    delegate: Item {
                        id: cell
                        required property int index
                        readonly property int day: root.dayAt(index)
                        width: 38
                        height: 32

                        Rectangle {
                            anchors.fill: parent
                            radius: 8
                            color: cell.day > 0 && root.isToday(cell.day)
                                ? root.theme.primary
                                : "transparent"

                            Text {
                                anchors.centerIn: parent
                                visible: cell.day > 0
                                text: cell.day
                                color: root.isToday(cell.day)
                                    ? root.theme.onPrimary
                                    : root.theme.onSurface
                                font.family: root.theme.fontFamily
                                font.pixelSize: 11
                                font.weight: root.isToday(cell.day) ? Font.Bold : Font.Normal
                            }
                        }
                    }
                }
            }

            Text {
                Layout.fillWidth: true
                text: Qt.formatDate(root.today, "dddd, d 'de' MMMM")
                color: root.theme.onSurfaceVariant
                font.family: root.theme.fontFamily
                font.pixelSize: 10
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }
}
