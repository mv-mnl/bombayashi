#!/bin/bash
# Requires: bw (Bitwarden CLI, apuntado a tu server autoalojado), jq, wl-copy
# Setup único (en una terminal, antes de usar este script):
#   bw config server https://tu-servidor-vaultwarden.tld
#   bw login tu@correo.com
# Doble modo: standalone (keybind propio) o modo-script de rofi (pestaña del menu principal)

RUNTIME_DIR="${XDG_RUNTIME_DIR:-/tmp}"
SESSION_FILE="$RUNTIME_DIR/bw_session_$(id -u)"
SESSION_TTL=900 # segundos que se guarda la sesión desbloqueada
ACTIONS="  Copiar contraseña\n  Copiar usuario\n  Copiar OTP"

bw_session_valid() {
    [ -n "$1" ] && bw unlock --check --session "$1" &>/dev/null
}

bw_unlock() {
    local password session
    password=$(rofi -dmenu -password -p "  Master password")
    [ -z "$password" ] && return 1

    session=$(bw unlock "$password" --raw 2>/dev/null)
    if [ -z "$session" ]; then
        notify-send "Bitwarden" "Contraseña maestra incorrecta" -t 2000
        return 1
    fi

    umask 077
    printf '%s' "$session" > "$SESSION_FILE"
    ( sleep "$SESSION_TTL"; bw lock --session "$session" &>/dev/null; rm -f "$SESSION_FILE" ) &disown
    printf '%s' "$session"
}

bw_session() {
    local session
    session=$(cat "$SESSION_FILE" 2>/dev/null)
    if bw_session_valid "$session"; then
        printf '%s' "$session"
    else
        rm -f "$SESSION_FILE"
        bw_unlock
    fi
}

list_entries() {
    bw list items --session "$1" 2>/dev/null | jq -r '.[].name' | sort -u
}

do_copy_action() {
    local ENTRY="$1" ACTION="$2" SESSION="$3"
    case "$ACTION" in
        *"Copiar contraseña"*)
            bw get password "$ENTRY" --session "$SESSION" | tr -d '\n' | wl-copy
            notify-send "Bitwarden" "Contraseña copiada (se borra en 30s)" -t 2000
            { sleep 30; wl-copy --clear; } &disown
            ;;
        *"Copiar usuario"*)
            USER=$(bw get username "$ENTRY" --session "$SESSION" 2>/dev/null)
            if [ -z "$USER" ]; then
                notify-send "Bitwarden" "No se encontró usuario" -t 2000
            else
                printf '%s' "$USER" | wl-copy
                notify-send "Bitwarden" "Usuario copiado" -t 2000
            fi
            ;;
        *"Copiar OTP"*)
            OTP=$(bw get totp "$ENTRY" --session "$SESSION" 2>/dev/null)
            if [ -z "$OTP" ]; then
                notify-send "Bitwarden" "Esta entrada no tiene OTP" -t 2000
            else
                printf '%s' "$OTP" | tr -d '\n' | wl-copy
                notify-send "Bitwarden" "OTP copiado" -t 2000
            fi
            ;;
    esac
}

if ! command -v bw &>/dev/null; then
    notify-send "Bitwarden" "bw CLI no está instalado" -t 3000
    exit 0
fi

if ! bw login --check &>/dev/null; then
    notify-send "Bitwarden" "No has iniciado sesión: corre 'bw config server <url> && bw login' en una terminal" -t 5000
    exit 0
fi

if [ -n "$ROFI_RETV" ]; then
    SESSION=$(bw_session)
    [ -z "$SESSION" ] && exit 0
    if [ -z "$1" ]; then
        if [ -n "$ROFI_DATA" ]; then
            printf "%b" "$ACTIONS\n"
        else
            list_entries "$SESSION"
        fi
    else
        if [ -z "$ROFI_DATA" ]; then
            echo -en "\0data\x1f$1\n"
            printf "%b" "$ACTIONS\n"
        else
            do_copy_action "$ROFI_DATA" "$1" "$SESSION"
        fi
    fi
    exit 0
fi

SESSION=$(bw_session)
[ -z "$SESSION" ] && exit 0

ENTRY=$(list_entries "$SESSION" | rofi -dmenu -i -p "  Bitwarden")
[ -z "$ENTRY" ] && exit 0

ACTION=$(printf "%b" "$ACTIONS" \
    | rofi -dmenu -i -p "  $ENTRY" \
    -theme-str 'window {width: 360px;} listview {lines: 3;}')

[ -z "$ACTION" ] && exit 0
do_copy_action "$ENTRY" "$ACTION" "$SESSION"
