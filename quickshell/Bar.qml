import Quickshell
import Quickshell.Wayland
import Quickshell.Services.UPower
import QtQuick

// ==============================================================================
// BARRA (reemplaza a waybar)
// La ventana es alta y transparente para que la isla pueda crecer hacia abajo;
// la "mask" deja pasar los clics a las ventanas fuera de las píldoras.
// ==============================================================================
PanelWindow {
    id: bar

    required property var modelData
    screen: modelData

    anchors { top: true; left: true; right: true }
    implicitHeight: 580
    exclusiveZone: Theme.barHeight + Theme.margin
    color: "transparent"

    WlrLayershell.namespace: "quickshell-bar"
    WlrLayershell.layer: WlrLayer.Top
    // Teclado solo cuando hay un panel abierto (contraseña wifi, búsqueda...)
    WlrLayershell.keyboardFocus: Panels.current === "clipboard" ? WlrKeyboardFocus.Exclusive
        : (Panels.current !== "" || island.expanded) ? WlrKeyboardFocus.OnDemand
        : WlrKeyboardFocus.None

    mask: Region {
        item: leftPill
        Region { item: island }
        Region { item: rightPill }
    }

    // --- Izquierda: workspaces + red --------------------------------------------
    Pill {
        id: leftPill
        x: 8
        y: Theme.margin
        spacing: 10

        Item { width: 4; height: 1 }
        Workspaces { anchors.verticalCenter: parent.verticalCenter }
        Rectangle { visible: Settings.opts.showNet; width: 1; height: 14; color: Theme.track; anchors.verticalCenter: parent.verticalCenter }
        Chip {
            anchors.verticalCenter: parent.verticalCenter
            visible: Settings.opts.showNet
            text: `<font color="${Theme.fgDim}">󰁝</font> ${Stats.formatRate(Stats.txRate)}  <font color="${Theme.fgDim}">󰁅</font> ${Stats.formatRate(Stats.rxRate)}`
            onClicked: Panels.toggle("wifi")
        }
    }

    // --- Centro: isla dinámica --------------------------------------------------
    Island {
        id: island
        window: bar
        anchors.horizontalCenter: parent.horizontalCenter
        y: Theme.margin
    }

    // --- Derecha: sistema -------------------------------------------------------
    Pill {
        id: rightPill
        anchors.right: parent.right
        anchors.rightMargin: 8
        y: Theme.margin
        spacing: 2

        Chip {
            anchors.verticalCenter: parent.verticalCenter
            text: Osd.icon + " " + Stats.volume + "%"
            color: Stats.muted ? Theme.fgDim : Theme.fg
            onClicked: Panels.toggle("audio")
            onRightClicked: Quickshell.execDetached(["sh", "-c", "~/.config/hypr/scripts/audio.sh mute-toggle"])
            onScrolled: d => Quickshell.execDetached(["sh", "-c", `~/.config/hypr/scripts/audio.sh ${d > 0 ? "up" : "down"}`])
        }
        Chip {
            anchors.verticalCenter: parent.verticalCenter
            visible: Stats.brightness >= 0
            text: "󰃠 " + Stats.brightness + "%"
            onClicked: Panels.toggle("brightness")
            onScrolled: d => Quickshell.execDetached(["sh", "-c", `brightnessctl -c backlight s ${d > 0 ? "+5%" : "5%-"} && qs ipc call osd brightness`])
        }
        Chip {
            anchors.verticalCenter: parent.verticalCenter
            visible: Settings.opts.showStats
            onClicked: Panels.toggle("system")
            onRightClicked: Quickshell.execDetached(["sh", "-c", "~/.config/hypr/scripts/btop.sh"])
            text: `\u{F0EE0} ${Stats.cpu}%` + (Stats.temp >= 0 ? ` <font color="${Theme.fgDim}">${Stats.temp}°</font>` : "")
            color: Stats.temp >= 85 ? Theme.urgent : Theme.fg
        }
        Chip {
            anchors.verticalCenter: parent.verticalCenter
            visible: Stats.gpu >= 0 && Settings.opts.showStats
            onClicked: Panels.toggle("system")
            text: "󰢮 " + Stats.gpu + "%"
        }
        Chip {
            anchors.verticalCenter: parent.verticalCenter
            visible: Settings.opts.showStats
            onClicked: Panels.toggle("system")
            onRightClicked: Quickshell.execDetached(["sh", "-c", "~/.config/hypr/scripts/btop.sh"])
            text: "\u{F035B} " + Stats.mem + "%"
        }
        Chip {
            anchors.verticalCenter: parent.verticalCenter
            visible: UPower.displayDevice?.isLaptopBattery ?? false
            onClicked: Panels.toggle("system")
            readonly property int pct: Math.round((UPower.displayDevice?.percentage ?? 0) * 100)
            readonly property bool charging: UPower.displayDevice?.state === UPowerDeviceState.Charging
            text: (charging ? "󰂄" : ["󰁺", "󰁼", "󰁾", "󰂀", "󰁹"][Math.min(4, Math.floor(pct / 20))]) + " " + pct + "%"
            color: pct <= 15 && !charging ? Theme.urgent : Theme.fg
        }
        // Notificaciones: clic abre el centro, clic derecho = No molestar
        Chip {
            id: bell
            anchors.verticalCenter: parent.verticalCenter
            text: Notifs.dnd ? "󰂛" : Notifs.count > 0 ? `󰂚 ${Notifs.count}` : "󰂜"
            color: Notifs.dnd ? Theme.fgDim : Notifs.count > 0 ? Theme.accent : Theme.fg
            onClicked: Panels.toggle("notifications")
            onRightClicked: Notifs.toggleDnd()
            // Se sacude cuando llega una notificación
            transformOrigin: Item.Top
            SequentialAnimation on rotation {
                id: shake
                running: false
                NumberAnimation { to: 18; duration: 70 }
                NumberAnimation { to: -15; duration: 110 }
                NumberAnimation { to: 10; duration: 100 }
                NumberAnimation { to: -6; duration: 90 }
                NumberAnimation { to: 0; duration: 80 }
            }
            Connections {
                target: Notifs
                function onCountChanged() { if (Notifs.count > 0 && !Notifs.dnd) shake.restart() }
            }
        }
        Chip {
            anchors.verticalCenter: parent.verticalCenter
            text: "⏻"
            onClicked: Panels.toggle("power")
            onRightClicked: Quickshell.execDetached(["loginctl", "lock-session"])
        }
        Item { width: 2; height: 1 }
    }
}
