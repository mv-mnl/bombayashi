pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

// Visualizador de audio: corre cava solo mientras hay música sonando
Singleton {
    id: root

    property var bars: new Array(24).fill(0)

    Process {
        running: Media.playing
        command: ["cava", "-p", Quickshell.shellPath("cava.conf")]
        onRunningChanged: if (!running) root.bars = new Array(24).fill(0)
        stdout: SplitParser {
            onRead: data => {
                const v = data.split(";").filter(s => s.length > 0).map(Number);
                if (v.length > 0) root.bars = v;
            }
        }
    }
}
