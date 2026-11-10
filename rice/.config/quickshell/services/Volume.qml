import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: root

    property int volume: 0
    property bool muted: false
    readonly property string label: (muted ? "\uf026" : (volume > 50 ? "\uf028" : "\uf027")) + " " + volume + "%"

    function refresh() {
        proc.running = true;
    }

    property Process proc: Process {
        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]

        stdout: StdioCollector {
            onStreamFinished: {
                const match = text.match(/Volume:\s*([0-9.]+)(\s*\[MUTED\])?/);
                if (match) {
                    root.volume = Math.round(parseFloat(match[1]) * 100);
                    root.muted = match[2] !== undefined;
                }
            }
        }
    }

    property Timer timer: Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }
}
