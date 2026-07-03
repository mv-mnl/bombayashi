#!/bin/bash
# Control de volumen que apunta a los sinks de hardware reales.
#
# EasyEffects crea un sink virtual ("easyeffects_sink") que queda marcado
# como sink por defecto, pero es cosmético: EasyEffects lee y reenvía el
# audio directo al hardware por su cuenta, sin respetar el volumen/mute
# de ese sink virtual. Por eso hay que operar sobre los sinks ALSA reales.
#
# Uso: audio.sh up|down|mute-toggle|set <pct>|get

real_sinks() {
    pactl list short sinks | awk '$2 !~ /easyeffects/ {print $2}'
}

running_sink() {
    pactl list sinks | awk '
        /^Sink #/ { name="" ; state="" }
        /Name: / { name=$2 }
        /State: / { state=$2 }
        /^$/ { if (name !~ /easyeffects/ && state == "RUNNING") print name }
    ' | head -1
}

each_real_sink() {
    local cmd="$1" arg="$2"
    while read -r sink; do
        [ -n "$sink" ] && pactl "$cmd" "$sink" "$arg"
    done < <(real_sinks)
}

get_volume() {
    local sink
    sink=$(running_sink)
    [ -z "$sink" ] && sink=$(real_sinks | head -1)
    [ -z "$sink" ] && { echo "0%"; return; }
    pactl list sinks | grep -A15 "Name: $sink$" | grep -m1 "Volume:" | grep -oP '\d+%' | head -1
}

case "$1" in
    up)
        each_real_sink set-sink-volume "+5%"
        each_real_sink set-sink-mute 0
        ;;
    down)
        each_real_sink set-sink-volume "-5%"
        ;;
    mute-toggle)
        each_real_sink set-sink-mute toggle
        ;;
    set)
        each_real_sink set-sink-volume "${2}%"
        each_real_sink set-sink-mute "$([ "${2:-0}" -eq 0 ] && echo 1 || echo 0)"
        ;;
    get)
        get_volume
        ;;
esac
