import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: root

    property var colors: ({})
    property var style: ({})

    readonly property string stateDir: (Quickshell.env("XDG_STATE_HOME") || (Quickshell.env("HOME") + "/.local/state")) + "/rice"
    readonly property var s: style && style.quickshell ? style.quickshell : ({})

    readonly property string styleId: style && style.id ? style.id : "padrao"
    readonly property string styleName: style && style.name ? style.name : "Padrão"
    readonly property bool glass: styleId === "glass"
    readonly property bool sharp: styleId === "omarchy"

    readonly property color primary: colors.primary ? colors.primary : "#cba6f7"
    readonly property color onPrimary: colors.on_primary ? colors.on_primary : "#1e1e2e"
    readonly property color primaryContainer: colors.primary_container ? colors.primary_container : "#45475a"
    readonly property color onPrimaryContainer: colors.on_primary_container ? colors.on_primary_container : "#cdd6f4"
    readonly property color secondary: colors.secondary ? colors.secondary : "#89b4fa"
    readonly property color tertiary: colors.tertiary ? colors.tertiary : "#94e2d5"
    readonly property color error: colors.error ? colors.error : "#f38ba8"
    readonly property color surface: colors.surface ? colors.surface : "#1e1e2e"
    readonly property color surfaceContainer: colors.surface_container ? colors.surface_container : "#313244"
    readonly property color surfaceContainerHigh: colors.surface_container_high ? colors.surface_container_high : "#45475a"
    readonly property color onSurface: colors.on_surface ? colors.on_surface : "#cdd6f4"
    readonly property color onSurfaceVariant: colors.on_surface_variant ? colors.on_surface_variant : "#a6adc8"
    readonly property color outline: colors.outline ? colors.outline : "#6c7086"
    readonly property color outlineVariant: colors.outline_variant ? colors.outline_variant : "#585b70"

    readonly property real barHeight: s.bar_height !== undefined ? s.bar_height : 34
    readonly property real barMarginTop: s.bar_margin_top !== undefined ? s.bar_margin_top : 8
    readonly property real barMarginX: s.bar_margin_x !== undefined ? s.bar_margin_x : 12
    readonly property real barRadius: s.bar_radius !== undefined ? s.bar_radius : 14
    readonly property real panelRadius: s.panel_radius !== undefined ? s.panel_radius : 16
    readonly property real panelMargin: s.panel_margin !== undefined ? s.panel_margin : 12
    readonly property bool blur: s.blur !== undefined ? s.blur : true
    readonly property real barOpacity: style.waybar && style.waybar.opacity !== undefined ? style.waybar.opacity : 0.5

    readonly property string fontFamily: "JetBrainsMono Nerd Font"
    readonly property int fontSize: 13
    readonly property int smallSize: 11
    readonly property int largeSize: 18

    function alpha(color, value) {
        return Qt.rgba(color.r, color.g, color.b, value);
    }

    function parse(raw) {
        try {
            return JSON.parse(raw);
        } catch (error) {
            return {};
        }
    }

    property FileView colorsFile: FileView {
        path: root.stateDir + "/quickshell/colors.json"
        watchChanges: true
        onTextChanged: root.colors = root.parse(text())
    }

    property FileView styleFile: FileView {
        path: root.stateDir + "/style.json"
        watchChanges: true
        onTextChanged: root.style = root.parse(text())
    }
}
