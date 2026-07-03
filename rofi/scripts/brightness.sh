#!/bin/bash
# Doble modo: standalone (keybind propio) o modo-script de rofi (pestaña del menu principal)

LEVELS="10%\n20%\n30%\n40%\n50%\n60%\n70%\n80%\n90%\n100%"

if [ -n "$ROFI_RETV" ]; then
    if [ -n "$1" ]; then
        brightnessctl s "$1"
    else
        printf "%b\n" "$LEVELS"
    fi
    exit 0
fi

CURRENT=$(brightnessctl g)
MAX=$(brightnessctl m)
PCT=$(( CURRENT * 100 / MAX ))

CHOICE=$(printf "%b" "$LEVELS" \
    | rofi -dmenu -i -p "  Brillo ($PCT%)" \
    -theme-str 'window {width: 220px;} listview {lines: 10;}')

[ -z "$CHOICE" ] && exit 0
brightnessctl s "$CHOICE"
