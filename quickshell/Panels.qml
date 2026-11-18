pragma Singleton
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import QtQuick

// ==============================================================================
// PANELES DE LA ISLA (reemplazan los menús de rofi)
// La isla se transforma en el panel pedido. Desde fuera:
//   qs ipc call panel toggle wifi|bluetooth|audio|brightness|clipboard|system
//   qs ipc call panel toggle power      (menú de apagado a pantalla completa)
// ==============================================================================
Singleton {
    id: root

    property string current: ""     // panel abierto en la isla ("" = ninguno)
    property string monitor: ""     // monitor donde se abrió
    property bool power: false      // menú de apagado

    readonly property var sizes: ({
        wifi:       [460, 470],
        bluetooth:  [460, 450],
        audio:      [520, 500],
        brightness: [420, 190],
        clipboard:  [540, 520],
        system:     [560, 560],
        notifications: [520, 580],
    })

    function toggle(name) {
        if (name === "power") { power = !power; current = ""; return; }
        if (current === name) { current = ""; return; }
        monitor = Hyprland.focusedMonitor?.name ?? "";
        current = name;
        power = false;
    }

    function close() { current = ""; power = false; }

    IpcHandler {
        target: "panel"
        function toggle(name: string): void { root.toggle(name) }
        function close(): void { root.close() }
    }
}
