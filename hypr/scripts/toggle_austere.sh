#!/bin/bash

# Este script cambia entre una configuración con bordes y espacios (actual) 
# y una "full austera" sin bordes ni espacios.

STATE_FILE="/tmp/hypr_austere_mode"

if [ -f "$STATE_FILE" ]; then
    # Restaurar configuración actual
    hyprctl keyword general:gaps_in 5
    hyprctl keyword general:gaps_out 10
    hyprctl keyword general:border_size 2
    hyprctl keyword decoration:rounding 10
    rm -f "$STATE_FILE"
    notify-send "Hyprland" "Modo Normal Activado" -t 2000

    waybar &


else
    # Activar configuración austera
    hyprctl keyword general:gaps_in 0
    hyprctl keyword general:gaps_out 0
    hyprctl keyword general:border_size 0
    hyprctl keyword decoration:rounding 0
    touch "$STATE_FILE"
    notify-send "Hyprland" "Modo Austero Activado" -t 2000

    killall waybar
fi
