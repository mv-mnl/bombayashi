#!/bin/bash
# Doble modo: standalone (keybind propio) o modo-script de rofi (pestaña del menu principal)

# Hosts de ~/.ssh/config (todos los alias de cada línea "Host", sin comodines)
# + los servidores a los que ya te conectaste (~/.ssh/known_hosts, no hasheados)
HOSTS=$(
    {
        awk 'tolower($1) == "host" { for (i = 2; i <= NF; i++) if ($i !~ /[*?!]/) print $i }' ~/.ssh/config
        awk '$1 !~ /^[|#@]/ && NF {
                n = split($1, names, ",")
                for (i = 1; i <= n; i++) { h = names[i]; gsub(/^\[|\]:[0-9]+$/, "", h); print h }
             }' ~/.ssh/known_hosts
    } 2>/dev/null | awk 'NF && !seen[$0]++'
)

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
