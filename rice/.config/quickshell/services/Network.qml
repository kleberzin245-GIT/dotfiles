import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: root

    property string ssid: ""
    property string state: ""
    readonly property string label: ssid !== "" ? "\uf1eb" : (state === "connected" ? "\udb80\ude00" : "\uf071")

    function refresh() {
        proc.running = true;
    }

    property Process proc: Process {
        command: ["sh", "-c", "nmcli -t -f ACTIVE,SSID dev wifi 2>/dev/null | sed -n 's/^yes://p' | head -n1; nmcli -t -f STATE general 2>/dev/null"]

        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.trim().split("\n");
                root.ssid = lines.length > 0 ? lines[0] : "";
                root.state = lines.length > 1 ? lines[1] : "";
            }
        }
    }

    property Timer timer: Timer {
        interval: 10000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }
}
