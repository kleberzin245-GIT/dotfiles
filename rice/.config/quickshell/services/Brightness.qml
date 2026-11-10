import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: root

    property var osd: null
    property bool available: false
    property bool seen: false
    property bool applying: false
    property int percent: 0
    property string device: ""

    function setPercent(value) {
        if (!available)
            return;
        const clamped = Math.max(1, Math.min(100, Math.round(value)));
        root.percent = clamped;
        if (osd)
            osd.showBrightness(clamped);
        applying = true;
        setter.command = ["brightnessctl", "set", clamped + "%"];
        setter.running = true;
    }

    function refresh() {
        if (!reader.running)
            reader.running = true;
    }

    onPercentChanged: {
        if (seen && !applying && osd)
            osd.showBrightness(percent);
    }

    property Process reader: Process {
        command: ["sh", "-c", "brightnessctl -m 2>/dev/null | head -n1"]

        stdout: StdioCollector {
            onStreamFinished: {
                const parts = text.trim().split(",");
                if (parts.length < 4)
                    return;
                root.device = parts[0];
                const parsed = parseInt(String(parts[3]).replace("%", ""), 10);
                if (!isNaN(parsed))
                    root.percent = parsed;
                root.available = true;
                root.seen = true;
            }
        }
    }

    property Process setter: Process {
        command: []
        onExited: {
            root.applying = false;
            root.refresh();
        }
    }

    property Timer timer: Timer {
        interval: 2500
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }
}
