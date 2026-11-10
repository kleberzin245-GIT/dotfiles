import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: root

    readonly property string home: Quickshell.env("HOME")
    property var wallpapers: []
    property var styles: []
    property string currentWallpaper: ""
    property string mode: "dark"
    property int colorIndex: 0

    function refreshWallpapers() {
        if (!wallpaperLister.running)
            wallpaperLister.running = true;
    }

    function refreshStyles() {
        if (!styleLister.running)
            styleLister.running = true;
    }

    function refreshCurrent() {
        if (!currentReader.running)
            currentReader.running = true;
        if (!modeReader.running)
            modeReader.running = true;
        if (!indexReader.running)
            indexReader.running = true;
    }

    function runCommand(command) {
        if (runner.running)
            return;
        runner.command = command;
        runner.running = true;
    }

    function applyWallpaper(path) {
        if (!path)
            return;
        runCommand([root.home + "/.config/hypr/scripts/wallpaper.sh", path]);
        currentWallpaper = path;
    }

    function applyStyle(name) {
        if (!name)
            return;
        runCommand([root.home + "/.config/hypr/scripts/menu.sh", "--apply-style", name]);
    }

    function setMode(value) {
        if (value !== "dark" && value !== "light")
            return;
        mode = value;
        runCommand(["sh", "-c", "mkdir -p \"$HOME/.cache\"; printf '%s\\n' '" + value + "' > \"$HOME/.cache/matugen_mode\"; \"$HOME/.config/hypr/scripts/wallpaper.sh\" restore"]);
    }

    function setColorIndex(value) {
        const index = Math.max(0, Math.min(3, value));
        colorIndex = index;
        runCommand(["sh", "-c", "mkdir -p \"$HOME/.cache\"; printf '%s\\n' '" + index + "' > \"$HOME/.cache/matugen_index\"; \"$HOME/.config/hypr/scripts/wallpaper.sh\" restore"]);
    }

    property Process wallpaperLister: Process {
        command: ["sh", "-c", "find \"$HOME/Pictures/Wallpapers\" -maxdepth 1 -type f \\( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \\) -printf '%p\\t%f\\n' | sort"]

        stdout: StdioCollector {
            onStreamFinished: {
                const result = [];
                const lines = text.trim().split("\n");
                for (let i = 0; i < lines.length; i++) {
                    if (lines[i] === "")
                        continue;
                    const parts = lines[i].split("\t");
                    result.push({ path: parts[0], name: parts.length > 1 ? parts[1] : parts[0] });
                }
                root.wallpapers = result;
            }
        }
    }

    property Process styleLister: Process {
        command: ["python3", "-c", "import glob,json,os; d=os.path.expanduser('~/.config/rice/styles'); out=[];\nfor f in sorted(glob.glob(d+'/*.json')):\n    try: out.append(json.load(open(f)))\n    except Exception: pass\nprint(json.dumps(out))"]

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    root.styles = JSON.parse(text.trim());
                } catch (error) {
                    root.styles = [];
                }
            }
        }
    }

    property Process currentReader: Process {
        command: ["sh", "-c", "cat \"$HOME/.cache/current_wallpaper\" 2>/dev/null || true"]

        stdout: StdioCollector {
            onStreamFinished: root.currentWallpaper = text.trim()
        }
    }

    property Process modeReader: Process {
        command: ["sh", "-c", "cat \"$HOME/.cache/matugen_mode\" 2>/dev/null || echo dark"]

        stdout: StdioCollector {
            onStreamFinished: root.mode = text.trim() || "dark"
        }
    }

    property Process indexReader: Process {
        command: ["sh", "-c", "cat \"$HOME/.cache/matugen_index\" 2>/dev/null || echo 0"]

        stdout: StdioCollector {
            onStreamFinished: root.colorIndex = parseInt(text.trim(), 10) || 0
        }
    }

    property Process runner: Process {
        command: []
        onExited: root.refreshCurrent()
    }

    Component.onCompleted: {
        refreshWallpapers();
        refreshStyles();
        refreshCurrent();
    }

    property Timer timer: Timer {
        interval: 15000
        running: true
        repeat: true
        onTriggered: root.refreshCurrent()
    }
}
