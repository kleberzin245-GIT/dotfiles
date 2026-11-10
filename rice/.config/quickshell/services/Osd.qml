import QtQuick

QtObject {
    id: root

    property bool visible: false
    property string kind: "volume"
    property int value: 0
    property bool muted: false

    function showVolume(volume, muted) {
        root.kind = "volume";
        root.value = volume;
        root.muted = muted;
        root.visible = true;
        hideTimer.restart();
    }

    function showBrightness(brightness) {
        root.kind = "brightness";
        root.value = brightness;
        root.muted = false;
        root.visible = true;
        hideTimer.restart();
    }

    property Timer hideTimer: Timer {
        interval: 1500
        onTriggered: root.visible = false
    }
}
