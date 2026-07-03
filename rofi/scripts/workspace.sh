#!/bin/bash
# Saltar a un workspace de Hyprland por nombre/número
# Doble modo: standalone (keybind propio) o modo-script de rofi (pestaña del menu principal)

list_workspaces() {
    hyprctl workspaces \
        | grep "^workspace ID" \
        | sed 's/workspace ID \(-\?[0-9]*\) (\([^)]*\)) on monitor \(.*\):/\1 \2 [\3]/' \
        | awk '{printf "  %-4s %s %s\n", $1, $2, $3}'
}

do_action() {
    WS=$(echo "$1" | awk '{print $2}')
    hyprctl dispatch workspace "$WS"
}

if [ -n "$ROFI_RETV" ]; then
    if [ -n "$1" ]; then
        do_action "$1"
    else
        list_workspaces
    fi
    exit 0
fi

CHOICE=$(list_workspaces \
    | rofi -dmenu -i -p "  Workspace" \
    -theme-str 'window {width: 380px;} listview {lines: 10;}')

[ -z "$CHOICE" ] && exit 0
do_action "$CHOICE"
