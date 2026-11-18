import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Widgets
import QtQuick

// ==============================================================================
// CARRUSEL DE FONDOS (SUPER + W)
// Dos modos (Tab para cambiar):
//   Mi PC     -> fondos locales; escribe para filtrar, Enter aplica
//   Internet  -> busca en wallhaven.cc (solo contenido SFW); Enter busca y, sobre
//                un resultado, lo descarga a ~/Imágenes/Wallpapers y lo aplica.
//                Ctrl+S solo lo guarda.
// ←/→ o rueda para moverte · Ctrl+R aleatorio · Esc cierra
// ==============================================================================
PanelWindow {
    id: win

    property bool online: false
    property real t: Settings.picker ? 1 : 0
    Behavior on t { NumberAnimation { duration: 380; easing.type: Easing.OutCubic } }

    // ---------------------------------------------------------------- datos
    readonly property var localItems: {
        const q = online ? "" : search.text.trim().toLowerCase();
        return Settings.wallpapers
            .filter(p => !q || p.split("/").pop().toLowerCase().includes(q))
            .map(p => ({ id: p, src: p, full: p, remote: false, name: nameOf(p), info: p.replace(Quickshell.env("HOME"), "~").replace(/\/[^/]+$/, "") }));
    }
    property var results: []
    property int page: 0
    property int lastPage: 1
    property bool loading: false
    property string lastQuery: "\u0000"
    property string status: ""
    property string downloading: ""

    readonly property var items: online ? results : localItems
    readonly property var selected: items.length ? items[Math.max(0, Math.min(view.currentIndex, items.length - 1))] : null

    function nameOf(p) { return p.split("/").pop().replace(/\.[^.]+$/, "").replace(/[-_]+/g, " ") }
    function localPathFor(item) {
        const ext = item.full.split(".").pop();
        return `${Settings.wallpaperDir}/wallhaven-${item.id}.${ext}`;
    }
    function isSaved(item) { return item.remote && Settings.wallpapers.some(p => p.endsWith(`wallhaven-${item.id}.${item.full.split(".").pop()}`)) }

    function fetchPage(p) {
        loading = true;
        const q = search.text.trim();
        const params = `categories=111&purity=100&atleast=1920x1080&page=${p}` +
            (q ? `&q=${encodeURIComponent(q)}&sorting=relevance` : "&sorting=toplist&topRange=1M");
        api.command = ["curl", "-sfL", "--max-time", "20", "https://wallhaven.cc/api/v1/search?" + params];
        api.page = p;
        api.running = true;
        status = p === 1 ? "Buscando…" : "";
    }

    function searchOnline() {
        lastQuery = search.text.trim();
        results = [];
        view.currentIndex = 0;
        fetchPage(1);
    }

    function download(item, applyAfter) {
        if (!item || !item.remote || downloading) return;
        const dest = localPathFor(item);
        if (isSaved(item)) {
            status = "Ya estaba guardado";
            if (applyAfter) apply(dest);
            return;
        }
        downloading = item.id;
        status = "Descargando…";
        dl.dest = dest;
        dl.applyAfter = applyAfter;
        dl.command = ["sh", "-c", 'mkdir -p "$(dirname "$1")" && curl -sfL --max-time 180 -o "$1.part" "$2" && mv "$1.part" "$1"', "sh", dest, item.full];
        dl.running = true;
    }

    function apply(path) {
        if (!path) return;
        Settings.setWallpaper(path);
        Settings.picker = false;
    }

    function accept() {
        if (!selected && !online) return;
        if (online) {
            if (search.text.trim() !== lastQuery || results.length === 0) searchOnline();
            else download(selected, true);
        } else apply(selected.full);
    }

    function setMode(o) {
        if (online === o) return;
        online = o;
        status = "";
        view.currentIndex = 0;
        if (online && results.length === 0) searchOnline();
        search.forceActiveFocus();
    }

    // qs ipc call wallpaper search "spiderman"   /   qs ipc call wallpaper open
    IpcHandler {
        target: "wallpaper"
        function open(): void { Settings.picker = true }
        function search(query: string): void {
            Settings.picker = true;
            Qt.callLater(() => { search.text = query; win.online = true; win.searchOnline(); });
        }
        function next(): void { view.incrementCurrentIndex() }
        function prev(): void { view.decrementCurrentIndex() }
        function state(): string { return `${win.online ? "internet" : "local"} ${view.currentIndex + 1}/${win.items.length} q="${win.lastQuery}"` }
        function save(): void { win.download(win.selected, false) }
    }

    Process {
        id: api
        property int page: 1
        stdout: StdioCollector {
            onStreamFinished: {
                win.loading = false;
                try {
                    const r = JSON.parse(text);
                    const items = r.data.map(d => ({
                        id: d.id, src: d.thumbs.large, full: d.path, remote: true,
                        name: d.resolution, info: `${(d.file_size / 1048576).toFixed(1)} MB · ${d.category} · wallhaven.cc`,
                    }));
                    if (api.page === 1) {
                        win.results = items;
                        // Búsqueda nueva: empezar siempre por el primero
                        Qt.callLater(() => { view.positionViewAtIndex(0, PathView.Center); view.currentIndex = 0; view.prevIndex = 0; });
                    } else {
                        // Reemplazar el modelo reinicia el PathView: volver a donde estabas
                        const keep = view.currentIndex;
                        win.results = win.results.concat(items);
                        Qt.callLater(() => { view.positionViewAtIndex(keep, PathView.Center); view.currentIndex = keep; });
                    }
                    win.page = r.meta.current_page;
                    win.lastPage = r.meta.last_page;
                    win.status = win.results.length ? "" : "Sin resultados";
                } catch (e) {
                    win.status = "No se pudo conectar con wallhaven.cc";
                }
            }
        }
        onExited: code => { if (code !== 0) { win.loading = false; win.status = "No se pudo conectar con wallhaven.cc"; } }
    }

    Process {
        id: dl
        property string dest
        property bool applyAfter
        onExited: code => {
            win.downloading = "";
            if (code === 0) {
                win.status = "Guardado en ~/Imágenes/Wallpapers";
                Settings.refreshWallpapers();
                if (dl.applyAfter) win.apply(dl.dest);
            } else win.status = "Error al descargar";
        }
    }

    // ------------------------------------------------------------- ventana
    visible: Settings.picker || t > 0.001
    screen: Quickshell.screens.find(s => s.name === Hyprland.focusedMonitor?.name) ?? Quickshell.screens[0]
    anchors { top: true; bottom: true; left: true; right: true }
    exclusionMode: ExclusionMode.Ignore
    color: Qt.rgba(0, 0, 0, 0.5 * t)

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "quickshell-wallpaper"
    WlrLayershell.keyboardFocus: Settings.picker ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    onVisibleChanged: {
        if (!visible) return;
        search.text = "";
        status = "";
        online = false;
        results = [];
        page = 0;
        lastPage = 1;
        lastQuery = "\u0000";
        Settings.refreshWallpapers();
        const i = Settings.wallpapers.indexOf(Settings.currentWallpaper);
        view.positionViewAtIndex(Math.max(0, i), PathView.Center);
        view.currentIndex = Math.max(0, i);
        search.forceActiveFocus();
    }

    // Fondo: el seleccionado en grande y tenue (con fundido al cambiar)
    Item {
        anchors.fill: parent
        opacity: 0.35 * win.t
        property bool flip: false
        property string src: win.selected ? win.selected.src : ""
        onSrcChanged: { flip = !flip; (flip ? bgA : bgB).source = src; }
        Image { id: bgA; anchors.fill: parent; fillMode: Image.PreserveAspectCrop; asynchronous: true; sourceSize.width: 960
                opacity: parent.flip ? 1 : 0; Behavior on opacity { NumberAnimation { duration: 450 } } }
        Image { id: bgB; anchors.fill: parent; fillMode: Image.PreserveAspectCrop; asynchronous: true; sourceSize.width: 960
                opacity: parent.flip ? 0 : 1; Behavior on opacity { NumberAnimation { duration: 450 } } }
    }

    MouseArea { anchors.fill: parent; onClicked: Settings.picker = false }

    Column {
        anchors.centerIn: parent
        anchors.verticalCenterOffset: (1 - win.t) * 60
        opacity: win.t
        spacing: 22

        // Selector de modo
        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            width: 300; height: 40; radius: 20
            color: Theme.bgSolid
            border.color: Theme.border
            Rectangle {
                y: 4
                x: win.online ? parent.width / 2 : 4
                width: parent.width / 2 - 4; height: 32; radius: 16
                color: Theme.accent
                Behavior on x { SpringAnimation { spring: 4; damping: 0.35; epsilon: 0.3 } }
            }
            Row {
                anchors.fill: parent
                Repeater {
                    model: [{ icon: "󰋩", name: "Mi PC", online: false }, { icon: "󰖟", name: "Internet", online: true }]
                    Item {
                        required property var modelData
                        width: 150; height: 40
                        Txt {
                            anchors.centerIn: parent
                            text: `${modelData.icon}  ${modelData.name}`
                            font.bold: win.online === modelData.online
                            color: win.online === modelData.online ? Theme.base : Theme.fgDim
                            Behavior on color { ColorAnimation { duration: 200 } }
                        }
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: win.setMode(modelData.online) }
                    }
                }
            }
        }

        // Buscador
        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            width: 520
            height: 46
            radius: 23
            color: Theme.bgSolid
            border.color: search.activeFocus ? Theme.accent : Theme.border
            Txt {
                id: searchIcon
                x: 18; anchors.verticalCenter: parent.verticalCenter
                text: win.online ? "󰖟" : "󰍉"
                color: Theme.fgDim
                font.pixelSize: 16
                RotationAnimation on rotation {
                    running: win.loading
                    from: 0; to: 360; duration: 1000; loops: Animation.Infinite
                    onRunningChanged: if (!running) searchIcon.rotation = 0
                }
            }
            TextInput {
                id: search
                anchors.fill: parent
                anchors.leftMargin: 46
                anchors.rightMargin: 100
                verticalAlignment: TextInput.AlignVCenter
                color: Theme.fg
                selectionColor: Theme.accent
                font.family: Theme.font
                font.pixelSize: 14
                onTextChanged: if (!win.online) view.currentIndex = 0
                Keys.onLeftPressed: view.decrementCurrentIndex()
                Keys.onRightPressed: view.incrementCurrentIndex()
                Keys.onReturnPressed: win.accept()
                Keys.onEnterPressed: win.accept()
                Keys.onEscapePressed: Settings.picker = false
                Keys.onTabPressed: win.setMode(!win.online)
                Keys.onBacktabPressed: win.setMode(!win.online)
                Keys.onPressed: e => {
                    const ctrl = e.modifiers & Qt.ControlModifier;
                    if (ctrl && e.key === Qt.Key_R && win.items.length) {
                        view.currentIndex = Math.floor(Math.random() * win.items.length);
                        e.accepted = true;
                    } else if (ctrl && e.key === Qt.Key_S && win.online) {
                        win.download(win.selected, false);
                        e.accepted = true;
                    }
                }
                Txt {
                    anchors.verticalCenter: parent.verticalCenter
                    text: win.online ? "Buscar en internet… (ej: spiderman) y Enter" : "Buscar en mis fondos…"
                    color: Theme.fgDim
                    visible: search.text.length === 0
                }
            }
            Txt {
                anchors.right: parent.right
                anchors.rightMargin: 18
                anchors.verticalCenter: parent.verticalCenter
                text: win.items.length ? `${view.currentIndex + 1} / ${win.items.length}${win.online && win.page < win.lastPage ? "+" : ""}` : "0"
                color: Theme.fgDim
                font.pixelSize: 12
            }
        }

        // Carrusel
        PathView {
            id: view
            width: win.width
            height: 400
            model: win.items
            pathItemCount: Math.min(7, Math.max(1, win.items.length))
            preferredHighlightBegin: 0.5
            preferredHighlightEnd: 0.5
            highlightRangeMode: PathView.StrictlyEnforceRange
            highlightMoveDuration: 420
            snapMode: PathView.SnapToItem
            cacheItemCount: 4

            readonly property real spread: Math.min(win.width * 0.42, 260 * pathItemCount / 2 + 200)

            // Cargar la siguiente página al acercarse al final, solo avanzando hacia
            // la derecha (← desde el primero da la vuelta al último sin cargar más)
            property int prevIndex: 0
            onCurrentIndexChanged: {
                const forward = currentIndex === prevIndex + 1;
                prevIndex = currentIndex;
                if (forward && win.online && !win.loading && win.page < win.lastPage && currentIndex >= win.results.length - 5)
                    win.fetchPage(win.page + 1);
            }

            path: Path {
                startX: view.width / 2 - view.spread; startY: view.height / 2
                PathAttribute { name: "itemScale"; value: 0.55 }
                PathAttribute { name: "itemAngle"; value: 55 }
                PathAttribute { name: "itemOpacity"; value: 0.25 }
                PathAttribute { name: "itemZ"; value: 0 }
                PathLine { x: view.width / 2; y: view.height / 2 }
                PathAttribute { name: "itemScale"; value: 1 }
                PathAttribute { name: "itemAngle"; value: 0 }
                PathAttribute { name: "itemOpacity"; value: 1 }
                PathAttribute { name: "itemZ"; value: 100 }
                PathLine { x: view.width / 2 + view.spread; y: view.height / 2 }
                PathAttribute { name: "itemScale"; value: 0.55 }
                PathAttribute { name: "itemAngle"; value: -55 }
                PathAttribute { name: "itemOpacity"; value: 0.25 }
                PathAttribute { name: "itemZ"; value: 0 }
            }

            delegate: Item {
                id: card
                required property var modelData
                required property int index
                readonly property bool isCurrent: PathView.isCurrentItem
                readonly property bool isApplied: modelData.remote
                    ? Settings.currentWallpaper.endsWith(`wallhaven-${modelData.id}.${modelData.full.split(".").pop()}`)
                    : modelData.full === Settings.currentWallpaper
                readonly property bool saved: win.isSaved(modelData)
                property real angle: PathView.itemAngle ?? 0

                width: 600
                height: 338
                scale: (PathView.itemScale ?? 1) * (hover.containsMouse && isCurrent ? 1.03 : 1)
                opacity: PathView.itemOpacity ?? 1
                z: PathView.itemZ ?? 0
                transform: Rotation {
                    origin.x: card.width / 2
                    origin.y: card.height / 2
                    axis { x: 0; y: 1; z: 0 }
                    angle: card.angle
                }
                Behavior on scale { NumberAnimation { duration: 180 } }

                ClippingRectangle {
                    anchors.fill: parent
                    radius: 24
                    color: Theme.bgAlt
                    Image {
                        anchors.fill: parent
                        source: card.modelData.src
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        sourceSize.width: 640
                        opacity: status === Image.Ready ? 1 : 0
                        Behavior on opacity { NumberAnimation { duration: 300 } }
                    }
                    // Alta resolución para el del centro cuando viene de internet
                    Image {
                        anchors.fill: parent
                        source: card.isCurrent && card.modelData.remote ? card.modelData.full : ""
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        sourceSize.width: 1280
                        opacity: status === Image.Ready ? 1 : 0
                        Behavior on opacity { NumberAnimation { duration: 400 } }
                    }
                    // Barra de descarga
                    Rectangle {
                        visible: win.downloading === card.modelData.id
                        anchors.bottom: parent.bottom
                        width: parent.width
                        height: 5
                        color: Theme.track
                        Rectangle {
                            id: dlBar
                            height: parent.height
                            color: Theme.accent
                            SequentialAnimation on x {
                                running: win.downloading === card.modelData.id
                                loops: Animation.Infinite
                                NumberAnimation { from: -150; to: 600; duration: 1100; easing.type: Easing.InOutQuad }
                            }
                            width: 150
                        }
                    }
                }
                Rectangle {
                    anchors.fill: parent
                    radius: 24
                    color: "transparent"
                    border.width: card.isCurrent ? 3 : 1
                    border.color: card.isCurrent ? Theme.accent : Theme.border
                }
                Row {
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: 14
                    spacing: 6
                    Rectangle {
                        visible: card.saved && !card.isApplied
                        width: 30; height: 30; radius: 15
                        color: Theme.bgSolid
                        Txt { anchors.centerIn: parent; text: "󰉍"; color: Theme.accent; font.pixelSize: 15 }
                    }
                    Rectangle {
                        visible: card.isApplied
                        width: 30; height: 30; radius: 15
                        color: Theme.accent
                        Txt { anchors.centerIn: parent; text: "󰄬"; color: Theme.base; font.pixelSize: 16 }
                    }
                }
                MouseArea {
                    id: hover
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (!card.isCurrent) { view.currentIndex = card.index; return; }
                        if (card.modelData.remote) win.download(card.modelData, true);
                        else win.apply(card.modelData.full);
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.NoButton
                onWheel: w => w.angleDelta.y > 0 || w.angleDelta.x > 0 ? view.decrementCurrentIndex() : view.incrementCurrentIndex()
            }

            Txt {
                anchors.centerIn: parent
                visible: win.items.length === 0
                text: win.online
                    ? (win.loading ? "Buscando en wallhaven.cc…" : win.status || "Escribe algo y presiona Enter")
                    : Settings.wallpapers.length ? "Ningún fondo coincide con la búsqueda" : "No hay fondos. Agrega imágenes en ~/Imágenes/Wallpapers"
                color: Theme.fgDim
                font.pixelSize: 15
            }
        }

        // Nombre, info y ayuda
        Column {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 8
            Txt {
                anchors.horizontalCenter: parent.horizontalCenter
                text: win.selected ? win.selected.name : ""
                font.pixelSize: 20
                font.bold: true
            }
            Txt {
                anchors.horizontalCenter: parent.horizontalCenter
                text: win.status || (win.selected ? win.selected.info : "")
                color: win.status.startsWith("Error") || win.status.startsWith("No se") ? Theme.urgent : Theme.fgDim
                font.pixelSize: 11
            }
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 18
                topPadding: 10
                Repeater {
                    model: win.online
                        ? ["Tab  mi PC", "Enter  buscar / guardar y aplicar", "Ctrl+S  solo guardar", "←/→  moverte", "Esc  cerrar"]
                        : ["Tab  internet", "Enter  aplicar", "←/→  moverte", "Ctrl+R  aleatorio", "Esc  cerrar"]
                    Txt { required property string modelData; text: modelData; color: Theme.fgDim; font.pixelSize: 11 }
                }
            }
            Toggle {
                anchors.horizontalCenter: parent.horizontalCenter
                width: 330
                label: "Generar colores del fondo al aplicar"
                checked: Settings.opts.autoColors
                onToggled: Settings.opts.autoColors = !Settings.opts.autoColors
            }
        }
    }
}
