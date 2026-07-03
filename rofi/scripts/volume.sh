#!/bin/bash
# Selector de salida de audio + nivel de volumen
# Doble modo: standalone (keybind propio) o modo-script de rofi (pestaña del menu principal)
#
# El nivel se aplica vía hypr/scripts/audio.sh sobre los sinks de hardware
# reales: @DEFAULT_AUDIO_SINK@ es el sink virtual de EasyEffects, cuyo
# volumen/mute es cosmético y no afecta lo que en verdad suena.

AUDIO_SH="$HOME/.config/hypr/scripts/audio.sh"
TOP_OPTIONS="  Cambiar nivel\n  Cambiar salida"
LEVELS="10%\n20%\n30%\n40%\n50%\n60%\n70%\n80%\n90%\n100%\n0% (silencio)"

list_sinks() {
    pactl list short sinks | awk '{print NR". "$2}'
}

set_level() {
    NUM=$(echo "$1" | tr -dc '0-9')
    "$AUDIO_SH" set "$NUM"
    notify-send "Audio" "Volumen: ${NUM}%" -t 1500
}

set_sink() {
    SINK_NAME=$(echo "$1" | awk '{print $2}')
    pactl set-default-sink "$SINK_NAME"
    notify-send "Audio" "Salida: $SINK_NAME" -t 2000
}

if [ -n "$ROFI_RETV" ]; then
    if [ -z "$1" ]; then
        case "$ROFI_DATA" in
            level) printf "%b\n" "$LEVELS" ;;
            sink)  list_sinks ;;
            *)     printf "%b\n" "$TOP_OPTIONS" ;;
        esac
    else
        case "$ROFI_DATA" in
            level) set_level "$1" ;;
            sink)  set_sink "$1" ;;
            *)
                case "$1" in
                    *"Cambiar nivel"*)
                        echo -en "\0data\x1flevel\n"
                        printf "%b\n" "$LEVELS"
                        ;;
                    *"Cambiar salida"*)
                        echo -en "\0data\x1fsink\n"
                        list_sinks
                        ;;
                esac
                ;;
        esac
    fi
    exit 0
fi

VOL=$("$AUDIO_SH" get)

CHOICE=$(printf "  Cambiar nivel (%s)\n  Cambiar salida" "$VOL" \
    | rofi -dmenu -i -p "  Audio ($VOL)" \
    -theme-str 'window {width: 380px;} listview {lines: 2;}')

[ -z "$CHOICE" ] && exit 0

case "$CHOICE" in
    *"Cambiar nivel"*)
        LEVEL=$(printf "%b" "$LEVELS" \
            | rofi -dmenu -i -p "  Volumen" \
            -theme-str 'window {width: 250px;} listview {lines: 11;}')
        [ -z "$LEVEL" ] && exit 0
        set_level "$LEVEL"
        ;;
    *"Cambiar salida"*)
        SINK=$(list_sinks | rofi -dmenu -i -p "  Salida de audio" \
            -theme-str 'window {width: 480px;}')
        [ -z "$SINK" ] && exit 0
        set_sink "$SINK"
        ;;
esac
