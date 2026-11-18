import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Widgets
import QtQuick

// ==============================================================================
// PANTALLA DE AJUSTES  (SUPER + S, o el engranaje de la isla expandida)
// Pestañas: Colores · Fondo · Barra · Ventanas. Esc o clic afuera para cerrar.
// ==============================================================================
PanelWindow {
    id: win

    property real t: Settings.open ? 1 : 0
    Behavior on t { NumberAnimation { duration: 340; easing.type: Easing.OutCubic } }

    visible: Settings.open || t > 0.001
    screen: Quickshell.screens.find(s => s.name === Hyprland.focusedMonitor?.name) ?? Quickshell.screens[0]

    anchors { top: true; bottom: true; left: true; right: true }
    exclusionMode: ExclusionMode.Ignore
    color: Qt.rgba(0, 0, 0, 0.45 * t)

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "quickshell-settings"
    WlrLayershell.keyboardFocus: Settings.open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    onVisibleChanged: if (visible) { card.forceActiveFocus(); Settings.refreshWallpapers(); }

    // Clic fuera de la tarjeta = cerrar
    MouseArea {
        anchors.fill: parent
        onClicked: Settings.open = false
    }

    // ---------------------------------------------------------------- componentes
    component Label: Text {
        color: Theme.fg
        font.family: Theme.font
        font.pixelSize: Theme.fontSize
        elide: Text.ElideRight
        verticalAlignment: Text.AlignVCenter
    }

    component Section: Label {
        width: parent?.width ?? 0
        topPadding: 6
        text: ""
        color: Theme.fgDim
        font.pixelSize: 11
        font.bold: true
        font.letterSpacing: 1.5
    }




    // Página con scroll + animación de entrada al cambiar de pestaña
    component Page: Flickable {
        id: page
        property int index
        default property alias body: col.data
        readonly property bool current: Settings.tab === index
        anchors.fill: parent
        contentHeight: col.implicitHeight + 8
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        visible: opacity > 0.01
        opacity: current ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 220 } }
        transform: Translate {
            y: page.current ? 0 : 24
            Behavior on y { NumberAnimation { duration: 320; easing.type: Easing.OutCubic } }
        }
        Column {
            id: col
            width: page.width
            spacing: 12
        }
    }

    // ------------------------------------------------------------------- tarjeta
    Rectangle {
        id: card
        width: Math.min(980, win.width - 80)
        height: Math.min(640, win.height - 120)
        anchors.centerIn: parent
        anchors.verticalCenterOffset: (1 - win.t) * 40
        scale: 0.94 + 0.06 * win.t
        opacity: win.t
        radius: 28
        color: Theme.bgSolid
        border.color: Theme.border
        border.width: 1
        focus: true
        Keys.onEscapePressed: Settings.open = false
        Behavior on color { ColorAnimation { duration: 300 } }

        // Tragar clics para que no cierren la pantalla
        MouseArea { anchors.fill: parent }

        // ------------------------------------------------------------ barra lateral
        Item {
            id: sidebar
            width: 230
            height: parent.height

            Column {
                x: 24; y: 26
                spacing: 2
                Row {
                    spacing: 10
                    Label { text: "󰒓"; font.pixelSize: 24; color: Theme.accent }
                    Label { text: "Ajustes"; font.pixelSize: 22; font.bold: true }
                }
                Label { text: "bombayashi · larpeo"; color: Theme.fgDim; font.pixelSize: 11; leftPadding: 2 }
            }

            readonly property var tabs: [
                { icon: "󰏘", name: "Colores" },
                { icon: "󰸉", name: "Fondo" },
                { icon: "󰕮", name: "Barra e isla" },
                { icon: "󰖲", name: "Ventanas" },
                { icon: "󰋗", name: "Ayuda" },
            ]

            // Indicador que se desliza entre pestañas
            Rectangle {
                x: 14
                y: 104 + Settings.tab * 50
                width: sidebar.width - 28
                height: 44
                radius: 14
                color: Theme.alpha(Theme.accent, 0.14)
                Behavior on y { SpringAnimation { spring: 4; damping: 0.35; epsilon: 0.3 } }
                Rectangle {
                    width: 4; height: 20; radius: 2
                    anchors.left: parent.left
                    anchors.leftMargin: 6
                    anchors.verticalCenter: parent.verticalCenter
                    color: Theme.accent
                }
            }

            Repeater {
                model: sidebar.tabs
                Item {
                    required property var modelData
                    required property int index
                    x: 14
                    y: 104 + index * 50
                    width: sidebar.width - 28
                    height: 44
                    Row {
                        anchors.verticalCenter: parent.verticalCenter
                        x: 22
                        spacing: 12
                        Label {
                            text: modelData.icon
                            font.pixelSize: 17
                            color: Settings.tab === index ? Theme.accent : Theme.fgDim
                            Behavior on color { ColorAnimation { duration: 200 } }
                        }
                        Label {
                            text: modelData.name
                            font.pixelSize: 13
                            font.bold: Settings.tab === index
                            color: Settings.tab === index ? Theme.fg : Theme.fgDim
                        }
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Settings.tab = index
                    }
                }
            }

            Label {
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 22
                x: 26
                text: "Esc para cerrar"
                color: Theme.fgDim
                font.pixelSize: 11
            }
        }

        Rectangle {
            x: sidebar.width
            y: 20
            width: 1
            height: parent.height - 40
            color: Theme.track
        }

        // --------------------------------------------------------------- contenido
        Item {
            id: content
            anchors.fill: parent
            anchors.leftMargin: sidebar.width + 32
            anchors.rightMargin: 32
            anchors.topMargin: 28
            anchors.bottomMargin: 24

            // ===== COLORES =====
            Page {
                index: 0

                Section { text: "PALETAS" }
                Grid {
                    width: parent.width
                    columns: 4
                    spacing: 12
                    Repeater {
                        model: Settings.presets
                        Rectangle {
                            id: preset
                            required property var modelData
                            readonly property bool selected: Settings.opts.palette === modelData.name
                            width: (content.width - 36) / 4
                            height: 86
                            radius: 18
                            color: modelData.bg
                            border.width: selected ? 2 : 1
                            border.color: selected ? modelData.accent : Theme.track
                            scale: pa.containsMouse ? 1.04 : 1
                            Behavior on scale { NumberAnimation { duration: 180; easing.type: Easing.OutBack } }
                            Label {
                                x: 14; y: 12
                                text: preset.modelData.name
                                color: preset.modelData.fg
                                font.bold: true
                            }
                            Row {
                                x: 14
                                anchors.bottom: parent.bottom
                                anchors.bottomMargin: 14
                                spacing: 6
                                Repeater {
                                    model: [preset.modelData.fgDim, preset.modelData.fg, preset.modelData.accent]
                                    Rectangle {
                                        required property var modelData
                                        width: 16; height: 16; radius: 8
                                        color: modelData
                                    }
                                }
                            }
                            Label {
                                anchors.right: parent.right
                                anchors.rightMargin: 14
                                anchors.bottom: parent.bottom
                                anchors.bottomMargin: 12
                                text: "󰄬"
                                color: preset.modelData.accent
                                font.pixelSize: 16
                                opacity: preset.selected ? 1 : 0
                                Behavior on opacity { NumberAnimation { duration: 150 } }
                            }
                            MouseArea {
                                id: pa
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: Settings.applyPreset(preset.modelData)
                            }
                        }
                    }
                }

                Section { text: "COLOR DE ACENTO" }
                Row {
                    spacing: 10
                    Repeater {
                        model: Settings.accents
                        Rectangle {
                            id: sw
                            required property var modelData
                            readonly property bool selected: Settings.opts.accent.toLowerCase() === modelData
                            width: 30; height: 30; radius: 15
                            color: "transparent"
                            border.width: 2
                            border.color: selected ? modelData : "transparent"
                            Rectangle {
                                anchors.centerIn: parent
                                width: sw.selected ? 20 : swa.containsMouse ? 26 : 24
                                height: width; radius: width / 2
                                color: sw.modelData
                                Behavior on width { NumberAnimation { duration: 180; easing.type: Easing.OutBack } }
                            }
                            MouseArea {
                                id: swa
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: { Settings.opts.accent = sw.modelData; Settings.opts.palette = "Personalizada"; }
                            }
                        }
                    }
                    // Hex manual
                    Rectangle {
                        width: 110; height: 30; radius: 15
                        color: Theme.bgAlt
                        border.color: hexInput.activeFocus ? Theme.accent : Theme.track
                        Rectangle {
                            x: 6; anchors.verticalCenter: parent.verticalCenter
                            width: 18; height: 18; radius: 9
                            color: Settings.opts.accent
                        }
                        TextInput {
                            id: hexInput
                            x: 30
                            width: parent.width - 38
                            anchors.verticalCenter: parent.verticalCenter
                            text: Settings.opts.accent
                            color: Theme.fg
                            selectionColor: Theme.accent
                            font.family: Theme.font
                            font.pixelSize: 12
                            maximumLength: 7
                            validator: RegularExpressionValidator { regularExpression: /#?[0-9a-fA-F]{0,6}/ }
                            onAccepted: {
                                let v = text.startsWith("#") ? text : "#" + text;
                                if (/^#[0-9a-fA-F]{6}$/.test(v)) {
                                    Settings.opts.accent = v.toLowerCase();
                                    Settings.opts.palette = "Personalizada";
                                }
                                card.forceActiveFocus();
                            }
                        }
                    }
                }

                Section { text: "DESDE EL FONDO DE PANTALLA" }
                Row {
                    spacing: 10
                    Button {
                        primary: true
                        text: Settings.generating ? "Generando…" : "󰸉  Generar paleta del fondo"
                        onClicked: Settings.colorsFromWallpaper()
                    }
                    Repeater {
                        model: [
                            { id: "scheme-tonal-spot", name: "Suave" },
                            { id: "scheme-vibrant", name: "Vibrante" },
                            { id: "scheme-expressive", name: "Expresivo" },
                            { id: "scheme-monochrome", name: "Mono" },
                        ]
                        Button {
                            required property var modelData
                            text: modelData.name
                            color: Settings.opts.matugenScheme === modelData.id ? Theme.track : Theme.bgAlt
                            onClicked: { Settings.opts.matugenScheme = modelData.id; Settings.colorsFromWallpaper(); }
                        }
                    }
                }
                Toggle {
                    label: "Cambiar colores automáticamente"
                    hint: "Cada vez que elijas un fondo nuevo, la paleta se genera sola"
                    checked: Settings.opts.autoColors
                    onToggled: Settings.opts.autoColors = !Settings.opts.autoColors
                }
                Slider {
                    label: "Opacidad de la barra y la isla"
                    from: 0.4; to: 1; decimals: 2
                    value: Settings.opts.barOpacity
                    onMoved: v => Settings.opts.barOpacity = v
                }
            }

            // ===== FONDO =====
            Page {
                index: 1

                Item {
                    width: parent.width
                    height: 190
                    ClippingRectangle {
                        id: preview
                        width: 320; height: 180; radius: 18
                        color: Theme.bgAlt
                        Image {
                            anchors.fill: parent
                            source: Settings.currentWallpaper
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                            sourceSize.width: 640
                        }
                    }
                    Column {
                        anchors.left: preview.right
                        anchors.leftMargin: 20
                        anchors.right: parent.right
                        anchors.verticalCenter: preview.verticalCenter
                        spacing: 10
                        Label { text: "Fondo actual"; color: Theme.fgDim; font.pixelSize: 11 }
                        Label {
                            width: parent.width
                            text: Settings.currentWallpaper.split("/").pop() || "—"
                            font.pixelSize: 15
                            font.bold: true
                        }
                        Label {
                            width: parent.width
                            text: "Agrega tus imágenes en ~/Imágenes/Wallpapers"
                            color: Theme.fgDim
                            font.pixelSize: 11
                        }
                        Flow {
                            width: parent.width
                            spacing: 8
                            Button {
                                text: "󰉋  Abrir carpeta"
                                onClicked: {
                                    Settings.open = false;
                                    Quickshell.execDetached(["sh", "-c", `mkdir -p "${Settings.wallpaperDir}" && xdg-open "${Settings.wallpaperDir}"`]);
                                }
                            }
                            Button { text: "󰑐  Recargar"; onClicked: Settings.refreshWallpapers() }
                            Button { primary: true; text: "󰸉  Carrusel (SUPER+W)"; onClicked: { Settings.open = false; Settings.picker = true; } }
                            Button {
                                text: "󰒝  Aleatorio"
                                onClicked: if (Settings.wallpapers.length) Settings.setWallpaper(Settings.wallpapers[Math.floor(Math.random() * Settings.wallpapers.length)])
                            }
                        }
                    }
                }

                Section { text: `TODOS LOS FONDOS (${Settings.wallpapers.length})` }
                Grid {
                    width: parent.width
                    columns: 4
                    spacing: 12
                    Repeater {
                        model: Settings.wallpapers
                        ClippingRectangle {
                            id: thumb
                            required property string modelData
                            required property int index
                            readonly property bool selected: Settings.currentWallpaper === modelData
                            width: (content.width - 36) / 4
                            height: width * 9 / 16
                            radius: 14
                            color: Theme.bgAlt
                            scale: ta.containsMouse ? 1.05 : 1
                            z: ta.containsMouse ? 2 : 0
                            Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutBack } }
                            Image {
                                anchors.fill: parent
                                source: thumb.modelData
                                fillMode: Image.PreserveAspectCrop
                                asynchronous: true
                                sourceSize.width: 360
                                opacity: status === Image.Ready ? 1 : 0
                                Behavior on opacity { NumberAnimation { duration: 300 } }
                            }
                            Rectangle {
                                anchors.fill: parent
                                radius: thumb.radius
                                color: "transparent"
                                border.width: thumb.selected ? 3 : 0
                                border.color: Theme.accent
                            }
                            Rectangle {
                                visible: thumb.selected
                                anchors.right: parent.right
                                anchors.top: parent.top
                                anchors.margins: 8
                                width: 22; height: 22; radius: 11
                                color: Theme.accent
                                Label { anchors.centerIn: parent; text: "󰄬"; color: Theme.base; font.pixelSize: 13 }
                            }
                            MouseArea {
                                id: ta
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: Settings.setWallpaper(thumb.modelData)
                            }
                        }
                    }
                }
            }

            // ===== BARRA E ISLA =====
            Page {
                index: 2

                Section { text: "BARRA" }
                Toggle {
                    label: "Velocidad de red"
                    hint: "Subida / bajada junto a los workspaces"
                    checked: Settings.opts.showNet
                    onToggled: Settings.opts.showNet = !Settings.opts.showNet
                }
                Toggle {
                    label: "Uso del sistema"
                    hint: "CPU, temperatura, GPU y RAM"
                    checked: Settings.opts.showStats
                    onToggled: Settings.opts.showStats = !Settings.opts.showStats
                }
                Slider {
                    label: "Tamaño de la barra y la isla"
                    from: 1; to: 1.8; decimals: 2; suffix: "×"
                    value: Settings.opts.barScale
                    onMoved: v => Settings.opts.barScale = v
                }
                Section { text: "ESTILO DEL ESCRITORIO" }
                Row {
                    spacing: 10
                    Button {
                        primary: true
                        text: "󰏘  Cambiar de estilo (SUPER+SHIFT+E)"
                        onClicked: { Settings.open = false; Quickshell.execDetached(["sh", "-c", "~/.local/bin/estilo"]); }
                    }
                    Txt {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "larpeo = isla · main = clásico (waybar)"
                        color: Theme.fgDim
                        font.pixelSize: 11
                    }
                }
                Section { text: "ISLA DINÁMICA" }
                Toggle {
                    label: "Brillo que respira"
                    hint: "El borde de la isla pulsa mientras suena música"
                    checked: Settings.opts.islandGlow
                    onToggled: Settings.opts.islandGlow = !Settings.opts.islandGlow
                }
                Toggle {
                    label: "Visualizador de audio"
                    hint: "Barras de cava dentro de la isla"
                    checked: Settings.opts.visualizer
                    onToggled: Settings.opts.visualizer = !Settings.opts.visualizer
                }
                Slider {
                    label: "Opacidad"
                    from: 0.4; to: 1; decimals: 2
                    value: Settings.opts.barOpacity
                    onMoved: v => Settings.opts.barOpacity = v
                }
                Row {
                    spacing: 10
                    Button { text: "Probar notificación"; onClicked: Quickshell.execDetached(["notify-send", "-a", "bombayashi", "Hola 👋", "Así se ven las notificaciones en la isla"]) }
                    Button { text: "Probar OSD"; onClicked: Osd.show("volume") }
                }
            }

            // ===== VENTANAS =====
            Page {
                index: 3

                Section { text: "ESPACIADO Y BORDES" }
                Slider {
                    label: "Espacio entre ventanas"
                    from: 0; to: 30; suffix: " px"
                    value: Settings.opts.gapsIn
                    onMoved: v => Settings.opts.gapsIn = v
                }
                Slider {
                    label: "Margen con la pantalla"
                    from: 0; to: 40; suffix: " px"
                    value: Settings.opts.gapsOut
                    onMoved: v => Settings.opts.gapsOut = v
                }
                Slider {
                    label: "Grosor del borde"
                    from: 0; to: 6; suffix: " px"
                    value: Settings.opts.border
                    onMoved: v => Settings.opts.border = v
                }
                Slider {
                    label: "Esquinas redondeadas"
                    from: 0; to: 28; suffix: " px"
                    value: Settings.opts.rounding
                    onMoved: v => Settings.opts.rounding = v
                }
                Section { text: "EFECTOS" }
                Toggle {
                    label: "Blur"
                    hint: "Desenfoque detrás de ventanas transparentes, barra y menús"
                    checked: Settings.opts.blur
                    onToggled: Settings.opts.blur = !Settings.opts.blur
                }
                Slider {
                    visible: Settings.opts.blur
                    label: "Intensidad del blur"
                    from: 1; to: 16
                    value: Settings.opts.blurSize
                    onMoved: v => Settings.opts.blurSize = v
                }
                Toggle {
                    label: "Sombras"
                    checked: Settings.opts.shadow
                    onToggled: Settings.opts.shadow = !Settings.opts.shadow
                }
                Toggle {
                    label: "Animaciones de ventanas"
                    checked: Settings.opts.animations
                    onToggled: Settings.opts.animations = !Settings.opts.animations
                }
                Button { text: "󰑓  Restablecer"; onClicked: Settings.resetWindows() }
            }

            // ===== AYUDA =====
            Page {
                index: 4
                HelpPage {}
            }
        }
    }
}
