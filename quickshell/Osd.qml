pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

// OSD de volumen/brillo que se muestra dentro de la isla.
// Se dispara desde fuera con:  qs ipc call osd volume | brightness
Singleton {
    id: root

    property string kind: "volume"
    property bool shown: false

    readonly property int value: kind === "volume" ? Stats.volume : Stats.brightness
    readonly property string icon: {
        if (kind === "brightness") return "󰃠";
        if (Stats.muted || Stats.volume === 0) return "󰝟";
        return Stats.volume < 40 ? "󰕿" : Stats.volume < 75 ? "󰖀" : "󰕾";
    }

    function show(k) {
        kind = k;
        Stats.refreshLevels();
        shown = true;
        hideTimer.restart();
    }

    Timer { id: hideTimer; interval: 1800; onTriggered: root.shown = false }

    // Abrir/cerrar la isla:  qs ipc call island toggle
    signal toggleIsland

    IpcHandler {
        target: "island"
        function toggle(): void { root.toggleIsland() }
    }

    IpcHandler {
        target: "osd"
        function volume(): void { root.show("volume") }
        function brightness(): void { root.show("brightness") }
    }
}
