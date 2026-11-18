#!/bin/bash

# Este script cambia entre una configuración con bordes y espacios (actual) 
# y una "full austera" sin bordes ni espacios.

STATE_FILE="${XDG_RUNTIME_DIR:-/tmp}/hypr_austere_mode"

if [ -f "$STATE_FILE" ]; then
    # Restaurar configuración actual
    hyprctl eval 'hl.config({ general = { gaps_in = 5, gaps_out = 10, border_size = 2 }, decoration = { rounding = 10 } })'
    rm -f "$STATE_FILE"
    notify-send "Hyprland" "Modo Normal Activado" -t 2000

    qs -d >/dev/null 2>&1


else
    # Activar configuración austera
    hyprctl eval 'hl.config({ general = { gaps_in = 0, gaps_out = 0, border_size = 0 }, decoration = { rounding = 0 } })'
    touch "$STATE_FILE"
    notify-send "Hyprland" "Modo Austero Activado" -t 2000

    qs kill
fi
