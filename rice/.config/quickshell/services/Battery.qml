import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: root

    property int capacity: -1
    property string status: ""
    readonly property string label: capacity < 0 ? "" : (status === "Charging" ? "\uf0e7 " : "") + capacity + "%"

    function refresh() {
        proc.running = true;
    }

    property Process proc: Process {
        command: ["sh", "-c", "for b in /sys/class/power_supply/BAT*; do [ -r \"$b/capacity\" ] && cat \"$b/capacity\" \"$b/status\"; done"]

        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.trim().split(/\s+/);
                if (lines.length >= 2) {
                    root.capacity = parseInt(lines[0], 10);
                    root.status = lines[1];
                }
            }
        }
    }

    property Timer timer: Timer {
        interval: 30000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }
}
