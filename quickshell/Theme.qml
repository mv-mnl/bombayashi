pragma Singleton
import Quickshell
import QtQuick

// Paleta y medidas compartidas. Los colores salen de Settings (editables en la
// pantalla de ajustes); el resto se deriva de ellos.
Singleton {
    readonly property var o: Settings.opts

    readonly property color base:    o.bg
    readonly property color bg:      Qt.rgba(base.r, base.g, base.b, o.barOpacity)
    readonly property color bgSolid: Qt.rgba(base.r, base.g, base.b, Math.max(0.94, o.barOpacity))
    readonly property color fg:      o.fg
    readonly property color fgDim:   o.fgDim
    readonly property color accent:  o.accent
    readonly property color bgAlt:   Qt.tint(base, Qt.rgba(fg.r, fg.g, fg.b, 0.07))
    readonly property color track:   Qt.tint(base, Qt.rgba(fg.r, fg.g, fg.b, 0.16))
    readonly property color border:  Qt.rgba(accent.r, accent.g, accent.b, 0.2)
    readonly property color urgent:  "#ff6b6b"

    function alpha(c, a) { return Qt.rgba(c.r, c.g, c.b, a) }

    readonly property string font: "JetBrainsMono Nerd Font"
    readonly property int fontSize: 12

    // Tamaño de la barra / isla compacta (ajustable en SUPER + S -> Barra e isla)
    readonly property real barScale: o.barScale > 0 ? o.barScale : 1.3
    function s(x) { return Math.round(x * barScale) }
    readonly property int barFont: s(12)

    readonly property int barHeight: s(34)
    readonly property int margin: 6
}
