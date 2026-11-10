import QtQuick
import Quickshell
import Quickshell.Io
import "core"
import "bar"
import "panels"
import "osd"
import "services"

ShellRoot {
    id: shell

    Theme { id: theme }
    State { id: state }
    Osd { id: osd }
    Audio { id: audio; osd: osd }
    Brightness { id: brightness; osd: osd }
    SystemStats { id: stats }
    Media { id: media }
    Notifications { id: notifications }
    Desktop { id: desktop }

    Variants {
        model: Quickshell.screens
        delegate: Bar {
            theme: theme
            state: state
            audio: audio
            stats: stats
            notifications: notifications
            media: media
        }
    }

    Variants {
        model: Quickshell.screens
        delegate: ControlCenter {
            theme: theme
            state: state
            audio: audio
            brightness: brightness
            stats: stats
            notifications: notifications
            media: media
            desktop: desktop
        }
    }

    Variants {
        model: Quickshell.screens
        delegate: OsdWindow {
            theme: theme
            osd: osd
        }
    }

        IpcHandler {
        target: "rice"

        function toggleControlCenter(): void {
            state.toggle();
        }

        function openControlCenter(): void {
            state.controlCenterOpen = true;
        }

        function closeControlCenter(): void {
            state.controlCenterOpen = false;
        }

        function toggleCalendar(): void {
            state.calendarOpen = !state.calendarOpen;
        }
    }

}
