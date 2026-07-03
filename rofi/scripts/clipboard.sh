#!/bin/bash
# Requires: cliphist, wl-copy
# cliphist debe estar corriendo: wl-paste --watch cliphist store
# Doble modo: standalone (keybind propio) o modo-script de rofi (pestaña del menu principal)

if [ -n "$ROFI_RETV" ]; then
    if [ -n "$1" ]; then
        printf '%s' "$1" | cliphist decode | wl-copy
    else
        cliphist list
    fi
    exit 0
fi

cliphist list \
    | rofi -dmenu -i -p "  Clipboard" \
    -theme-str 'window {width: 600px;} listview {lines: 12;}' \
    | cliphist decode \
    | wl-copy
