#!/bin/bash
# Doble modo: standalone (keybind propio) o modo-script de rofi (pestaña del menu principal)

RESCAN="  Scan"
DISCONNECT="  Disconnect"

list_networks() {
    nmcli -t -f ssid,signal,security dev wifi list 2>/dev/null \
        | awk -F: '
            $1 == "" { next }
            !seen[$1]++ {
                icon = ($2+0 > 70 ? "󰤨" : $2+0 > 40 ? "󰤥" : "󰤢")
                lock = ($3 != "--" ? "  " : "")
                printf "%s  %s%s\n", icon, $1, lock
            }
        '
}

do_action() {
    local CHOICE="$1"
    case "$CHOICE" in
        "$RESCAN")
            nmcli dev wifi rescan
            notify-send "Network" "Scan complete" -t 2000
            ;;
        "$DISCONNECT")
            DEV=$(nmcli -t -f type,device dev | awk -F: '$1=="wifi"{print $2; exit}')
            nmcli dev disconnect "$DEV" && notify-send "Network" "Disconnected" -t 2000
            ;;
        *)
            SSID=$(echo "$CHOICE" | sed 's/^[^ ]*  //' | sed 's/  $//')
            if nmcli con show "$SSID" &>/dev/null; then
                nmcli con up "$SSID"
            else
                SECURITY=$(nmcli -t -f ssid,security dev wifi list 2>/dev/null \
                    | awk -F: -v s="$SSID" '$1==s{print $2; exit}')
                if [ -n "$SECURITY" ] && [ "$SECURITY" != "--" ]; then
                    PASS=$(rofi -dmenu -password -p "  Password for $SSID" \
                        -theme-str 'window {width: 400px;} listview {lines: 0;}')
                    [ -z "$PASS" ] && exit 0
                    nmcli dev wifi connect "$SSID" password "$PASS"
                else
                    nmcli dev wifi connect "$SSID"
                fi
            fi
            notify-send "Network" "Conectado a $SSID" -t 3000
            ;;
    esac
}

if [ -n "$ROFI_RETV" ]; then
    if [ -n "$1" ]; then
        do_action "$1"
    else
        printf "%s\n%s\n%s\n" "$RESCAN" "$DISCONNECT" "$(list_networks)"
    fi
    exit 0
fi

ACTIVE=$(nmcli -t -f active,ssid dev wifi 2>/dev/null | awk -F: '$1=="yes"{print $2}')
PROMPT="  Network"
[ -n "$ACTIVE" ] && PROMPT="  $ACTIVE"

CHOICE=$(printf "%s\n%s\n%s" "$RESCAN" "$DISCONNECT" "$(list_networks)" \
    | rofi -dmenu -i -p "$PROMPT" -theme-str 'window {width: 450px;}')

[ -z "$CHOICE" ] && exit 0
do_action "$CHOICE"
