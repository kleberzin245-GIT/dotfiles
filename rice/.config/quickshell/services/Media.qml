import QtQuick
import Quickshell.Services.Mpris

QtObject {
    id: root

    property var player: null
    property var players: []

    readonly property bool hasPlayer: player !== null
    readonly property bool playing: player ? player.isPlaying : false
    readonly property string title: player ? (player.trackTitle || player.identity || "") : ""
    readonly property string artist: player ? (player.trackArtist || "") : ""
    readonly property string album: player ? (player.trackAlbum || "") : ""
    readonly property string artUrl: player ? (player.trackArtUrl || "") : ""
    readonly property bool canNext: player ? player.canGoNext : false
    readonly property bool canPrevious: player ? player.canGoPrevious : false
    readonly property bool canToggle: player ? player.canTogglePlaying : false
    readonly property real position: player ? player.position : 0
    readonly property real length: player ? player.length : 0

    function refresh() {
        const list = Mpris.players.values;
        if (list.length !== players.length) {
            players = list;
        }
        const active = list.find(item => item.isPlaying) || list[0] || null;
        if (active !== player)
            player = active;
    }

    function toggle() {
        if (player && player.canTogglePlaying)
            player.togglePlaying();
    }

    function next() {
        if (player && player.canGoNext)
            player.next();
    }

    function previous() {
        if (player && player.canGoPrevious)
            player.previous();
    }

    function seek(position) {
        if (player && player.canSeek)
            player.seek(position);
    }

    property Timer timer: Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }
}
