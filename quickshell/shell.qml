//@ pragma UseQApplication
import Quickshell
import QtQuick

// Punto de entrada de quickshell (`qs`). Una barra + isla por monitor.
ShellRoot {
    // Fuerza a crear los servicios al arrancar (notificaciones y OSD por IPC)
    Component.onCompleted: { Notifs.count; Osd.shown; Settings.open; Panels.current; }

    SettingsWindow {}
    PowerMenu {}
    WallpaperPicker {}

    Variants {
        model: Quickshell.screens
        Bar {}
    }
}
