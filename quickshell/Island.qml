import Quickshell
import Quickshell.Hyprland
import Quickshell.Widgets
import Quickshell.Services.Notifications
import QtQuick

// ==============================================================================
// ISLA DINÁMICA
// Una sola píldora que cambia de forma según lo que pase:
//   idle      → hora + fecha
//   media     → carátula girando + título + visualizador (cava)
//   osd       → volumen / brillo
//   notif     → última notificación
//   expanded  → panel grande (clic en la isla): música, sliders, accesos rápidos
// Prioridad: expanded > notif > osd > media > idle
// ==============================================================================
Rectangle {
    id: island

    required property var window
    property bool expanded: false
    property bool hoveredOnce: false   // el auto-cierre solo aplica si el mouse ya entró
    onExpandedChanged: hoveredOnce = hover.hovered

    readonly property bool panelHere: Panels.current !== "" && Panels.monitor === (window.screen?.name ?? "")
    readonly property bool big: mode === "expanded" || panelHere

    readonly property string mode: expanded ? "expanded"
        : panelHere ? Panels.current
        : Notifs.showing ? "notif"
        : Osd.shown ? "osd"
        : Media.active ? "media"
        : "idle"

    readonly property var sizes: ({
        idle:     [Theme.s(210), Theme.barHeight],
        media:    [Theme.s(400), Theme.barHeight],
        osd:      [Theme.s(320), Theme.barHeight],
        notif:    [460, 82],
        expanded: [580, Stats.brightness >= 0 ? 314 : 280],
        wifi:       Panels.sizes.wifi,
        bluetooth:  Panels.sizes.bluetooth,
        audio:      Panels.sizes.audio,
        brightness: Panels.sizes.brightness,
        clipboard:  Panels.sizes.clipboard,
        system:     Panels.sizes.system,
        notifications: Panels.sizes.notifications,
    })

    implicitWidth: sizes[mode][0]
    implicitHeight: sizes[mode][1]
    radius: big || mode === "notif" ? 28 : height / 2
    color: Theme.bg
    border.color: mode === "notif" && Notifs.current?.urgency === NotificationUrgency.Critical
        ? Theme.urgent : Theme.border
    border.width: 1
    clip: true

    // Resorte con rebote: es lo que le da el "efecto isla"
    Behavior on implicitWidth  { SpringAnimation { spring: 3.6; damping: 0.28; epsilon: 0.4 } }
    Behavior on implicitHeight { SpringAnimation { spring: 3.6; damping: 0.30; epsilon: 0.4 } }
    Behavior on color { ColorAnimation { duration: 300 } }
    Behavior on radius { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
    Behavior on border.color { ColorAnimation { duration: 300 } }

    // Brillo sutil que respira mientras suena música
    Rectangle {
        id: glow
        anchors.fill: parent
        radius: parent.radius
        color: "transparent"
        border.width: 1
        border.color: Theme.accent
        opacity: 0
        SequentialAnimation on opacity {
            running: Media.playing && island.mode !== "expanded" && Settings.opts.islandGlow
            loops: Animation.Infinite
            NumberAnimation { to: 0.35; duration: 1400; easing.type: Easing.InOutSine }
            NumberAnimation { to: 0.0;  duration: 1400; easing.type: Easing.InOutSine }
            onRunningChanged: if (!running) glow.opacity = 0
        }
    }

    // --- Interacción -----------------------------------------------------------
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            if (island.panelHere) { Panels.close(); return; }
            if (island.mode === "notif") Notifs.current = null;
            island.expanded = !island.expanded;
        }
        // La rueda cambia el volumen solo con la isla compacta; con un panel o
        // la vista expandida abierta, la rueda es para hacer scroll
        onWheel: w => {
            if (island.big) return;
            const cmd = w.angleDelta.y > 0 ? "up" : "down";
            Quickshell.execDetached(["sh", "-c", `~/.config/hypr/scripts/audio.sh ${cmd}`]);
        }
    }

    HoverHandler {
        id: hover
        onHoveredChanged: if (hovered) island.hoveredOnce = true
    }

    Connections {
        target: Osd
        function onToggleIsland() {
            // Solo la isla del monitor enfocado
            if (Hyprland.focusedMonitor?.name === island.window.screen?.name)
                island.expanded = !island.expanded;
        }
    }

    // Se cierra solo al sacar el mouse o al hacer clic fuera
    Timer {
        running: island.expanded && !hover.hovered && island.hoveredOnce
        interval: 1200
        onTriggered: island.expanded = false
    }
    // Al cambiar el modo de teclado de la ventana (el portapapeles pide teclado
    // exclusivo) Hyprland suelta el grab justo al abrir: si pasa en los primeros
    // ms se vuelve a tomar en vez de tomarlo como "clic afuera".
    property real bigSince: 0
    property bool regrab: false
    HyprlandFocusGrab {
        windows: [island.window]
        active: island.big && !island.regrab
        onCleared: {
            if (Date.now() - island.bigSince < 600) {
                island.regrab = true;
                Qt.callLater(() => island.regrab = false);
                return;
            }
            island.expanded = false;
            if (island.panelHere) Panels.close();
        }
    }

    // Esc cierra panel / isla expandida
    Keys.onEscapePressed: { island.expanded = false; if (island.panelHere) Panels.close(); }
    onBigChanged: if (big) { bigSince = Date.now(); forceActiveFocus(); }
    onPanelHereChanged: if (panelHere) expanded = false

    // Cada "cara" de la isla aparece con fade + zoom cuando le toca
    component Face: Item {
        property string name
        readonly property bool current: island.mode === name
        anchors.centerIn: parent
        width: island.sizes[name][0] - 28
        height: island.sizes[name][1] - (["idle", "media", "osd", "notif"].includes(name) ? 8 : 32)
        opacity: current ? 1 : 0
        scale: current ? 1 : 0.9
        visible: opacity > 0.01
        Behavior on opacity { NumberAnimation { duration: current ? 260 : 120 } }
        Behavior on scale { NumberAnimation { duration: 320; easing.type: Easing.OutBack } }
    }

    component Label: Text {
        color: Theme.fg
        font.family: Theme.font
        font.pixelSize: Theme.fontSize
        elide: Text.ElideRight
        verticalAlignment: Text.AlignVCenter
    }

    component AlbumArt: ClippingRectangle {
        id: artBox
        property bool spin: false
        color: Theme.bgAlt
        Image {
            id: artImg
            anchors.fill: parent
            source: Media.art
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            sourceSize.width: 256
            sourceSize.height: 256
        }
        Label {
            anchors.centerIn: parent
            visible: artImg.status !== Image.Ready
            text: "󰎈"
            color: Theme.fgDim
            font.pixelSize: artBox.height * 0.5
        }
        RotationAnimation on rotation {
            running: artBox.spin && Media.playing
            from: 0; to: 360; duration: 8000
            loops: Animation.Infinite
        }
    }

    component Visualizer: Row {
        id: viz
        visible: Settings.opts.visualizer
        property int count: 12
        property real maxHeight: Theme.barHeight * 0.5
        property real barWidth: Theme.s(3)
        spacing: 2
        Repeater {
            model: viz.count
            Rectangle {
                required property int index
                readonly property real v: (Cava.bars[Math.floor(index * Cava.bars.length / viz.count)] ?? 0) / 100
                anchors.verticalCenter: parent.verticalCenter
                width: viz.barWidth
                height: Math.max(viz.barWidth, v * viz.maxHeight)
                radius: width / 2
                color: Theme.alpha(Theme.accent, 0.45 + v * 0.55)
                Behavior on height { NumberAnimation { duration: 70 } }
            }
        }
    }

    component SliderRow: Row {
        id: srow
        property string icon
        property int value
        signal moved(int v)
        width: parent.width
        height: 20
        spacing: 12
        Label { width: 18; text: srow.icon; font.pixelSize: 15; anchors.verticalCenter: parent.verticalCenter }
        LevelBar {
            anchors.verticalCenter: parent.verticalCenter
            width: srow.width - 18 - 40 - 24
            height: 8
            interactive: true
            value: srow.value / 100
            onMoved: v => srow.moved(Math.round(v * 100))
        }
        Label {
            width: 40
            anchors.verticalCenter: parent.verticalCenter
            horizontalAlignment: Text.AlignRight
            text: srow.value + "%"
            color: Theme.fgDim
        }
    }


    component Quick: Rectangle {
        id: q
        property string icon
        property string cmd
        width: 48; height: 30; radius: 15
        color: qa.containsMouse ? Theme.track : Theme.bgAlt
        scale: qa.pressed ? 0.9 : 1
        Behavior on color { ColorAnimation { duration: 150 } }
        Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutBack } }
        Label { anchors.centerIn: parent; text: q.icon; font.pixelSize: 15 }
        MouseArea {
            id: qa
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                island.expanded = false;
                Quickshell.execDetached(["sh", "-c", q.cmd]);
            }
        }
    }

    // --- idle --------------------------------------------------------------------
    SystemClock { id: clock; precision: SystemClock.Seconds }

    Face {
        name: "idle"
        Row {
            anchors.centerIn: parent
            spacing: 10
            Label {
                text: Qt.formatDateTime(clock.date, "HH:mm")
                font.pixelSize: Theme.barFont + 2
                font.bold: true
            }
            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: 5; height: 5; radius: 2.5
                color: Notifs.count > 0 ? Theme.accent : Theme.fgDim
                SequentialAnimation on opacity {
                    running: Notifs.count > 0
                    loops: Animation.Infinite
                    NumberAnimation { to: 0.2; duration: 700 }
                    NumberAnimation { to: 1; duration: 700 }
                }
            }
            Label {
                text: clock.date.toLocaleString(Qt.locale("es_ES"), "ddd d MMM")
                color: Theme.fgDim
                font.pixelSize: Theme.barFont
            }
        }
    }

    // --- media -------------------------------------------------------------------
    Face {
        name: "media"
        AlbumArt {
            id: miniArt
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            width: Theme.barHeight - 12; height: width; radius: width / 2
            spin: true
        }
        Label {
            anchors.left: miniArt.right
            anchors.leftMargin: 10
            anchors.right: miniViz.left
            anchors.rightMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            text: Media.artist ? `${Media.title}  ·  <font color="${Theme.fgDim}">${Media.artist}</font>` : Media.title
            textFormat: Text.StyledText
            font.pixelSize: Theme.barFont
        }
        Visualizer {
            id: miniViz
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    // --- osd ---------------------------------------------------------------------
    Face {
        name: "osd"
        Label {
            id: osdIcon
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            text: Osd.icon
            font.pixelSize: Theme.barFont + 5
        }
        LevelBar {
            anchors.left: osdIcon.right
            anchors.leftMargin: 12
            anchors.right: osdValue.left
            anchors.rightMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            value: Osd.value / 100
            fill: Osd.kind === "volume" && Stats.muted ? Theme.fgDim : Theme.accent
        }
        Label {
            id: osdValue
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            width: Theme.s(40)
            horizontalAlignment: Text.AlignRight
            text: Osd.value + "%"
            font.bold: true
            font.pixelSize: Theme.barFont
        }
    }

    // --- notif -------------------------------------------------------------------
    Face {
        id: notifFace
        name: "notif"
        readonly property var n: Notifs.current

        ClippingRectangle {
            id: notifIcon
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            width: 44; height: 44; radius: 14
            color: Theme.bgAlt
            Label {
                anchors.centerIn: parent
                visible: notifIconImg.source == ""
                text: "󰂚"
                font.pixelSize: 20
            }
            IconImage {
                id: notifIconImg
                anchors.fill: parent
                anchors.margins: notifFace.n?.image ? 0 : 8
                source: Notifs.iconFor(notifFace.n)
            }
        }
        Column {
            anchors.left: notifIcon.right
            anchors.leftMargin: 14
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            spacing: 2
            Label {
                width: parent.width
                text: notifFace.n?.appName ?? ""
                color: Theme.fgDim
                font.pixelSize: 10
            }
            Label {
                width: parent.width
                text: notifFace.n?.summary ?? ""
                font.bold: true
            }
            Label {
                width: parent.width
                text: notifFace.n?.body ?? ""
                color: Theme.fgDim
                font.pixelSize: 11
                maximumLineCount: 1
                visible: text.length > 0
            }
        }
    }

    // --- paneles (se crean al abrirse para que la entrada se anime cada vez) ----
    component PanelFace: Face {
        id: pf
        property Component panel
        Loader {
            anchors.fill: parent
            active: pf.current || pf.visible
            sourceComponent: pf.panel
        }
    }
    PanelFace { name: "wifi";       panel: Component { WifiPanel {} } }
    PanelFace { name: "bluetooth";  panel: Component { BluetoothPanel {} } }
    PanelFace { name: "audio";      panel: Component { AudioPanel {} } }
    PanelFace { name: "brightness"; panel: Component { BrightnessPanel {} } }
    PanelFace { name: "clipboard";  panel: Component { ClipboardPanel {} } }
    PanelFace { name: "system";     panel: Component { SystemPanel {} } }
    PanelFace { name: "notifications"; panel: Component { NotificationsPanel {} } }

    // --- expanded ----------------------------------------------------------------
    Face {
        id: big
        name: "expanded"

        Column {
            anchors.fill: parent
            spacing: 14

            // Hora grande + notificaciones
            Item {
                width: parent.width
                height: 44
                Row {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 12
                    Label {
                        text: Qt.formatDateTime(clock.date, "HH:mm")
                        font.pixelSize: 36
                        font.bold: true
                    }
                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        Label {
                            text: clock.date.toLocaleString(Qt.locale("es_ES"), "dddd")
                            font.pixelSize: 13
                        }
                        Label {
                            text: clock.date.toLocaleString(Qt.locale("es_ES"), "d 'de' MMMM")
                            color: Theme.fgDim
                            font.pixelSize: 11
                        }
                    }
                }
                Row {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 4
                    Chip {
                        anchors.verticalCenter: parent.verticalCenter
                        text: Notifs.dnd ? "󰂛" : Notifs.count > 0 ? `󰂚 ${Notifs.count}` : "󰂜"
                        color: Notifs.count > 0 && !Notifs.dnd ? Theme.fg : Theme.fgDim
                        onClicked: Panels.toggle("notifications")
                        onRightClicked: Notifs.toggleDnd()
                    }
                    Chip {
                        visible: Notifs.count > 0
                        text: "limpiar"
                        size: 11
                        color: Theme.fgDim
                        onClicked: Notifs.clearAll()
                    }
                }
            }

            // Tarjeta de música
            Rectangle {
                width: parent.width
                height: 112
                radius: 20
                color: Theme.bgAlt

                AlbumArt {
                    id: bigArt
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                    width: 92; height: 92; radius: 14
                }

                Column {
                    anchors.left: bigArt.right
                    anchors.leftMargin: 14
                    anchors.right: parent.right
                    anchors.rightMargin: 14
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 6

                    Item {
                        width: parent.width
                        height: 18
                        Label {
                            anchors.left: parent.left
                            anchors.right: bigViz.left
                            anchors.rightMargin: 8
                            text: Media.active ? Media.title : "Nada sonando"
                            font.bold: true
                            font.pixelSize: 13
                        }
                        Visualizer {
                            id: bigViz
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            count: 16
                            maxHeight: 16
                        }
                    }
                    Label {
                        width: parent.width
                        text: Media.artist || (Media.active ? "" : "Pon algo en Spotify o el navegador")
                        visible: text !== ""
                        color: Theme.fgDim
                        font.pixelSize: 11
                    }
                    LevelBar {
                        width: parent.width
                        height: 4
                        value: Media.progress
                        visible: Media.active
                    }
                    // Sin música: atajo a Spotify (lo enfoca si está abierto, si no lo abre)
                    Chip {
                        visible: !Media.active
                        text: "󰓇  Abrir Spotify"
                        color: Theme.accent
                        size: 12
                        onClicked: {
                            island.expanded = false;
                            Quickshell.execDetached(["sh", "-c", "~/.config/quickshell/scripts/spotify.sh"]);
                        }
                    }
                    Item {
                        width: parent.width
                        height: 24
                        visible: Media.active
                        Label {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            text: Media.fmt(Media.player?.position)
                            color: Theme.fgDim
                            font.pixelSize: 10
                        }
                        Row {
                            anchors.centerIn: parent
                            spacing: 6
                            Chip { text: "󰒮"; size: 15; onClicked: Media.player?.previous() }
                            Chip { text: Media.playing ? "󰏤" : "󰐊"; size: 17; onClicked: Media.player?.togglePlaying() }
                            Chip { text: "󰒭"; size: 15; onClicked: Media.player?.next() }
                        }
                        Label {
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            text: Media.fmt(Media.player?.length)
                            color: Theme.fgDim
                            font.pixelSize: 10
                        }
                    }
                }
            }

            // Sliders
            SliderRow {
                icon: Osd.kind === "volume" ? Osd.icon : (Stats.muted ? "󰝟" : "󰕾")
                value: Stats.volume
                onMoved: v => {
                    Stats.volume = v;
                    Quickshell.execDetached(["sh", "-c", `~/.config/hypr/scripts/audio.sh set ${v}`]);
                }
            }
            SliderRow {
                visible: Stats.brightness >= 0
                icon: "󰃠"
                value: Math.max(0, Stats.brightness)
                onMoved: v => {
                    Stats.brightness = v;
                    Quickshell.execDetached(["brightnessctl", "-c", "backlight", "s", `${Math.max(1, v)}%`]);
                }
            }

            // Accesos rápidos
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 10
                Quick { icon: "󰤨"; cmd: "qs ipc call panel toggle wifi" }
                Quick { icon: "󰂯"; cmd: "qs ipc call panel toggle bluetooth" }
                Quick { icon: "󰅍"; cmd: "qs ipc call panel toggle clipboard" }
                Quick { icon: "󰌾"; cmd: "hyprlock" }
                Quick { icon: "󰒓"; cmd: "qs ipc call settings toggle" }
                Quick { icon: "⏻"; cmd: "qs ipc call panel toggle power" }
            }
        }
    }
}
