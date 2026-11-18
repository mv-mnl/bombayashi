# Contexto: modo "presumir" para bombayashi

> Documento de contexto para rediseñar el escritorio (Hyprland + barra + launcher + lock)
> con el objetivo de que sea **visual, animado y vistoso**, no necesariamente práctico.
> Pensado para pasárselo a Claude (u otra IA) como punto de partida.

---

## 1. Objetivo

- Crear una **vista/rice para presumir**: isla dinámica, animaciones fluidas, blur, transiciones, widgets.
- La funcionalidad pasa a segundo plano: prioridad = **que se vea bien en screenshots y video** (r/unixporn style).
- Se vale copiar/adaptar proyectos de GitHub en vez de hacerlo desde cero (respetando licencias).
- **No romper el setup actual**: todo en la rama `larpeo`, y idealmente intercambiable con el modo normal
  (igual que ya existe `toggle_austere.sh`, se puede hacer un `toggle_showoff.sh`).

---

## 2. Estado actual del repo (lo que hay hoy)

| Componente | Herramienta | Archivos | Notas |
|---|---|---|---|
| Compositor | **Hyprland 0.57.2** (config en **Lua**) | `hypr/hyprland.lua`, `hypr/conf/*.lua` | Desde 0.57 solo lee `.lua`. `hyprland.conf` es legado. |
| Apariencia | — | `hypr/conf/general.lua` | Escala de grises, `border_size=2`, gradiente blanco→gris. **No hay bloque `decoration` ni `animations`** → todo está con valores por defecto. |
| Barra | Waybar 0.16 | `waybar/config.jsonc`, `waybar/style.css`, `waybar/scripts/` | Workspaces, red, reloj, batería, disco, audio, brillo, cpu, gpu, ram. |
| Launcher/menús | Rofi 2.1 | `rofi/config.rasi`, `rofi/scripts/*.sh` | Menús de red, bt, clipboard, bitwarden, power, ssh, volumen, brillo, workspaces. |
| Notificaciones | swaync | (sin config en repo) | |
| Wallpaper | hyprpaper | `hypr/scripts/wallpaper.sh`, `wallpaper/black.png` | Fondo negro estático. |
| Lock / idle | hyprlock / hypridle | `hypr/hyprlock.conf`, `hypr/hypridle.conf` | Minimalista: hora centrada. |
| Login | SDDM | `sddm/Main.qml` | Tema QML propio. |
| Terminal | kitty (tema dracula) | `kitty/*.conf` | |
| Shell | zsh + starship | `zsh/` | |
| Instalación | — | `install.sh`, `link.sh` | `link.sh` enlaza `hypr kitty rofi waybar zsh` a `~/.config`. |

**Estética actual:** monocromo (negro/blanco/grises), minimalista, gaps pegados a la barra.

### Ya instalado en el sistema (útil para el rediseño)
- `quickshell-git 0.3.0` ← **clave para la isla dinámica** (QML, animaciones nativas)
- `eww 0.6.0` (alternativa más simple)
- `matugen 4.1.0` (genera paleta de colores a partir del wallpaper, estilo Material You)
- `cava 1.0.0` (visualizador de audio)

### No instalado (posibles agregados)
- `swww` o `awww` — wallpapers con transiciones animadas (hyprpaper no anima)
- `hyprland-plugins` / `hyprpm` — plugins (p.ej. `hyprtrails`, `hyprexpo`, `borders-plus-plus`)
- `fastfetch` — para el screenshot clásico

---

## 3. Visión del rediseño

### 3.1 Isla dinámica (pieza central)
Una "píldora" arriba al centro (reemplaza o convive con Waybar) que:
- **Colapsada**: hora + workspace activo (o un punto/indicador).
- **Se expande con animación** al:
  - reproducir música → carátula, título, artista, barra de progreso, visualizador (cava) — vía MPRIS
  - cambiar volumen / brillo → OSD con slider dentro de la isla
  - llegar una notificación → la isla crece y muestra la notificación
  - hover/clic → panel con controles rápidos (wifi, bt, power, calendario)
- Morph del launcher: que el launcher "salga" de la isla.

**Tecnología recomendada:** Quickshell (ya instalado). Tiene `PanelWindow`, servicios `Mpris`, `Pipewire`,
`Hyprland`, `Notifications` y animaciones QML (`Behavior`, `SpringAnimation`, `NumberAnimation`).

### 3.2 Hyprland: animaciones y decoración
Agregar un módulo nuevo `hypr/conf/decoration.lua` (y su `require` en `hyprland.lua`) con:
- `decoration`: `rounding` 12–16, **blur** activado (size/passes altos, `vibrancy`), sombras suaves, `dim_inactive` leve.
- `animations`: curvas bezier personalizadas tipo "overshoot"/spring para ventanas
  (`popin`/`slide`), workspaces (`slidefade` o `slidevert`), fade, border con gradiente **animado**
  (`borderangle` en loop).
- Ejemplos de curvas que usa la comunidad:
  - `easeOutQuint` → `0.23, 1, 0.32, 1`
  - `md3_standard` → `0.2, 0, 0, 1`
  - `md3_decel` → `0.05, 0.7, 0.1, 1`
  - overshoot → `0.05, 0.9, 0.1, 1.1`
- ⚠️ La sintaxis en Lua (0.57) **no es** la misma que `bezier = ...` del `.conf`. Verificar en la wiki:
  https://wiki.hypr.land/configuring/core/animations/ y validar con
  `Hyprland --verify-config -c ~/.config/hypr/hyprland.lua`.
- `layer_rule`s para blur sobre la isla/barra, rofi y swaync.

### 3.3 Colores dinámicos
- Pasar de monocromo fijo a **paleta generada por matugen** desde el wallpaper.
- Plantillas matugen → Hyprland (bordes), Quickshell, kitty, rofi, swaync, hyprlock.
- Opcional: mantener una variante monocromática "premium" (negro + un solo acento animado).

### 3.4 Wallpaper animado
- Cambiar hyprpaper → `swww`/`awww` con transiciones (`grow`, `wave`, `outer`).
- Carpeta con varios wallpapers + script/atajo para rotar (y regenerar colores con matugen).

### 3.5 Extras "para presumir"
- Visualizador cava dentro de la isla o como widget de escritorio.
- Lockscreen hyprlock con blur del escritorio (`screenshot` como fondo), carátula de música, saludo.
- Dock inferior que aparece al hover (Quickshell).
- Overview de workspaces (plugin `hyprexpo` o el de Quickshell de end-4).
- `fastfetch` con logo/imagen personalizada para el screenshot.
- Launcher con animación de entrada (Quickshell o rofi con tema nuevo).

---

## 4. Proyectos de referencia en GitHub

> No verifiqué estado ni licencia de cada uno: **revisar README y LICENSE antes de copiar**.

### Islas dinámicas (Quickshell)
- **ActivSpot**: https://github.com/Devvvmn/ActivSpot (reloj/clima, píldora de música, launcher que se transforma desde la isla)
- **Tide-island**: https://github.com/enhaoswen/Tide-island (Hyprland + niri; hay paquete AUR `tide-island`)
- **DynamicGlacier**: https://github.com/mavxa/DynamicGlacier (experimental, QML + Quickshell)
- **k4**: https://github.com/k4ditano/k4 (se queda colapsada en el borde y se expande solo cuando tiene algo que mostrar; trae `./instalar --dry-run`)
- **jimallen/quickshell**: https://github.com/jimallen/quickshell (barra con popups estilo notch)

### Shells completos (para robar ideas/componentes)
- **end-4 / dots-hyprland** (illogical-impulse, todo en Quickshell): https://github.com/end-4/dots-hyprland
- **caelestia shell**: https://github.com/caelestia-dots/shell
- **DankMaterialShell**: https://github.com/AvengeMedia/DankMaterialShell
- **Noctalia shell** (sobre Quickshell)
- **mszost/quickshell-config**: https://github.com/mszost/quickshell-config

### Docs
- Quickshell: https://quickshell.org (repo: https://github.com/quickshell-mirror/quickshell)
- Hyprland wiki (animaciones): https://wiki.hypr.land/configuring/core/animations/
- matugen: https://github.com/InioX/matugen

---

## 5. Plan de trabajo sugerido

1. **Base visual en Hyprland** — `conf/decoration.lua` con blur, sombras, rounding y animaciones bezier.
   (Rápido y es lo que más cambia la sensación.)
2. **Wallpaper + colores** — instalar swww, varios fondos, integrar matugen.
3. ✅ **Isla dinámica** (hecho: `quickshell/`, reemplaza waybar + swaync) — probar 1–2 repos de referencia tal cual; elegir uno y adaptarlo
   (o escribir una propia en `quickshell/` tomando piezas). Agregar `quickshell` a `link.sh`.
4. ✅ **Reemplazar/ocultar Waybar** (hecho) — mover módulos útiles (cpu, gpu, red) a la isla o a un panel lateral.
5. ✅ **Notificaciones y OSD** (hecho) — que volumen/brillo/notificaciones salgan en la isla
   (ajustar `hypr/scripts/audio.sh` y binds de `conf/keybinds/media.lua`).
6. **Lockscreen y login** — rediseño de `hyprlock.conf` y `sddm/Main.qml` a juego.
7. ✅ **Rediseñar colores y estilo de TODAS las vistas** (hecho: paneles de la isla para wifi, bluetooth, sonido, brillo y portapapeles; menú de apagado a pantalla completa; rofi re-tematizado con los colores de los ajustes. Falta: kitty, hyprlock y SDDM) — que todo combine con la barra/isla nueva
   (no solo el monocromo actual). Incluye todos los menús de rofi (`rofi/config.rasi`, `rofi/sidebar.rasi`,
   `rofi/scripts/*.sh`): power menu (`SUPER + X` → `powermenu.sh`), red, bluetooth, clipboard, bitwarden,
   volumen, brillo, ssh, workspaces y el launcher (`SUPER + R`). Idea: que se vean como paneles de la isla
   (blur, bordes redondeados, animación de entrada) o reemplazar los más vistosos (p.ej. el power menu)
   por paneles hechos en quickshell.
8. **Toggle** — `hypr/scripts/toggle_showoff.sh` que alterne entre el modo normal (waybar) y el de presumir
   (quickshell + animaciones intensas), similar a `toggle_austere.sh`.
9. Actualizar `install.sh` (paquetes nuevos) y `README.md`.

---

## 6. Restricciones / notas técnicas

- Hyprland **0.57.2** → config **solo en Lua** (`hl.config`, `hl.bind`, `hl.window_rule`, `hl.on`, `hl.exec_cmd`).
  Muchos dotfiles de GitHub siguen en `.conf` (hyprlang): **hay que traducirlos** a Lua.
- `hyprctl eval 'hl.config({...})'` sirve para cambiar valores en caliente (ya se usa en `toggle_austere.sh`).
- `conf/monitors.lua` lo genera `detect_monitor_scale.sh` y está en `.gitignore`: no tocarlo.
- Configs viven en el repo y se enlazan a `~/.config` con `link.sh`; cualquier carpeta nueva
  (`quickshell/`, `swaync/`, `matugen/`) hay que agregarla ahí.
- Distro: CachyOS (Arch). Paquetes vía `pacman`/`yay`.
- Fuente: JetBrainsMono Nerd Font.
- Autostart actual (`conf/autostart.lua`): `waybar`, `hyprpaper`, `swaync`, cliphist, `nm-applet`, `hypridle`,
  polkit, easyeffects. En modo presumir hay que cambiar waybar → `qs` (quickshell) y hyprpaper → swww.
- Estilo de commits del repo: `feat:`, `fix:`, `style:`, `chore:` en español.
