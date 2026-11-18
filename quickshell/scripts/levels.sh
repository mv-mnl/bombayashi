#!/bin/bash
# Imprime "vol <n> <muted>" y "bri <n>" (bri -1 si no hay backlight).
vol=$(~/.config/hypr/scripts/audio.sh get | tr -dc '0-9')
sink=$(pactl list short sinks | awk '$2 !~ /easyeffects/ {print $2; exit}')
muted=0
[ -n "$sink" ] && pactl get-sink-mute "$sink" 2>/dev/null | grep -q "yes" && muted=1
echo "vol ${vol:-0} $muted"

bri=$(brightnessctl -m -c backlight 2>/dev/null | head -1 | cut -d, -f4 | tr -dc '0-9')
echo "bri ${bri:--1}"
