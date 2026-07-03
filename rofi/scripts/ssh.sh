#!/bin/bash
# Doble modo: standalone (keybind propio) o modo-script de rofi (pestaña del menu principal)

HOSTS=$(awk '/^Host [^*]/{print $2}' ~/.ssh/config 2>/dev/null)

if [ -n "$ROFI_RETV" ]; then
    if [ -n "$1" ]; then
        kitty -e ssh "$1"
    else
        [ -n "$HOSTS" ] && printf "%s\n" "$HOSTS"
    fi
    exit 0
fi

if [ -z "$HOSTS" ]; then
    notify-send "SSH" "No hay hosts en ~/.ssh/config" -t 3000
    exit 0
fi

HOST=$(echo "$HOSTS" | rofi -dmenu -i -p "  SSH" \
    -theme-str 'window {width: 380px;}')

[ -z "$HOST" ] && exit 0
kitty -e ssh "$HOST"
