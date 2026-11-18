import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick

// ==============================================================================
// MENÚ DE APAGADO a pantalla completa (SUPER + X)
// ←/→ o 1-5 para elegir · Enter confirma · Reiniciar/Apagar piden confirmación
// ==============================================================================
PanelWindow {
    id: win

    property int selected: 0
    property int armed: -1        // acción que espera confirmación
    property string uptime: ""
    property real t: Panels.power ? 1 : 0
    Behavior on t { NumberAnimation { duration: 380; easing.type: Easing.OutCubic } }

    readonly property var actions: [
        { icon: "󰌾", name: "Bloquear",       cmd: "loginctl lock-session",      confirm: false },
        { icon: "󰤄", name: "Suspender",      cmd: "systemctl suspend",          confirm: false },
        { icon: "󰍃", name: "Cerrar sesión",  cmd: "hyprctl dispatch 'hl.dsp.exit()'", confirm: true },
        { icon: "󰜉", name: "Reiniciar",      cmd: "systemctl reboot",           confirm: true },
        { icon: "󰐥", name: "Apagar",         cmd: "systemctl poweroff",         confirm: true },
    ]

    function run(i) {
        const a = actions[i];
        if (a.confirm && armed !== i) { armed = i; selected = i; return; }
        Panels.power = false;
        armed = -1;
        Quickshell.execDetached(["sh", "-c", a.cmd]);
    }

    visible: Panels.power || t > 0.001
    screen: Quickshell.screens.find(s => s.name === Hyprland.focusedMonitor?.name) ?? Quickshell.screens[0]
    anchors { top: true; bottom: true; left: true; right: true }
    exclusionMode: ExclusionMode.Ignore
    color: Qt.rgba(0, 0, 0, 0.55 * t)

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "quickshell-power"
    WlrLayershell.keyboardFocus: Panels.power ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    onVisibleChanged: if (visible) { selected = 0; armed = -1; keys.forceActiveFocus(); up.running = true; }

    Process {
        id: up
        command: ["uptime", "-p"]
        stdout: StdioCollector {
            onStreamFinished: win.uptime = text.trim()
                .replace("up ", "Encendida hace ")
                .replace(/weeks?/, "sem").replace(/days?/, "d").replace(/hours?/, "h").replace(/minutes?/, "min")
        }
    }

    SystemClock { id: clock; precision: SystemClock.Minutes }

    MouseArea { anchors.fill: parent; onClicked: Panels.power = false }

    Item {
        id: keys
        anchors.fill: parent
        focus: true
        Keys.onEscapePressed: Panels.power = false
        Keys.onLeftPressed: { win.selected = (win.selected + 4) % 5; win.armed = -1; }
        Keys.onRightPressed: { win.selected = (win.selected + 1) % 5; win.armed = -1; }
        Keys.onReturnPressed: win.run(win.selected)
        Keys.onPressed: e => {
            const n = e.key - Qt.Key_1;
            if (n >= 0 && n < 5) { win.run(n); e.accepted = true; }
        }
    }

    Column {
        anchors.centerIn: parent
        anchors.verticalCenterOffset: (1 - win.t) * 60
        opacity: win.t
        spacing: 46

        Column {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 6
            Txt {
                anchors.horizontalCenter: parent.horizontalCenter
                text: Qt.formatDateTime(clock.date, "HH:mm")
                font.pixelSize: 96
                font.bold: true
            }
            Txt {
                anchors.horizontalCenter: parent.horizontalCenter
                text: `${Quickshell.env("USER")}  ·  ${win.uptime}`
                color: Theme.fgDim
                font.pixelSize: 14
            }
        }

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 26

            Repeater {
                model: win.actions
                Column {
                    id: act
                    required property var modelData
                    required property int index
                    readonly property bool sel: win.selected === index
                    readonly property bool danger: win.armed === index
                    spacing: 14

                    // Entrada escalonada con rebote
                    opacity: 0
                    transform: Translate { id: tr; y: 50 }
                    Connections {
                        target: win
                        function onVisibleChanged() {
                            if (!win.visible) return;
                            act.opacity = 0; tr.y = 50;
                            pop.restart();
                        }
                    }
                    SequentialAnimation {
                        id: pop
                        PauseAnimation { duration: 60 + act.index * 55 }
                        ParallelAnimation {
                            NumberAnimation { target: act; property: "opacity"; to: 1; duration: 300 }
                            NumberAnimation { target: tr; property: "y"; to: 0; duration: 520; easing.type: Easing.OutBack; easing.overshoot: 2 }
                        }
                    }

                    Rectangle {
                        id: btn
                        width: 116; height: 116
                        radius: act.sel ? 36 : 58
                        color: act.danger ? Theme.urgent : act.sel ? Theme.accent : Theme.bgSolid
                        border.width: 1
                        border.color: act.sel ? "transparent" : Theme.border
                        scale: ma.pressed ? 0.92 : act.sel ? 1.08 : 1
                        Behavior on radius { NumberAnimation { duration: 280; easing.type: Easing.OutCubic } }
                        Behavior on color { ColorAnimation { duration: 200 } }
                        Behavior on scale { NumberAnimation { duration: 260; easing.type: Easing.OutBack } }

                        // Halo
                        Rectangle {
                            anchors.centerIn: parent
                            width: parent.width + 18; height: parent.height + 18
                            radius: parent.radius + 9
                            color: "transparent"
                            border.width: 2
                            border.color: act.danger ? Theme.urgent : Theme.accent
                            opacity: act.sel ? 0.35 : 0
                            Behavior on opacity { NumberAnimation { duration: 200 } }
                        }

                        Txt {
                            anchors.centerIn: parent
                            text: act.modelData.icon
                            font.pixelSize: 42
                            color: act.sel || act.danger ? Theme.base : Theme.fg
                            Behavior on color { ColorAnimation { duration: 200 } }
                        }
                        MouseArea {
                            id: ma
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onEntered: if (win.selected !== act.index) { win.selected = act.index; win.armed = -1; }
                            onClicked: win.run(act.index)
                        }
                    }
                    Txt {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: act.danger ? "¿Seguro?" : act.modelData.name
                        color: act.danger ? Theme.urgent : act.sel ? Theme.fg : Theme.fgDim
                        font.pixelSize: 13
                        font.bold: act.sel
                    }
                    Txt {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "" + (act.index + 1)
                        color: Theme.fgDim
                        font.pixelSize: 10
                        opacity: 0.6
                    }
                }
            }
        }
    }
}
