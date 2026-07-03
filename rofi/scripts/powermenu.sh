#!/bin/bash
# Doble modo: standalone (keybind propio) o modo-script de rofi (pestaña del menu principal)

OPTIONS="  Lock\n  Suspend\n  Logout\n  Reboot\n  Shutdown"

do_action() {
    case "$1" in
        "  Lock")      loginctl lock-session ;;
        "  Suspend")   systemctl suspend ;;
        "  Logout")    hyprctl dispatch exit ;;
        "  Reboot")    systemctl reboot ;;
        "  Shutdown")  systemctl poweroff ;;
    esac
}

if [ -n "$ROFI_RETV" ]; then
    if [ -n "$1" ]; then
        do_action "$1"
    else
        printf "%b\n" "$OPTIONS"
    fi
    exit 0
fi

CHOICE=$(printf "%b" "$OPTIONS" \
    | rofi -dmenu -i -p "  Power" \
    -theme-str 'window {width: 280px;} listview {lines: 5;}')

[ -z "$CHOICE" ] && exit 0
do_action "$CHOICE"
