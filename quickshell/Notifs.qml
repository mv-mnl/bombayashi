pragma Singleton
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications
import QtQuick

// ==============================================================================
// NOTIFICACIONES (reemplaza a swaync)
// - La última llega como aviso en la isla unos segundos.
// - Todas quedan en el historial (centro de notificaciones, SUPER + N) hasta
//   descartarlas o que la app las cierre.
// - No molestar (SUPER + CTRL + N): no muestra avisos, pero las guarda igual.
//   Las urgentes (critical) sí se muestran.
// IPC:  qs ipc call notifs dnd | clear | center
// ==============================================================================
Singleton {
    id: root

    property var current: null
    readonly property bool showing: current !== null
    readonly property bool dnd: Settings.opts.dnd
    readonly property var list: server.trackedNotifications.values
    readonly property var newest: list.slice().reverse()
    readonly property int count: list.length

    // Hora de llegada de cada notificación (la spec no la incluye)
    property var arrived: ({})
    // Reloj para refrescar los "hace X min"
    property date now: new Date()
    Timer { interval: 30000; running: root.count > 0; repeat: true; onTriggered: root.now = new Date() }

    function ago(n) {
        const t = arrived[n.id];
        if (!t) return "";
        const s = Math.max(0, (now.getTime() - t) / 1000);
        if (s < 60) return "ahora";
        if (s < 3600) return `hace ${Math.floor(s / 60)} min`;
        if (s < 86400) return `hace ${Math.floor(s / 3600)} h`;
        return Qt.formatDateTime(new Date(t), "dd/MM HH:mm");
    }

    // Ícono de la notificación, o "" si no existe en el tema (para usar un glifo)
    function iconFor(n) {
        if (!n) return "";
        let img = n.image || "";
        if (img.startsWith("image://icon/")) img = Quickshell.iconPath(img.slice(13), true);
        else if (img.startsWith("/")) img = "file://" + img;
        if (img) return img;
        for (const name of [n.appIcon, n.desktopEntry, (n.appName || "").toLowerCase()]) {
            if (!name) continue;
            if (name.startsWith("file:")) return name;
            if (name.startsWith("/")) return "file://" + name;
            const p = Quickshell.iconPath(name, true);
            if (p) return p;
        }
        return "";
    }

    function clearAll() {
        for (const n of list.slice()) n.dismiss();
        current = null;
    }

    function toggleDnd() {
        Settings.opts.dnd = !Settings.opts.dnd;
        if (Settings.opts.dnd) current = null;
    }

    NotificationServer {
        id: server
        keepOnReload: true
        bodySupported: true
        imageSupported: true
        actionsSupported: true
        persistenceSupported: true

        onNotification: n => {
            n.tracked = true;
            const a = Object.assign({}, root.arrived);
            a[n.id] = Date.now();
            root.arrived = a;
            root.now = new Date();

            const critical = n.urgency === NotificationUrgency.Critical;
            if (root.dnd && !critical) return;   // silenciada: solo al historial

            root.current = n;
            hideTimer.interval = critical ? 10000 : 5000;
            hideTimer.restart();
            n.closed.connect(() => { if (root.current === n) root.current = null; });
        }
    }

    Timer { id: hideTimer; onTriggered: root.current = null }

    IpcHandler {
        target: "notifs"
        function dnd(): void { root.toggleDnd() }
        function clear(): void { root.clearAll() }
        function center(): void { Panels.toggle("notifications") }
    }
}
