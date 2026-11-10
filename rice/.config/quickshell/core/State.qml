import QtQuick

QtObject {
    id: root

    property bool controlCenterOpen: false
    property bool calendarOpen: false
    property string page: "connectivity"

    function open(pageId) {
        if (pageId && pageId.length > 0)
            root.page = pageId;
        root.calendarOpen = false;
        root.controlCenterOpen = true;
    }

    function toggle() {
        root.controlCenterOpen = !root.controlCenterOpen;
    }
}
