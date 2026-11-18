pragma Singleton
import Quickshell
import Quickshell.Services.Mpris
import QtQuick

// Reproductor MPRIS "activo": el que esté sonando, o el primero que haya
Singleton {
    id: root

    readonly property var player: {
        const ps = Mpris.players.values;
        for (const p of ps) if (p.isPlaying) return p;
        return ps.length > 0 ? ps[0] : null;
    }
    readonly property bool active: player !== null && (player.trackTitle ?? "") !== ""
    readonly property bool playing: player?.isPlaying ?? false
    readonly property string title: player?.trackTitle ?? ""
    readonly property string artist: player?.trackArtist ?? ""
    readonly property string art: player?.trackArtUrl ?? ""
    readonly property real progress: (player && player.length > 0) ? Math.min(1, player.position / player.length) : 0

    function fmt(secs) {
        if (!secs || secs < 0) return "0:00";
        const m = Math.floor(secs / 60), s = Math.floor(secs % 60);
        return m + ":" + (s < 10 ? "0" : "") + s;
    }

    // MPRIS no notifica la posición mientras avanza: hay que pedirla
    Timer {
        running: root.playing; interval: 1000; repeat: true
        onTriggered: root.player.positionChanged()
    }
}
