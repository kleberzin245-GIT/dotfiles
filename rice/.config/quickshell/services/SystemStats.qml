import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: root

    property int cpuPercent: 0
    property int memPercent: 0
    property real memUsedGb: 0
    property real memTotalGb: 0
    property real temp: -1
    property real diskUsedGb: 0
    property real diskTotalGb: 0
    property int diskPercent: 0
    property real load1: 0
    property int uptimeSeconds: 0

    property real _prevIdle: -1
    property real _prevTotal: -1

    readonly property string uptimeText: {
        const total = Math.max(0, uptimeSeconds);
        const days = Math.floor(total / 86400);
        const hours = Math.floor((total % 86400) / 3600);
        const minutes = Math.floor((total % 3600) / 60);
        if (days > 0)
            return days + "d " + hours + "h";
        if (hours > 0)
            return hours + "h " + minutes + "m";
        return minutes + "m";
    }

    function refresh() {
        if (!proc.running)
            proc.running = true;
    }

    property Process proc: Process {
        command: ["sh", "-c", "printf 'STAT '; head -n1 /proc/stat; printf 'MEM '; grep -E '^(MemTotal|MemAvailable):' /proc/meminfo | tr '\\n' ' '; echo; printf 'LOAD '; cat /proc/loadavg; printf 'UP '; cut -d' ' -f1 /proc/uptime; printf 'TEMP '; for z in /sys/class/thermal/thermal_zone*/temp; do cat \"$z\" 2>/dev/null; done | sort -n | tail -n1; printf '\\nDF '; df -B1 --output=used,size / | tail -n1"]

        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.trim().split("\n");
                for (let i = 0; i < lines.length; i++) {
                    const line = lines[i];
                    if (line.startsWith("STAT ")) {
                        const parts = line.substring(5).trim().split(/\s+/).slice(1).map(Number);
                        if (parts.length >= 4) {
                            const total = parts.reduce((sum, value) => sum + (isNaN(value) ? 0 : value), 0);
                            const idle = parts[3] + (parts[4] || 0);
                            if (root._prevTotal >= 0 && total > root._prevTotal) {
                                root.cpuPercent = Math.round((1 - (idle - root._prevIdle) / (total - root._prevTotal)) * 100);
                            }
                            root._prevIdle = idle;
                            root._prevTotal = total;
                        }
                    } else if (line.startsWith("MEM ")) {
                        const totalMatch = line.match(/MemTotal:\s+(\d+)/);
                        const availableMatch = line.match(/MemAvailable:\s+(\d+)/);
                        if (totalMatch && availableMatch) {
                            const totalKb = parseInt(totalMatch[1], 10);
                            const availableKb = parseInt(availableMatch[1], 10);
                            root.memTotalGb = totalKb / 1048576;
                            root.memUsedGb = (totalKb - availableKb) / 1048576;
                            root.memPercent = Math.round((1 - availableKb / totalKb) * 100);
                        }
                    } else if (line.startsWith("LOAD ")) {
                        root.load1 = parseFloat(line.substring(5).trim().split(/\s+/)[0]) || 0;
                    } else if (line.startsWith("UP ")) {
                        root.uptimeSeconds = Math.round(parseFloat(line.substring(3).trim())) || 0;
                    } else if (line.startsWith("TEMP ")) {
                        const tempValue = parseFloat(line.substring(5).trim());
                        root.temp = isNaN(tempValue) ? -1 : tempValue / 1000;
                    } else if (line.startsWith("DF ")) {
                        const df = line.substring(3).trim().split(/\s+/).map(Number);
                        if (df.length >= 2 && df[1] > 0) {
                            root.diskUsedGb = df[0] / 1073741824;
                            root.diskTotalGb = df[1] / 1073741824;
                            root.diskPercent = Math.round((df[0] / df[1]) * 100);
                        }
                    }
                }
            }
        }
    }

    property Timer timer: Timer {
        interval: 3000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }
}
