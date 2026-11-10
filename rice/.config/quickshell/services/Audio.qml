import QtQuick
import Quickshell.Services.Pipewire

QtObject {
    id: root

    property var osd: null
    property int tick: 0
    property bool seen: false

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var source: Pipewire.defaultAudioSource
    readonly property var audio: sink && sink.audio ? sink.audio : null
    readonly property int volume: audio ? Math.round(audio.volume * 100) : 0
    readonly property bool muted: audio ? audio.muted : false
    readonly property string sinkName: sink ? (sink.description || sink.nickname || "Saída padrão") : ""
    readonly property string sourceName: source ? (source.description || source.nickname || "Entrada padrão") : ""

    readonly property var sinks: {
        root.tick;
        return Pipewire.nodes.values.filter(node => node.isSink && !node.isStream);
    }

    readonly property var sources: {
        root.tick;
        return Pipewire.nodes.values.filter(node => !node.isSink && !node.isStream && node.audio);
    }

    function setVolume(value) {
        if (!audio)
            return;
        const clamped = Math.max(0, Math.min(1, value));
        audio.volume = clamped;
        if (osd)
            osd.showVolume(Math.round(clamped * 100), audio.muted);
    }

    function toggleMute() {
        if (!audio)
            return;
        audio.muted = !audio.muted;
        if (osd)
            osd.showVolume(root.volume, audio.muted);
    }

    function setSink(node) {
        if (node)
            Pipewire.preferredDefaultAudioSink = node;
    }

    function setSource(node) {
        if (node)
            Pipewire.preferredDefaultAudioSource = node;
    }

    onVolumeChanged: {
        if (seen && osd)
            osd.showVolume(volume, muted);
    }

    onMutedChanged: {
        if (seen && osd)
            osd.showVolume(volume, muted);
    }

    property PwObjectTracker tracker: PwObjectTracker {
        objects: {
            const nodes = [];
            if (Pipewire.defaultAudioSink)
                nodes.push(Pipewire.defaultAudioSink);
            if (Pipewire.defaultAudioSource)
                nodes.push(Pipewire.defaultAudioSource);
            return nodes;
        }
    }

    property Timer tickTimer: Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: root.tick++
    }

    property Timer readyTimer: Timer {
        interval: 1600
        running: true
        onTriggered: root.seen = true
    }
}
