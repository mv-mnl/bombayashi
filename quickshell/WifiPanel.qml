import Quickshell
import Quickshell.Io
import QtQuick

// Panel de Wi-Fi (nmcli): redes, conectar con contraseña, desconectar, escanear
Item {
    id: root

    property bool radio: true
    property string wifiDev: ""
    property string wifiState: ""
    property string ethDev: ""
    property var known: []
    property var networks: []
    property string expanded: ""      // SSID con el campo de contraseña abierto
    property string connecting: ""
    property string status: ""
    property bool scanning: false

    readonly property var activeNet: networks.find(n => n.inUse) ?? null

    // nmcli -t escapa ":" como "\:"
    function splitNm(line) {
        const out = [];
        let cur = "";
        for (let i = 0; i < line.length; i++) {
            const c = line[i];
            if (c === "\\" && i + 1 < line.length) cur += line[++i];
            else if (c === ":") { out.push(cur); cur = ""; }
            else cur += c;
        }
        out.push(cur);
        return out;
    }

    function signalIcon(s) { return s > 75 ? "󰤨" : s > 50 ? "󰤥" : s > 25 ? "󰤢" : "󰤟" }

    function refresh() { info.running = true }

    function run(cmd, label) {
        status = label;
        action.command = cmd;
        action.running = true;
    }

    function connect(net, password) {
        connecting = net.ssid;
        if (known.includes(net.ssid)) run(["nmcli", "con", "up", "id", net.ssid], `Conectando a ${net.ssid}…`);
        else if (password) run(["nmcli", "dev", "wifi", "connect", net.ssid, "password", password], `Conectando a ${net.ssid}…`);
        else run(["nmcli", "dev", "wifi", "connect", net.ssid], `Conectando a ${net.ssid}…`);
    }

    function rescan() {
        scanning = true;
        Quickshell.execDetached(["nmcli", "dev", "wifi", "rescan"]);
        rescanDone.restart();
    }

    Component.onCompleted: refresh()
    Timer { interval: 5000; running: true; repeat: true; onTriggered: root.refresh() }
    Timer { id: rescanDone; interval: 3500; onTriggered: { root.scanning = false; root.refresh(); } }

    Process {
        id: info
        command: ["sh", "-c",
            "echo \"R $(nmcli radio wifi)\"; " +
            "nmcli -t -f DEVICE,TYPE,STATE dev | awk -F: '$2==\"wifi\"{print \"D \"$1\":\"$3} $2==\"ethernet\" && $3==\"connected\"{print \"E \"$1}'; " +
            "nmcli -t -f NAME,TYPE con show | awk -F: '$2==\"802-11-wireless\"{print \"K \"$1}'; " +
            "nmcli -t -f IN-USE,SSID,SIGNAL,SECURITY dev wifi list --rescan no 2>/dev/null | sed 's/^/N /'"]
        stdout: StdioCollector {
            onStreamFinished: {
                let radio = true, dev = "", st = "", eth = "", known = [], nets = {};
                for (const raw of text.split("\n")) {
                    const kind = raw.slice(0, 1), rest = raw.slice(2);
                    if (kind === "R") radio = rest.trim() === "enabled";
                    else if (kind === "D") { const p = root.splitNm(rest); dev = p[0]; st = p[1]; }
                    else if (kind === "E") eth = rest.trim();
                    else if (kind === "K") known.push(rest);
                    else if (kind === "N") {
                        const p = root.splitNm(rest);
                        const ssid = p[1];
                        if (!ssid) continue;
                        const n = { inUse: p[0] === "*", ssid, signal: Number(p[2]) || 0, secure: p[3] !== "" && p[3] !== "--", security: p[3] };
                        if (!nets[ssid] || n.inUse || n.signal > nets[ssid].signal) nets[ssid] = n;
                    }
                }
                root.radio = radio; root.wifiDev = dev; root.wifiState = st; root.ethDev = eth; root.known = known;
                root.networks = Object.values(nets).sort((a, b) => (b.inUse - a.inUse) || (b.signal - a.signal));
            }
        }
    }

    Process {
        id: action
        stderr: StdioCollector { id: actionErr }
        onExited: code => {
            root.status = code === 0 ? (root.connecting ? `Conectado a ${root.connecting}` : "Listo")
                                     : "Error: " + (actionErr.text.trim().split("\n").pop() || "no se pudo");
            if (code === 0) root.expanded = "";
            root.connecting = "";
            root.refresh();
        }
    }

    Column {
        anchors.fill: parent
        spacing: 12

        PanelHeader {
            icon: !root.radio ? "󰤭" : root.activeNet ? root.signalIcon(root.activeNet.signal) : root.ethDev ? "󰈀" : "󰤯"
            title: "Wi-Fi"
            active: root.radio && (root.activeNet !== null || root.ethDev !== "")
            subtitle: !root.wifiDev ? "No hay adaptador wifi" + (root.ethDev ? ` · Ethernet (${root.ethDev})` : "")
                : !root.radio ? "Apagado"
                : root.activeNet ? `Conectado a ${root.activeNet.ssid}`
                : root.wifiState === "unavailable" ? "No disponible"
                : "Sin conexión"

            Rectangle {
                width: 34; height: 34; radius: 17
                visible: root.radio && root.wifiDev !== ""
                color: sa.containsMouse ? Theme.track : Theme.bgAlt
                Txt {
                    id: scanIcon
                    anchors.centerIn: parent
                    text: "󰑐"
                    font.pixelSize: 15
                    RotationAnimation on rotation {
                        running: root.scanning
                        from: 0; to: 360; duration: 900; loops: Animation.Infinite
                        onRunningChanged: if (!running) scanIcon.rotation = 0
                    }
                }
                MouseArea { id: sa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root.rescan() }
            }
            Toggle {
                width: 50
                visible: root.wifiDev !== ""
                checked: root.radio
                onToggled: {
                    root.radio = !root.radio;
                    Quickshell.execDetached(["nmcli", "radio", "wifi", root.radio ? "on" : "off"]);
                    refreshLater.restart();
                }
                Timer { id: refreshLater; interval: 1500; onTriggered: root.refresh() }
            }
        }

        // Ethernet
        PanelRow {
            visible: root.ethDev !== ""
            animate: false
            icon: "󰈀"
            title: "Ethernet"
            subtitle: root.ethDev
            trailing: "Conectado"
            active: true
        }

        Txt {
            width: parent.width
            text: root.status
            visible: root.status.length > 0
            color: root.status.startsWith("Error") ? Theme.urgent : Theme.fgDim
            font.pixelSize: 11
        }

        // Lista de redes
        Flickable {
            width: parent.width
            height: parent.height - y - 4
            contentHeight: list.implicitHeight
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            visible: root.radio && root.wifiDev !== ""

            Column {
                id: list
                width: parent.width
                spacing: 4

                Repeater {
                    model: root.networks
                    PanelRow {
                        id: netRow
                        required property var modelData
                        required property int index
                        readonly property bool isKnown: root.known.includes(modelData.ssid)
                        icon: root.signalIcon(modelData.signal)
                        title: modelData.ssid
                        subtitle: modelData.inUse ? "Conectado" : isKnown ? "Guardada" : modelData.secure ? modelData.security : "Abierta"
                        trailing: (modelData.secure ? "󰌾  " : "") + modelData.signal + "%"
                        active: modelData.inUse
                        busy: root.connecting === modelData.ssid
                        onClicked: {
                            if (modelData.inUse) return;
                            if (modelData.secure && !isKnown) root.expanded = root.expanded === modelData.ssid ? "" : modelData.ssid;
                            else root.connect(modelData);
                        }
                        onSecondary: if (modelData.inUse) root.run(["nmcli", "dev", "disconnect", root.wifiDev], "Desconectando…")

                        // Campo de contraseña desplegable
                        Item {
                            width: parent.width
                            height: root.expanded === netRow.modelData.ssid ? 46 : 0
                            clip: true
                            Behavior on height { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
                            Rectangle {
                                id: pwBox
                                y: 2
                                width: parent.width - 110
                                height: 34; radius: 17
                                color: Theme.base
                                border.color: pw.activeFocus ? Theme.accent : Theme.track
                                TextInput {
                                    id: pw
                                    anchors.fill: parent
                                    anchors.leftMargin: 14
                                    anchors.rightMargin: 14
                                    verticalAlignment: TextInput.AlignVCenter
                                    echoMode: TextInput.Password
                                    color: Theme.fg
                                    selectionColor: Theme.accent
                                    font.family: Theme.font
                                    font.pixelSize: 12
                                    onVisibleChanged: if (visible && root.expanded === netRow.modelData.ssid) forceActiveFocus()
                                    onAccepted: root.connect(netRow.modelData, text)
                                    Txt {
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: "Contraseña"
                                        color: Theme.fgDim
                                        visible: pw.text.length === 0
                                    }
                                }
                            }
                            Button {
                                y: 2
                                anchors.right: parent.right
                                primary: true
                                text: "Conectar"
                                onClicked: root.connect(netRow.modelData, pw.text)
                            }
                        }
                    }
                }

                Txt {
                    width: parent.width
                    visible: root.networks.length === 0
                    topPadding: 30
                    horizontalAlignment: Text.AlignHCenter
                    text: root.wifiState === "unavailable" ? "El adaptador wifi no está disponible" : "Buscando redes…"
                    color: Theme.fgDim
                }
            }
        }

        Txt {
            width: parent.width
            visible: !root.wifiDev
            topPadding: 20
            horizontalAlignment: Text.AlignHCenter
            text: "Este equipo no tiene wifi.\nEstás conectado por cable."
            color: Theme.fgDim
        }
    }

    Txt {
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        text: "clic derecho en la red activa para desconectar"
        color: Theme.fgDim
        font.pixelSize: 10
        visible: root.activeNet !== null
    }
}
