import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower
import QtQuick

// Panel de sistema: medidores, historial de CPU/RAM, procesos, batería y
// perfil de energía. Se abre con clic en CPU / GPU / RAM / batería de la barra.
Item {
    id: root

    property var procs: []
    property string uptime: ""
    property string host: ""
    readonly property var bat: UPower.displayDevice
    readonly property bool hasBattery: bat?.isLaptopBattery ?? false

    function refresh() { procProc.running = true }
    Component.onCompleted: { refresh(); up.running = true; }
    Timer { interval: 3000; running: true; repeat: true; onTriggered: root.refresh() }

    Process {
        id: procProc
        command: ["ps", "-eo", "pid,comm,%cpu,%mem", "--sort=-%cpu", "--no-headers"]
        stdout: StdioCollector {
            onStreamFinished: root.procs = text.trim().split("\n").slice(0, 5).map(l => {
                const p = l.trim().split(/\s+/);
                return { pid: p[0], name: p[1], cpu: Number(p[2]), mem: Number(p[3]) };
            })
        }
    }

    Process {
        running: true
        command: ["cat", "/etc/hostname"]
        stdout: StdioCollector { onStreamFinished: root.host = text.trim() }
    }

    Process {
        id: up
        command: ["uptime", "-p"]
        stdout: StdioCollector {
            onStreamFinished: root.uptime = text.trim().replace("up ", "encendida hace ")
                .replace(/weeks?/, "sem").replace(/days?/, "d").replace(/hours?/, "h").replace(/minutes?/, "min")
        }
    }

    Flickable {
        anchors.fill: parent
        contentHeight: col.implicitHeight
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        Column {
            id: col
            width: parent.width
            spacing: 14

            PanelHeader {
                icon: "󰍛"
                title: "Sistema"
                subtitle: [root.host, root.uptime].filter(x => x).join("  ·  ")
                Button {
                    text: "󰄨  btop"
                    onClicked: {
                        Panels.close();
                        Quickshell.execDetached(["sh", "-c", "~/.config/hypr/scripts/btop.sh"]);
                    }
                }
            }

            // Medidores
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 8
                Gauge {
                    icon: "\u{F0EE0}"
                    label: Stats.temp >= 0 ? `CPU · ${Stats.temp}°C` : "CPU"
                    value: Stats.cpu
                }
                Gauge {
                    icon: "\u{F035B}"
                    label: `RAM · ${Stats.memUsedGb.toFixed(1)}/${Math.round(Stats.memTotalGb)} GB`
                    value: Stats.mem
                }
                Gauge {
                    visible: Stats.gpu >= 0
                    icon: "󰢮"
                    label: "GPU"
                    value: Math.max(0, Stats.gpu)
                }
                Gauge {
                    icon: "󰋊"
                    label: "Disco /"
                    value: Stats.disk
                }
            }

            // Historial
            Rectangle {
                width: parent.width
                height: 92
                radius: 16
                color: Theme.bgAlt
                Sparkline {
                    anchors.fill: parent
                    anchors.margins: 10
                    anchors.topMargin: 26
                    values: Stats.memHistory
                    color: Theme.fgDim
                }
                Sparkline {
                    anchors.fill: parent
                    anchors.margins: 10
                    anchors.topMargin: 26
                    values: Stats.cpuHistory
                }
                Row {
                    x: 12; y: 8
                    spacing: 14
                    Txt { text: "● CPU"; color: Theme.accent; font.pixelSize: 10 }
                    Txt { text: "● RAM"; color: Theme.fgDim; font.pixelSize: 10 }
                }
                Txt {
                    anchors.right: parent.right
                    anchors.rightMargin: 12
                    y: 8
                    text: `󰁝 ${Stats.formatRate(Stats.txRate)}/s   󰁅 ${Stats.formatRate(Stats.rxRate)}/s`
                    color: Theme.fgDim
                    font.pixelSize: 10
                }
            }

            // Batería (solo laptop)
            Rectangle {
                visible: root.hasBattery
                width: parent.width
                height: 52
                radius: 16
                color: Theme.bgAlt
                readonly property int pct: Math.round((root.bat?.percentage ?? 0) * 100)
                readonly property bool charging: root.bat?.state === UPowerDeviceState.Charging
                Txt {
                    x: 14
                    anchors.verticalCenter: parent.verticalCenter
                    text: (parent.charging ? "󰂄" : "󰁹") + "  " + parent.pct + "%"
                    font.pixelSize: 14
                    font.bold: true
                }
                LevelBar {
                    x: 100
                    width: parent.width - 100 - 150
                    anchors.verticalCenter: parent.verticalCenter
                    value: parent.pct / 100
                    fill: parent.pct <= 15 && !parent.charging ? Theme.urgent : Theme.accent
                }
                Txt {
                    anchors.right: parent.right
                    anchors.rightMargin: 14
                    anchors.verticalCenter: parent.verticalCenter
                    readonly property real secs: parent.charging ? (root.bat?.timeToFull ?? 0) : (root.bat?.timeToEmpty ?? 0)
                    text: secs > 0 ? `${parent.charging ? "llena en" : "quedan"} ${Math.floor(secs / 3600)} h ${Math.round(secs % 3600 / 60)} min` : ""
                    color: Theme.fgDim
                    font.pixelSize: 11
                }
            }

            // Perfil de energía
            Row {
                spacing: 8
                Txt { text: "Energía"; color: Theme.fgDim; font.pixelSize: 11; anchors.verticalCenter: parent.verticalCenter; width: 70 }
                Repeater {
                    model: [
                        { p: PowerProfile.PowerSaver,  name: "󰌪  Ahorro" },
                        { p: PowerProfile.Balanced,    name: "󰾅  Equilibrado" },
                        { p: PowerProfile.Performance, name: "󰓅  Rendimiento" },
                    ]
                    Button {
                        required property var modelData
                        visible: modelData.p !== PowerProfile.Performance || PowerProfiles.hasPerformanceProfile
                        text: modelData.name
                        primary: PowerProfiles.profile === modelData.p
                        onClicked: PowerProfiles.profile = modelData.p
                    }
                }
            }

            // Procesos
            Txt { text: "PROCESOS QUE MÁS CONSUMEN"; color: Theme.fgDim; font.pixelSize: 11; font.bold: true; font.letterSpacing: 1.5 }
            Repeater {
                model: root.procs
                Item {
                    required property var modelData
                    required property int index
                    width: col.width
                    height: 24
                    Txt { x: 4; width: 170; text: modelData.name; anchors.verticalCenter: parent.verticalCenter }
                    LevelBar {
                        x: 180
                        width: parent.width - 180 - 110
                        height: 5
                        anchors.verticalCenter: parent.verticalCenter
                        value: Math.min(100, modelData.cpu) / 100
                    }
                    Txt {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        text: `${modelData.cpu.toFixed(1)}%  ·  ${modelData.mem.toFixed(1)}%`
                        color: Theme.fgDim
                        font.pixelSize: 11
                    }
                }
            }
        }
    }
}
