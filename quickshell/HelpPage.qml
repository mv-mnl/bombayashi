import QtQuick

// ==============================================================================
// AYUDA: guía completa del escritorio (pestaña "Ayuda" de SUPER + S, o SUPER + F1)
// Cada sección: ícono, título, introducción y filas [tecla / dónde, explicación].
// El buscador filtra filas por cualquier palabra.
// ==============================================================================
Column {
    id: help
    width: parent?.width ?? 0
    spacing: 14

    readonly property var sections: [
        {
            icon: "󰋗", title: "Qué es todo esto",
            intro: "Tu escritorio es Hyprland (el gestor de ventanas) más una capa visual hecha con quickshell: la barra de arriba, la isla dinámica del centro, los paneles que salen de ella, el menú de apagado, el carrusel de fondos y esta pantalla de ajustes. Rofi se usa para el lanzador de apps y algunos menús; kitty es la terminal. Todo comparte la misma paleta de colores, que eliges aquí en Colores.",
            items: [
                ["SUPER", "La tecla de Windows. Casi todos los atajos empiezan con ella."],
                ["SUPER + S", "Abre esta pantalla de ajustes (colores, fondo, barra, ventanas y esta ayuda)."],
                ["SUPER + F1", "Abre directamente esta ayuda."],
                ["Esc / clic afuera", "Cierra cualquier panel, la isla expandida, los ajustes, el carrusel o el menú de apagado."],
            ]
        },
        {
            icon: "󰍜", title: "La isla dinámica (centro de la barra)",
            intro: "Una sola píldora que cambia de forma con un efecto de resorte según lo que pase. Prioridad: expandida › panel abierto › notificación › volumen/brillo › música › reposo.",
            items: [
                ["Reposo", "Muestra la hora y la fecha. El puntito parpadea si tienes notificaciones sin leer."],
                ["Música", "Cuando algo suena (Spotify, navegador…): carátula girando, canción · artista y un visualizador de audio. El borde 'respira'."],
                ["Volumen / brillo", "Al usar las teclas multimedia, la rueda o los sliders aparece una barra de nivel durante ~2 s."],
                ["Notificación", "Llega como aviso 5 s (urgentes 10 s, con borde rojo). Clic en el aviso: lo quita y abre la isla."],
                ["Clic en la isla / SUPER + A", "La expande: reloj grande, tarjeta de música con anterior/pausa/siguiente y progreso, slider de volumen (y brillo en laptop) y accesos rápidos."],
                ["Accesos rápidos", "󰤨 Wi-Fi · 󰂯 Bluetooth · 󰅍 Portapapeles · 󰌾 Bloquear · 󰒓 Ajustes · ⏻ Apagar."],
                ["Contador 󰂚 (expandida)", "Clic abre el centro de notificaciones; clic derecho activa/desactiva No molestar."],
                ["Rueda sobre la isla", "Con la isla compacta sube/baja el volumen. Con un panel abierto la rueda solo hace scroll."],
                ["Cerrar la expandida", "Saca el mouse de encima, haz clic afuera o pulsa Esc."],
            ]
        },
        {
            icon: "󰕮", title: "La barra",
            intro: "Tres píldoras: izquierda (workspaces y red), centro (la isla) y derecha (sistema). Todo es clicable.",
            items: [
                ["Workspaces", "El activo es una píldora larga; gris = tiene ventanas; oscuro = vacío. Clic para ir, rueda para cambiar."],
                ["󰁝 / 󰁅 red", "Velocidad de subida / bajada en vivo. Clic abre el panel de Wi-Fi."],
                ["󰕾 volumen", "Clic: panel de sonido · clic derecho: silenciar · rueda: subir/bajar."],
                ["󰃠 brillo", "Solo en pantallas con control de brillo (laptop). Clic: panel · rueda: subir/bajar."],
                ["CPU / GPU / RAM", "Uso en vivo (CPU con temperatura; se pone roja ≥ 85 °C). Clic: panel de Sistema · clic derecho en CPU o RAM: abre btop."],
                ["Batería", "Solo en laptop. Clic: panel de Sistema."],
                ["󰂚 campana", "Cuántas notificaciones tienes; se sacude cuando llega una. Clic: centro de notificaciones · clic derecho: No molestar (campana tachada)."],
                ["⏻", "Clic: menú de apagado · clic derecho: bloquear al instante."],
                ["Tamaño", "SUPER + S › Barra e isla › 'Tamaño de la barra y la isla' (1.0× a 1.8×)."],
            ]
        },
        {
            icon: "󰕰", title: "Paneles que salen de la isla",
            intro: "La isla se transforma en el panel. Se cierran con Esc, clic afuera, clic en un área vacía de la isla o volviendo a pulsar su atajo.",
            items: [
                ["Wi-Fi · SUPER + SHIFT + N", "Redes con señal y candado. Clic conecta (las guardadas directo; las nuevas piden contraseña ahí mismo). Clic derecho en la activa: desconectar. 󰑐 escanea, el interruptor apaga el wifi. Muestra el Ethernet si estás por cable."],
                ["Bluetooth · SUPER + SHIFT + B", "Dispositivos con ícono y batería. Clic: conectar / desconectar / emparejar. Clic derecho en uno emparejado: olvidarlo. Busca dispositivos mientras está abierto."],
                ["Sonido · SUPER + SHIFT + V", "Volumen general y mute, elegir la salida (monitor, parlantes, audífonos, EasyEffects) y un mezclador por aplicación con su slider y medidor de nivel en vivo."],
                ["Brillo", "Slider y botones 10–100 %. Solo laptop."],
                ["Portapapeles · SUPER + K", "Historial con búsqueda y miniaturas de imágenes. Escribe para filtrar · ↑/↓ moverte · Enter copiar · 1–9 copiar directo · clic derecho borrar una · 'Borrar todo'."],
                ["Sistema · clic en CPU/RAM", "Medidores de CPU (°C), RAM, GPU y disco, gráfica de los últimos 2 min, perfil de energía (Ahorro / Equilibrado / Rendimiento), batería y los 5 procesos que más consumen. Botón para abrir btop."],
                ["Notificaciones · SUPER + N", "Ver la sección Notificaciones."],
            ]
        },
        {
            icon: "󰂚", title: "Notificaciones y No molestar",
            intro: "Quickshell es el servidor de notificaciones (reemplaza a swaync). Todas quedan en el historial hasta que las descartes o la app las cierre.",
            items: [
                ["SUPER + N", "Abre el centro: de la más nueva a la más vieja, con app y hora ('ahora', 'hace 5 min')."],
                ["Clic en una", "Expande el texto completo. Clic medio o ✕: descartarla. 'Limpiar' borra todas."],
                ["Botones de acción", "Si la app los manda (Responder, Abrir…) aparecen debajo y funcionan."],
                ["SUPER + CTRL + N", "No molestar: no salen avisos en la isla pero se guardan igual. Las urgentes sí salen. También: clic derecho en la campana o el interruptor del centro. Se recuerda entre reinicios."],
                ["Ojo", "El historial vive en memoria: se pierde si cierras sesión o quickshell se reinicia por completo."],
            ]
        },
        {
            icon: "󰒓", title: "Esta pantalla (SUPER + S)",
            intro: "Todo lo que cambies aquí se guarda solo en ~/.local/state/bombayashi/settings.json (fuera del repo: cada PC tiene los suyos) y se aplica en vivo.",
            items: [
                ["Colores › Paletas", "8 paletas: Monocromo, Dracula, Catppuccin, Tokyo Night, Nord, Gruvbox, Rosé Pine, Everforest. Cambian barra, isla, paneles, bordes de ventanas, rofi, kitty (incluidos sus 16 colores) y btop."],
                ["Colores › Acento", "10 colores o escribe tu hex (#rrggbb) y Enter."],
                ["Colores › Desde el fondo", "'Generar paleta del fondo' usa matugen para sacar los colores de tu fondo actual. Estilos: Suave, Vibrante, Expresivo, Mono. El interruptor lo hace automático cada vez que cambias de fondo."],
                ["Colores › Opacidad", "Transparencia de la barra, la isla y rofi (hay blur detrás)."],
                ["Fondo", "Vista previa del actual y galería de todos tus fondos; clic para aplicar. Botones: Abrir carpeta (~/Imágenes/Wallpapers), Recargar, Aleatorio y Carrusel (SUPER + W)."],
                ["Barra e isla", "Mostrar/ocultar velocidad de red y uso del sistema, brillo que respira, visualizador de audio, opacidad, tamaño de la barra, y botones para probar una notificación o el OSD."],
                ["Ventanas", "Espacio entre ventanas, margen con la pantalla, grosor del borde, esquinas redondeadas, blur (e intensidad), sombras y animaciones. 'Restablecer' vuelve a los valores por defecto. Si Hyprland recarga su config, se vuelven a aplicar solos."],
                ["Ayuda", "Esta guía. El buscador de arriba filtra por cualquier palabra."],
            ]
        },
        {
            icon: "󰸉", title: "Fondos de pantalla (SUPER + W)",
            intro: "Carrusel a pantalla completa con dos modos. Tab cambia entre ellos.",
            items: [
                ["Mi PC", "Tus fondos de wallpaper/ del repo, ~/Imágenes/Wallpapers y los de Hyprland. Escribe para filtrar, ←/→ o rueda para moverte, Enter o clic en el del centro para aplicar, Ctrl+R aleatorio."],
                ["Internet", "Busca en wallhaven.cc (solo contenido apto, ≥ 1920×1080). Escribe (ej: spiderman) y Enter. Sin texto muestra los más populares del mes. Se cargan más páginas al llegar al final."],
                ["Enter sobre un resultado", "Lo descarga a ~/Imágenes/Wallpapers y lo aplica. Ctrl+S solo lo guarda. Los ya guardados llevan 󰉍 y no se descargan dos veces."],
                ["✓", "Marca el fondo que tienes puesto."],
                ["Colores automáticos", "El interruptor de abajo genera la paleta del fondo al aplicarlo."],
                ["Al iniciar sesión", "Se pone el último fondo que elegiste."],
            ]
        },
        {
            icon: "󰐥", title: "Menú de apagado (SUPER + X)",
            intro: "Pantalla completa con reloj y tiempo encendida.",
            items: [
                ["←/→ o 1–5", "Elegir: Bloquear · Suspender · Cerrar sesión · Reiniciar · Apagar."],
                ["Enter / clic", "Ejecuta. Cerrar sesión, Reiniciar y Apagar piden confirmar ('¿Seguro?'): pulsa otra vez."],
                ["SUPER + L", "Bloquear directo (hyprlock)."],
                ["SUPER + SHIFT + Q", "Apaga al instante, sin preguntar. ¡Cuidado!"],
            ]
        },
        {
            icon: "󰌌", title: "Atajos · aplicaciones y menús",
            intro: "",
            items: [
                ["SUPER + Enter", "Terminal (kitty)."],
                ["SUPER + R", "Lanzador de aplicaciones (rofi)."],
                ["SUPER + SHIFT + R", "Menú de rofi con pestañas: apps, red, bluetooth, portapapeles, apagado, SSH, workspaces, volumen, brillo."],
                ["SUPER + B", "Firefox."],
                ["SUPER + E", "Mostrar/ocultar EasyEffects (workspace especial 'audio')."],
                ["SUPER + H", "SSH: hosts de ~/.ssh/config y los servidores donde ya entraste (known_hosts). Abre en kitty."],
                ["SUPER + G", "Saltar a un workspace por nombre (rofi)."],
                ["SUPER + SHIFT + K", "Bitwarden: contraseña maestra, buscas una cuenta y copias contraseña, usuario u OTP. Queda desbloqueado 15 min."],
                ["SUPER + A / S / W / N", "Isla expandida / Ajustes / Fondos / Notificaciones."],
                ["SUPER + SHIFT + N / B / V", "Paneles de Wi-Fi / Bluetooth / Sonido."],
                ["SUPER + K", "Portapapeles."],
                ["SUPER + X", "Menú de apagado."],
                ["SUPER + SPACE", "Cambiar teclado entre inglés (US) y español."],
            ]
        },
        {
            icon: "󰖲", title: "Atajos · ventanas",
            intro: "",
            items: [
                ["SUPER + C", "Cerrar la ventana."],
                ["SUPER + F", "Pantalla completa."],
                ["SUPER + SHIFT + F", "Hacerla flotante (60 % del monitor, centrada) o devolverla al mosaico."],
                ["SUPER + flechas", "Mover el foco a la ventana de ese lado."],
                ["SUPER + SHIFT + flechas", "Mover la ventana hacia ese lado."],
                ["SUPER + CTRL + flechas", "Redimensionar: mueve el borde entre ventanas (o agranda/achica la flotante). Se puede mantener."],
                ["SUPER + ALT + flechas", "Mover una ventana flotante 40 px. Se puede mantener."],
                ["SUPER + clic izq. y arrastrar", "Mover la ventana."],
                ["SUPER + clic der. y arrastrar", "Redimensionar la ventana."],
                ["Arrastrar el borde", "Pasa el mouse por el espacio entre ventanas y arrastra (sin teclas)."],
                ["SUPER + J / O", "Cambiar la división (horizontal ↔ vertical)."],
                ["SUPER + I", "Intercambiar con la siguiente ventana."],
                ["SUPER + P", "Pseudo-mosaico."],
                ["ALT + Tab", "Ciclar ventanas del workspace."],
            ]
        },
        {
            icon: "󰕰", title: "Atajos · workspaces",
            intro: "",
            items: [
                ["SUPER + 1…0", "Ir al workspace 1–10."],
                ["SUPER + SHIFT + 1…0", "Mover la ventana a ese workspace."],
                ["SUPER + TAB / SHIFT + TAB", "Workspace siguiente / anterior (también SUPER + rueda)."],
                ["SUPER + CTRL + 1…0", "Mostrar/ocultar un workspace especial (s1–s10) para apps que usas de vez en cuando."],
                ["SUPER + ALT + 1…0", "Mandar la ventana a ese workspace especial (vuelve con SUPER + SHIFT + número)."],
            ]
        },
        {
            icon: "󰝚", title: "Atajos · multimedia y sistema",
            intro: "",
            items: [
                ["Teclas de volumen / mute", "Suben, bajan o silencian y lo muestran en la isla."],
                ["Teclas de brillo", "Suben/bajan el brillo (laptop) y lo muestran en la isla."],
                ["SUPER + V, luego 1–5", "Volumen fijo: 0 %, 25 %, 50 %, 75 %, 100 %. Esc cancela."],
                ["SUPER + SHIFT + S", "Captura de una región: se guarda en ~/Imágenes/Capturas y se copia al portapapeles."],
                ["SUPER + CTRL + R", "Recargar la config de Hyprland."],
                ["SUPER + SHIFT + M", "Salir de Hyprland."],
            ]
        },
        {
            icon: "󰆍", title: "Terminal, btop y rofi",
            intro: "Todos toman los colores de esta pantalla.",
            items: [
                ["kitty", "Colores y los 16 colores de la terminal según la paleta. Las ventanas abiertas cambian al momento."],
                ["btop", "Clic derecho en CPU o RAM (o el botón del panel de Sistema): se abre flotante y centrado con tus colores. Otra vez lo cierra."],
                ["rofi", "Ventana con blur, bordes redondeados y tus colores."],
            ]
        },
        {
            icon: "󰘦", title: "Comandos (para scripts o atajos propios)",
            intro: "Desde una terminal, con quickshell corriendo:",
            items: [
                ["qs ipc call panel toggle <nombre>", "wifi · bluetooth · audio · brightness · clipboard · system · notifications · power."],
                ["qs ipc call island toggle", "Expandir/contraer la isla."],
                ["qs ipc call settings toggle | open <n> | close", "Ajustes (n = pestaña: 0 Colores, 1 Fondo, 2 Barra, 3 Ventanas, 4 Ayuda)."],
                ["qs ipc call settings preset <nombre>", "Aplicar una paleta (ej: Dracula)."],
                ["qs ipc call settings wallpaper <ruta>", "Poner un fondo. 'colorsFromWallpaper' genera la paleta."],
                ["qs ipc call wallpaper search <texto>", "Abrir el carrusel buscando en internet."],
                ["qs ipc call notifs dnd | clear | center", "No molestar / limpiar / abrir el centro."],
                ["qs ipc call osd volume | brightness", "Mostrar el nivel en la isla."],
            ]
        },
        {
            icon: "󰉋", title: "Dónde está cada cosa",
            intro: "Los archivos viven en el repo ~/bombayashi y se enlazan a ~/.config con link.sh.",
            items: [
                ["quickshell/", "Barra, isla, paneles, ajustes, carrusel, menú de apagado (archivos .qml)."],
                ["hypr/conf/", "Config de Hyprland en Lua: general.lua, windowrules.lua, keybinds/*.lua."],
                ["rofi/, kitty/, btop/", "Configs de cada programa."],
                ["~/.local/state/bombayashi/", "Lo que generan los ajustes: settings.json, colores de rofi y kitty. El tema de btop va en ~/.config/btop/themes/."],
                ["~/Imágenes/Wallpapers", "Tus fondos (y los que descargas de internet)."],
            ]
        },
        {
            icon: "󰁨", title: "Si algo falla",
            intro: "",
            items: [
                ["No aparece la barra", "En una terminal: qs kill; setsid -f qs -n"],
                ["Ver errores", "qs log"],
                ["Volver a waybar", "qs kill && waybar & swaync &"],
                ["No me salen notificaciones", "Revisa que No molestar esté apagado (campana sin tachar)."],
                ["kitty no cambió de color", "Las nuevas ventanas siempre toman la paleta; si una abierta no cambió, ciérrala y ábrela."],
                ["Quiero empezar de cero", "Borra ~/.local/state/bombayashi/settings.json y reinicia quickshell."],
                ["No hay brillo", "Es normal en PC de escritorio: los monitores externos no tienen control de brillo."],
            ]
        },
    ]

    readonly property string query: searchBox.text.trim().toLowerCase()
    function matches(sec, row) {
        if (!query) return true;
        return (row[0] + " " + row[1] + " " + sec.title).toLowerCase().includes(query);
    }

    // Buscador
    Rectangle {
        width: help.width
        height: 42
        radius: 21
        color: Theme.base
        border.color: searchBox.activeFocus ? Theme.accent : Theme.track
        Txt { x: 16; anchors.verticalCenter: parent.verticalCenter; text: "󰍉"; color: Theme.fgDim; font.pixelSize: 15 }
        TextInput {
            id: searchBox
            anchors.fill: parent
            anchors.leftMargin: 42
            anchors.rightMargin: 16
            verticalAlignment: TextInput.AlignVCenter
            color: Theme.fg
            selectionColor: Theme.accent
            font.family: Theme.font
            font.pixelSize: 13
            Txt {
                anchors.verticalCenter: parent.verticalCenter
                text: "Buscar en la ayuda… (ej: wifi, fondo, ventana, captura)"
                color: Theme.fgDim
                visible: searchBox.text.length === 0
            }
        }
    }

    Repeater {
        model: help.sections

        Rectangle {
            id: sec
            required property var modelData
            readonly property var rows: modelData.items.filter(r => help.matches(modelData, r))
            visible: rows.length > 0
            width: help.width
            height: visible ? secCol.implicitHeight + 28 : 0
            radius: 18
            color: Theme.bgAlt

            Column {
                id: secCol
                x: 16; y: 14
                width: parent.width - 32
                spacing: 8

                Row {
                    spacing: 10
                    Txt { text: sec.modelData.icon; color: Theme.accent; font.pixelSize: 17 }
                    Txt { text: sec.modelData.title; font.pixelSize: 15; font.bold: true }
                }
                Txt {
                    width: parent.width
                    visible: sec.modelData.intro.length > 0 && !help.query
                    text: sec.modelData.intro
                    color: Theme.fgDim
                    font.pixelSize: 12
                    wrapMode: Text.Wrap
                    elide: Text.ElideNone
                    bottomPadding: 2
                }
                Repeater {
                    model: sec.rows
                    Item {
                        required property var modelData
                        width: secCol.width
                        height: Math.max(keyBox.height, desc.implicitHeight)
                        TextMetrics { id: km; font.family: Theme.font; font.pixelSize: 11; font.bold: true; text: modelData[0] }
                        Rectangle {
                            id: keyBox
                            width: Math.min(km.width + 18, 230)
                            height: keyText.implicitHeight + 8
                            radius: 8
                            color: Theme.alpha(Theme.accent, 0.12)
                            Txt {
                                id: keyText
                                x: 8; y: 4
                                width: keyBox.width - 16
                                text: modelData[0]
                                color: Theme.accent
                                font.pixelSize: 11
                                font.bold: true
                                wrapMode: Text.Wrap
                                elide: Text.ElideNone
                            }
                        }
                        Txt {
                            id: desc
                            x: 244
                            y: 3
                            width: parent.width - 244
                            text: modelData[1]
                            font.pixelSize: 12
                            wrapMode: Text.Wrap
                            elide: Text.ElideNone
                        }
                    }
                }
            }
        }
    }

    Txt {
        visible: help.sections.every(s => !s.items.some(r => help.matches(s, r)))
        width: help.width
        topPadding: 30
        horizontalAlignment: Text.AlignHCenter
        text: "Nada coincide con la búsqueda"
        color: Theme.fgDim
    }
}
