pragma Singleton
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import QtQuick

// ==============================================================================
// AJUSTES PERSISTENTES
// Se guardan en ~/.local/state/bombayashi/settings.json (fuera del repo, así
// cada máquina tiene los suyos). Los cambios de ventanas/bordes se aplican en
// vivo a Hyprland con `hyprctl eval` y se re-aplican si Hyprland recarga config.
// Abrir la pantalla:  qs ipc call settings toggle   (SUPER + S)
// ==============================================================================
Singleton {
    id: root

    property bool open: false
    property int tab: 0
    property alias opts: adapter

    readonly property string dir: Quickshell.env("HOME") + "/.local/state/bombayashi"
    readonly property string wallpaperDir: Quickshell.env("HOME") + "/Imágenes/Wallpapers"

    readonly property var presets: [
        { name: "Monocromo",   bg: "#0d0d0d", fg: "#e6e6e6", fgDim: "#808080", accent: "#ffffff",
          ansi: ["#1a1a1a", "#d47a7a", "#9ec49a", "#d6c48f", "#9aa8c4", "#bf9ac4", "#93c2c2", "#cccccc", "#555555", "#e89b9b", "#b6d9b1", "#e8d9a8", "#b7c3dc", "#d6b6db", "#b0dada", "#ffffff"] },
        { name: "Dracula",     bg: "#1e1f29", fg: "#f8f8f2", fgDim: "#6272a4", accent: "#bd93f9",
          ansi: ["#21222c", "#ff5555", "#50fa7b", "#f1fa8c", "#bd93f9", "#ff79c6", "#8be9fd", "#f8f8f2", "#6272a4", "#ff6e6e", "#69ff94", "#ffffa5", "#d6acff", "#ff92df", "#a4ffff", "#ffffff"] },
        { name: "Catppuccin",  bg: "#1e1e2e", fg: "#cdd6f4", fgDim: "#7f849c", accent: "#cba6f7",
          ansi: ["#45475a", "#f38ba8", "#a6e3a1", "#f9e2af", "#89b4fa", "#f5c2e7", "#94e2d5", "#bac2de", "#585b70", "#f38ba8", "#a6e3a1", "#f9e2af", "#89b4fa", "#f5c2e7", "#94e2d5", "#a6adc8"] },
        { name: "Tokyo Night", bg: "#1a1b26", fg: "#c0caf5", fgDim: "#565f89", accent: "#7aa2f7",
          ansi: ["#15161e", "#f7768e", "#9ece6a", "#e0af68", "#7aa2f7", "#bb9af7", "#7dcfff", "#a9b1d6", "#414868", "#f7768e", "#9ece6a", "#e0af68", "#7aa2f7", "#bb9af7", "#7dcfff", "#c0caf5"] },
        { name: "Nord",        bg: "#2e3440", fg: "#eceff4", fgDim: "#7b88a1", accent: "#88c0d0",
          ansi: ["#3b4252", "#bf616a", "#a3be8c", "#ebcb8b", "#81a1c1", "#b48ead", "#88c0d0", "#e5e9f0", "#4c566a", "#bf616a", "#a3be8c", "#ebcb8b", "#81a1c1", "#b48ead", "#8fbcbb", "#eceff4"] },
        { name: "Gruvbox",     bg: "#1d2021", fg: "#ebdbb2", fgDim: "#928374", accent: "#fabd2f",
          ansi: ["#282828", "#cc241d", "#98971a", "#d79921", "#458588", "#b16286", "#689d6a", "#a89984", "#928374", "#fb4934", "#b8bb26", "#fabd2f", "#83a598", "#d3869b", "#8ec07c", "#ebdbb2"] },
        { name: "Rosé Pine",   bg: "#191724", fg: "#e0def4", fgDim: "#6e6a86", accent: "#ebbcba",
          ansi: ["#26233a", "#eb6f92", "#31748f", "#f6c177", "#9ccfd8", "#c4a7e7", "#ebbcba", "#e0def4", "#6e6a86", "#eb6f92", "#31748f", "#f6c177", "#9ccfd8", "#c4a7e7", "#ebbcba", "#e0def4"] },
        { name: "Everforest",  bg: "#272e33", fg: "#d3c6aa", fgDim: "#859289", accent: "#a7c080",
          ansi: ["#414b50", "#e67e80", "#a7c080", "#dbbc7f", "#7fbbb3", "#d699b6", "#83c092", "#d3c6aa", "#475258", "#e67e80", "#a7c080", "#dbbc7f", "#7fbbb3", "#d699b6", "#83c092", "#d3c6aa"] },
    ]

    readonly property var accents: [
        "#ffffff", "#ff6b6b", "#ffa94d", "#ffd43b", "#69db7c",
        "#38d9a9", "#4dabf7", "#748ffc", "#b197fc", "#f783ac",
    ]

    function applyPreset(p) {
        opts.bg = p.bg;
        opts.fg = p.fg;
        opts.fgDim = p.fgDim;
        opts.accent = p.accent;
        opts.palette = p.name;
    }

    // Fondo que se ve ahora: el elegido, o el primero de wallpaper/ del repo
    property string defaultWallpaper: ""
    readonly property string currentWallpaper: opts.wallpaper || defaultWallpaper

    Process {
        running: true
        command: ["sh", "-c", "find \"$(readlink -f ~/.config/quickshell)/../wallpaper\" -maxdepth 1 -type f | sort | head -1 | xargs -r -d '\\n' readlink -f"]
        stdout: StdioCollector { onStreamFinished: root.defaultWallpaper = text.trim() }
    }

    // Fondos disponibles: wallpaper/ del repo, ~/Imágenes/Wallpapers y los de Hyprland
    property var wallpapers: []
    function refreshWallpapers() { wallList.running = true }
    Process {
        id: wallList
        running: true
        command: ["sh", "-c",
            `mkdir -p "${root.wallpaperDir}"; ` +
            `find "$(readlink -f ~/.config/quickshell)/../wallpaper" "${root.wallpaperDir}" /usr/share/hypr ` +
            `-maxdepth 2 -type f \\( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' \\) ` +
            `! -iname 'lockdead*' 2>/dev/null | xargs -r -d '\\n' readlink -f | sort -u`]
        stdout: StdioCollector {
            onStreamFinished: root.wallpapers = text.split("\n").filter(p => p.length > 0)
        }
    }

    // Selector de fondos (carrusel, SUPER + W)
    property bool picker: false

    function setWallpaper(path) {
        opts.wallpaper = path;
        Quickshell.execDetached(["hyprctl", "hyprpaper", "wallpaper", "," + path]);
        if (opts.autoColors) colorsFromWallpaper();
    }

    // Paleta Material You a partir del fondo actual (matugen)
    property bool generating: false
    function colorsFromWallpaper() {
        if (!currentWallpaper) return;
        generating = true;
        matugen.command = ["matugen", "image", currentWallpaper, "--dry-run", "-j", "hex",
                           "--prefer", "saturation", "-t", opts.matugenScheme];
        matugen.running = true;
    }

    function resetWindows() {
        opts.gapsIn = 5; opts.gapsOut = 0; opts.border = 2; opts.rounding = 10;
        opts.blur = true; opts.blurSize = 8; opts.shadow = true; opts.animations = true;
    }

    function _hex(c, alpha) {
        const h = x => ("0" + Math.round(x * 255).toString(16)).slice(-2);
        return h(c.r) + h(c.g) + h(c.b) + (alpha ?? "");
    }

    function applyHyprland() {
        const o = opts;
        const lua = `hl.config({
            general = {
                gaps_in = ${o.gapsIn},
                gaps_out = { top = 0, right = ${o.gapsOut}, bottom = ${Math.max(10, o.gapsOut)}, left = ${o.gapsOut} },
                border_size = ${o.border},
                col = {
                    active_border = { colors = { "rgba(${_hex(Theme.accent, "ee")})", "rgba(${_hex(Theme.fgDim, "ee")})" }, angle = 45 },
                    inactive_border = "rgba(${_hex(Theme.track, "aa")})",
                },
            },
            decoration = {
                rounding = ${o.rounding},
                blur = { enabled = ${o.blur}, size = ${o.blurSize}, passes = 2, vibrancy = 0.17 },
                shadow = { enabled = ${o.shadow}, range = 14, render_power = 3, color = "rgba(00000099)" },
            },
            animations = { enabled = ${o.animations} },
        })`;
        hyprProc.command = ["hyprctl", "eval", lua];
        hyprProc.running = true;
    }

    Process { id: hyprProc }

    // Colores para rofi (los importa rofi/config.rasi al final)
    function writeRofi() {
        const h = c => "#" + _hex(c);
        rofiFile.setText(`/* Generado por quickshell (pantalla de ajustes). No editar a mano. */
* {
    bg:          ${h(Theme.base)}${("0" + Math.round(Math.min(1, opts.barOpacity + 0.05) * 255).toString(16)).slice(-2)};
    bg-solid:    ${h(Theme.base)};
    bg-alt:      ${h(Theme.bgAlt)};
    fg:          ${h(Theme.fg)};
    fg-dim:      ${h(Theme.fgDim)};
    accent:      ${h(Theme.accent)};
    accent-soft: ${h(Theme.accent)}26;
    border-col:  ${h(Theme.accent)}33;
}
`);
    }

    FileView { id: rofiFile; path: root.dir + "/rofi-colors.rasi" }

    // Tema de btop con la misma paleta (btop/btop.conf usa color_theme = "bombayashi")
    function writeBtop() {
        const h = c => "#" + _hex(c);
        const mix = (a, b, t) => h(Qt.rgba(a.r + (b.r - a.r) * t, a.g + (b.g - a.g) * t, a.b + (b.b - a.b) * t, 1));
        const A = Theme.accent, D = Theme.fgDim, F = Theme.fg;
        const grad = (name, from, to) =>
            `theme[${name}_start]="${h(from)}"\ntheme[${name}_mid]="${mix(from, to, 0.5)}"\ntheme[${name}_end]="${h(to)}"\n`;
        btopFile.setText(
`# Generado por quickshell (pantalla de ajustes). No editar a mano.
theme[main_bg]="${h(Theme.base)}"
theme[main_fg]="${h(F)}"
theme[title]="${h(F)}"
theme[hi_fg]="${h(A)}"
theme[selected_bg]="${h(Theme.track)}"
theme[selected_fg]="${h(A)}"
theme[inactive_fg]="${h(D)}"
theme[graph_text]="${h(D)}"
theme[meter_bg]="${h(Theme.track)}"
theme[proc_misc]="${h(A)}"
theme[cpu_box]="${mix(D, A, 0.6)}"
theme[mem_box]="${mix(D, A, 0.6)}"
theme[net_box]="${mix(D, A, 0.6)}"
theme[proc_box]="${mix(D, A, 0.6)}"
theme[div_line]="${h(Theme.track)}"
` + grad("temp", A, Theme.urgent) + grad("cpu", D, A) + grad("free", D, A) + grad("cached", D, A)
  + grad("available", D, A) + grad("used", D, A) + grad("download", D, A) + grad("upload", D, F)
  + grad("process", D, A));
    }

    // Colores de kitty (kitty/kitty.conf hace "include" de este archivo).
    // Paletas conocidas: sus 16 colores ANSI oficiales. Personalizada / del fondo:
    // una base neutra mezclada con el acento para que combine.
    readonly property var neutralAnsi: ["#15161e", "#f7768e", "#9ece6a", "#e0af68", "#7aa2f7", "#bb9af7", "#7dcfff", "#a9b1d6",
                                        "#414868", "#ff8fa3", "#b3e07f", "#f0c27e", "#93b4ff", "#cbb0ff", "#99dcff", "#c0caf5"]
    property string _lastKitty: ""

    function kittyAnsi() {
        const p = presets.find(x => x.name === opts.palette);
        if (p && p.ansi) return p.ansi;
        const h = c => "#" + _hex(c);
        const mixc = (a, b, t) => Qt.rgba(a.r + (b.r - a.r) * t, a.g + (b.g - a.g) * t, a.b + (b.b - a.b) * t, 1);
        const A = Theme.accent;
        const out = neutralAnsi.map(c => h(mixc(Qt.tint(c, "transparent"), A, 0.18)));
        out[0] = h(Theme.track); out[8] = h(Theme.fgDim);
        out[7] = h(Theme.fg);    out[15] = h(Qt.lighter(Theme.fg, 1.15));
        out[4] = h(A);           out[12] = h(Qt.lighter(A, 1.15));
        return out;
    }

    function writeKitty() {
        const h = c => "#" + _hex(c);
        const a = kittyAnsi();
        let txt = `# Generado por quickshell (pantalla de ajustes). No editar a mano.
foreground              ${h(Theme.fg)}
background              ${h(Theme.base)}
selection_foreground    ${h(Theme.base)}
selection_background    ${h(Theme.accent)}
cursor                  ${h(Theme.accent)}
cursor_text_color       ${h(Theme.base)}
url_color               ${h(Theme.accent)}
active_border_color     ${h(Theme.accent)}
inactive_border_color   ${h(Theme.track)}
active_tab_foreground   ${h(Theme.base)}
active_tab_background   ${h(Theme.accent)}
inactive_tab_foreground ${h(Theme.fgDim)}
inactive_tab_background ${h(Theme.bgAlt)}
tab_bar_background      ${h(Theme.base)}
`;
        for (let i = 0; i < 16; i++) txt += `color${i}${i < 10 ? " " : ""} ${a[i]}\n`;
        if (txt === _lastKitty) return;
        const first = _lastKitty === "";
        _lastKitty = txt;
        kittyFile.setText(txt);
        // Recargar las kitty abiertas (no hace falta al arrancar: ya leen el archivo)
        if (!first) kittyReload.restart();
    }

    FileView { id: kittyFile; path: root.dir + "/kitty-colors.conf" }
    Timer { id: kittyReload; interval: 250; onTriggered: Quickshell.execDetached(["pkill", "-USR1", "-x", "kitty"]) }

    FileView { id: btopFile; path: Quickshell.env("HOME") + "/.config/btop/themes/bombayashi.theme" }

    Process {
        id: matugen
        stdout: StdioCollector {
            onStreamFinished: {
                root.generating = false;
                try {
                    const c = JSON.parse(text).colors;
                    const get = k => c[k].dark.color;
                    root.opts.accent = get("primary");
                    root.opts.bg = get("surface_container_lowest");
                    root.opts.fg = get("on_surface");
                    root.opts.fgDim = get("outline");
                    root.opts.palette = "Fondo";
                } catch (e) {
                    console.warn("matugen: no se pudo leer la paleta", e);
                }
            }
        }
    }

    Timer { id: applyTimer; interval: 150; onTriggered: { root.applyHyprland(); root.writeRofi(); root.writeBtop(); root.writeKitty(); } }
    Timer { id: saveTimer; interval: 300; onTriggered: file.writeAdapter() }
    Timer { id: firstWrite; interval: 400; onTriggered: file.writeAdapter() }

    Connections {
        target: Hyprland
        function onRawEvent(ev) { if (ev.name === "configreloaded") applyTimer.restart() }
    }

    IpcHandler {
        target: "settings"
        function toggle(): void { root.open = !root.open }
        function open(tab: int): void { root.tab = tab; root.open = true }
        function close(): void { root.open = false }
        function preset(name: string): void {
            const p = root.presets.find(x => x.name.toLowerCase() === name.toLowerCase());
            if (p) root.applyPreset(p);
        }
        function wallpaper(path: string): void { root.setWallpaper(path) }
        function picker(): void { root.picker = !root.picker; root.open = false }
        function colorsFromWallpaper(): void { root.colorsFromWallpaper() }
    }

    FileView {
        id: file
        path: root.dir + "/settings.json"
        // Guardar con debounce: escribir dentro de este handler pisa cambios seguidos
        onAdapterUpdated: { saveTimer.restart(); applyTimer.restart(); }
        onLoaded: applyTimer.restart()
        onLoadFailed: err => {
            Quickshell.execDetached(["mkdir", "-p", root.dir]);
            firstWrite.start();
            applyTimer.restart();
        }

        JsonAdapter {
            id: adapter

            // Colores
            property string palette: "Monocromo"
            property string bg: "#0d0d0d"
            property string fg: "#e6e6e6"
            property string fgDim: "#808080"
            property string accent: "#ffffff"
            property real barOpacity: 0.88
            property real barScale: 1.3
            property bool autoColors: false
            property string matugenScheme: "scheme-tonal-spot"

            // Fondo
            property string wallpaper: ""

            // Barra / isla
            property bool showNet: true
            property bool showStats: true
            property bool islandGlow: true
            property bool visualizer: true
            property bool dnd: false

            // Ventanas (Hyprland)
            property int gapsIn: 5
            property int gapsOut: 0
            property int border: 2
            property int rounding: 10
            property bool blur: true
            property int blurSize: 8
            property bool shadow: true
            property bool animations: true
        }
    }
}
