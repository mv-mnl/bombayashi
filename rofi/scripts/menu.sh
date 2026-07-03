#!/bin/bash
# Menu principal: submenu de categorias a la izquierda (sidebar), opciones a la derecha (listview)

SCRIPTS_DIR="$(cd "$(dirname "$0")" && pwd)"
ROFI_DIR="$(cd "$SCRIPTS_DIR/.." && pwd)"
THEME="$ROFI_DIR/sidebar.rasi"

rofi -show drun \
    -modi "drun,Network:$SCRIPTS_DIR/network.sh,Bluetooth:$SCRIPTS_DIR/bluetooth.sh,Clipboard:$SCRIPTS_DIR/clipboard.sh,Power:$SCRIPTS_DIR/powermenu.sh,SSH:$SCRIPTS_DIR/ssh.sh,Workspace:$SCRIPTS_DIR/workspace.sh,Volumen:$SCRIPTS_DIR/volume.sh,Brillo:$SCRIPTS_DIR/brightness.sh" \
    -display-drun "Aplicaciones" \
    -theme-str "@import \"$THEME\""
