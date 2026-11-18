pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

// Métricas del sistema: CPU, RAM, red, temperatura, disco, GPU, volumen y brillo
Singleton {
    id: root

    property int cpu: 0
    property int temp: -1
    property int mem: 0
    property real memUsedGb: 0
    property real memTotalGb: 0
    property int disk: 0
    property int gpu: -1
    property real rxRate: 0   // bytes/s
    property real txRate: 0
    property int volume: 0
    property bool muted: false
    property int brightness: -1

    // Historial para las gráficas del panel de sistema (último ~2 min)
    property var cpuHistory: []
    property var memHistory: []
    function _push(list, v) { const l = list.concat([v]); return l.length > 60 ? l.slice(l.length - 60) : l; }

    property var _prevCpu: null
    property var _prevNet: null
    property real _prevNetTime: 0

    function formatRate(b) {
        if (b >= 1048576) return (b / 1048576).toFixed(1) + "M";
        if (b >= 1024) return Math.round(b / 1024) + "K";
        return Math.round(b) + "B";
    }

    function refreshLevels() { levelsProc.running = true }

    function _parseStats(text) {
        const now = Date.now();
        for (const line of text.trim().split("\n")) {
            const p = line.trim().split(/\s+/);
            switch (p[0]) {
            case "cpu": {
                const total = Number(p[1]), idle = Number(p[2]);
                if (_prevCpu) {
                    const dt = total - _prevCpu.total, di = idle - _prevCpu.idle;
                    if (dt > 0) cpu = Math.round(100 * (dt - di) / dt);
                }
                _prevCpu = { total, idle };
                break;
            }
            case "mem": {
                const t = Number(p[1]), a = Number(p[2]);
                memTotalGb = t / 1048576;
                memUsedGb = (t - a) / 1048576;
                mem = t > 0 ? Math.round(100 * (t - a) / t) : 0;
                break;
            }
            case "net": {
                const rx = Number(p[1]), tx = Number(p[2]);
                if (_prevNet && now > _prevNetTime) {
                    const secs = (now - _prevNetTime) / 1000;
                    rxRate = Math.max(0, (rx - _prevNet.rx) / secs);
                    txRate = Math.max(0, (tx - _prevNet.tx) / secs);
                }
                _prevNet = { rx, tx };
                _prevNetTime = now;
                break;
            }
            case "temp": temp = Number(p[1]); break;
            case "disk": disk = Number(p[1]); break;
            }
        }
    }

    Process {
        id: statsProc
        command: [Quickshell.shellPath("scripts/stats.sh")]
        stdout: StdioCollector {
            onStreamFinished: {
                root._parseStats(text);
                root.cpuHistory = root._push(root.cpuHistory, root.cpu);
                root.memHistory = root._push(root.memHistory, root.mem);
            }
        }
    }

    Process {
        id: gpuProc
        command: [Quickshell.shellPath("scripts/gpu.sh")]
        stdout: StdioCollector {
            onStreamFinished: {
                const v = parseInt(text.trim());
                root.gpu = isNaN(v) ? -1 : v;
            }
        }
    }

    Process {
        id: levelsProc
        command: [Quickshell.shellPath("scripts/levels.sh")]
        stdout: StdioCollector {
            onStreamFinished: {
                for (const line of text.trim().split("\n")) {
                    const p = line.split(" ");
                    if (p[0] === "vol") { root.volume = Number(p[1]); root.muted = p[2] === "1"; }
                    else if (p[0] === "bri") root.brightness = Number(p[1]);
                }
            }
        }
    }

    Timer {
        interval: 2000; running: true; repeat: true; triggeredOnStart: true
        onTriggered: statsProc.running = true
    }
    Timer {
        interval: 4000; running: true; repeat: true; triggeredOnStart: true
        onTriggered: gpuProc.running = true
    }
    Timer {
        interval: 5000; running: true; repeat: true; triggeredOnStart: true
        onTriggered: levelsProc.running = true
    }
}
