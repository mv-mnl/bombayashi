import Quickshell
import Quickshell.Bluetooth
import QtQuick

// Panel de Bluetooth (BlueZ nativo de quickshell)
Item {
    id: root

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool on: adapter?.enabled ?? false
    readonly property var devices: {
        const list = (adapter?.devices?.values ?? []).filter(d => d.name || d.deviceName);
        return list.sort((a, b) => (b.connected - a.connected) || (b.paired - a.paired) || (a.name ?? "").localeCompare(b.name ?? ""));
    }
    readonly property var connectedDevs: devices.filter(d => d.connected)

    function iconFor(d) {
        const i = d.icon ?? "";
        if (i.includes("headset") || i.includes("headphone")) return "󰋋";
        if (i.includes("audio") || i.includes("speaker")) return "󰓃";
        if (i.includes("mouse")) return "󰍽";
        if (i.includes("keyboard")) return "󰌌";
        if (i.includes("phone")) return "󰏲";
        if (i.includes("gaming") || i.includes("joystick")) return "󰊴";
        if (i.includes("computer")) return "󰟀";
        return "󰂯";
    }

    function stateText(d) {
        if (d.pairing) return "Emparejando…";
        if (d.state === BluetoothDeviceState.Connecting) return "Conectando…";
        if (d.state === BluetoothDeviceState.Disconnecting) return "Desconectando…";
        if (d.connected) return "Conectado" + (d.batteryAvailable ? `  ·  󰁹 ${Math.round(d.battery * 100)}%` : "");
        if (d.paired) return "Emparejado";
        return "Disponible";
    }

    function activate(d) {
        if (d.connected) d.disconnect();
        else if (d.paired) d.connect();
        else { d.trusted = true; d.pair(); }
    }

    // Buscar dispositivos mientras el panel está abierto
    Component.onCompleted: if (on) adapter.discovering = true
    Component.onDestruction: if (adapter) adapter.discovering = false

    Column {
        anchors.fill: parent
        spacing: 12

        PanelHeader {
            icon: !root.on ? "󰂲" : root.connectedDevs.length ? "󰂱" : "󰂯"
            title: "Bluetooth"
            active: root.on
            subtitle: !root.adapter ? "No hay adaptador"
                : !root.on ? "Apagado"
                : root.connectedDevs.length ? root.connectedDevs.map(d => d.name).join(", ")
                : root.adapter.discovering ? "Buscando dispositivos…" : "Encendido"

            Rectangle {
                width: 34; height: 34; radius: 17
                visible: root.on
                color: sa.containsMouse ? Theme.track : Theme.bgAlt
                Txt {
                    id: scanIcon
                    anchors.centerIn: parent
                    text: "󰑐"
                    font.pixelSize: 15
                    RotationAnimation on rotation {
                        running: root.adapter?.discovering ?? false
                        from: 0; to: 360; duration: 1200; loops: Animation.Infinite
                        onRunningChanged: if (!running) scanIcon.rotation = 0
                    }
                }
                MouseArea {
                    id: sa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.adapter.discovering = !root.adapter.discovering
                }
            }
            Toggle {
                width: 50
                visible: root.adapter !== null
                checked: root.on
                onToggled: {
                    root.adapter.enabled = !root.on;
                    if (root.adapter.enabled) root.adapter.discovering = true;
                }
            }
        }

        Flickable {
            width: parent.width
            height: parent.height - y
            contentHeight: list.implicitHeight
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            visible: root.on

            Column {
                id: list
                width: parent.width
                spacing: 4

                Repeater {
                    model: root.devices
                    PanelRow {
                        required property var modelData
                        required property int index
                        icon: root.iconFor(modelData)
                        title: modelData.name || modelData.deviceName
                        subtitle: root.stateText(modelData)
                        trailing: modelData.connected ? "Desconectar" : modelData.paired ? "Conectar" : "Emparejar"
                        active: modelData.connected
                        busy: modelData.pairing || modelData.state === BluetoothDeviceState.Connecting
                        onClicked: root.activate(modelData)
                        onSecondary: if (modelData.paired && !modelData.connected) modelData.forget()
                    }
                }

                Txt {
                    width: parent.width
                    visible: root.devices.length === 0
                    topPadding: 30
                    horizontalAlignment: Text.AlignHCenter
                    text: "Buscando dispositivos cercanos…"
                    color: Theme.fgDim
                }
            }
        }

        Txt {
            width: parent.width
            visible: !root.on
            topPadding: 30
            horizontalAlignment: Text.AlignHCenter
            text: root.adapter ? "Activa el Bluetooth para ver dispositivos" : "No se encontró un adaptador Bluetooth"
            color: Theme.fgDim
        }
    }

    Txt {
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        visible: root.on
        text: "clic derecho en uno emparejado para olvidarlo"
        color: Theme.fgDim
        font.pixelSize: 10
    }
}
