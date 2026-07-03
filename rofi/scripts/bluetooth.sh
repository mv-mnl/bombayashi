#!/bin/bash
# Doble modo: standalone (keybind propio) o modo-script de rofi (pestaña del menu principal)

build_menu() {
    while IFS= read -r line; do
        MAC=$(echo "$line" | awk '{print $2}')
        NAME=$(echo "$line" | awk '{$1=$2=""; print substr($0,3)}')
        if bluetoothctl info "$MAC" | grep -q "Connected: yes"; then
            echo "  $NAME (conectado)"
        else
            echo "  $NAME"
        fi
    done < <(bluetoothctl devices)
}

list_entries() {
    POWER=$(bluetoothctl show | awk '/Powered:/{print $2}')
    if [ "$POWER" = "no" ]; then
        echo "  Power on"
    else
        printf "%s\n  Scan\n  Power off\n" "$(build_menu)"
    fi
}

do_action() {
    local CHOICE="$1"
    case "$CHOICE" in
        "  Power on")
            bluetoothctl power on
            ;;
        "  Scan")
            notify-send "Bluetooth" "Escaneando 10s..." -t 2000
            bluetoothctl --timeout 10 scan on
            ;;
        "  Power off")
            bluetoothctl power off
            ;;
        *)
            NAME=$(echo "$CHOICE" | sed 's/^[^ ]*  //; s/ (conectado)$//')
            MAC=$(bluetoothctl devices | awk -v n="$NAME" '$0 ~ n {print $2; exit}')
            [ -z "$MAC" ] && exit 1
            if bluetoothctl info "$MAC" | grep -q "Connected: yes"; then
                bluetoothctl disconnect "$MAC"
                notify-send "Bluetooth" "Desconectado de $NAME" -t 2000
            else
                bluetoothctl connect "$MAC"
                notify-send "Bluetooth" "Conectado a $NAME" -t 2000
            fi
            ;;
    esac
}

if [ -n "$ROFI_RETV" ]; then
    if [ -n "$1" ]; then
        do_action "$1"
    else
        list_entries
    fi
    exit 0
fi

POWER=$(bluetoothctl show | awk '/Powered:/{print $2}')

if [ "$POWER" = "no" ]; then
    CHOICE=$(printf "  Power on\n  Exit" \
        | rofi -dmenu -i -p "  Bluetooth (apagado)" \
        -theme-str 'window {width: 350px;} listview {lines: 2;}')
    [ "$CHOICE" = "  Power on" ] && bluetoothctl power on
    exit 0
fi

CHOICE=$(printf "%s\n  Scan\n  Power off" "$(build_menu)" \
    | rofi -dmenu -i -p "  Bluetooth" \
    -theme-str 'window {width: 420px;}')

[ -z "$CHOICE" ] && exit 0
do_action "$CHOICE"
