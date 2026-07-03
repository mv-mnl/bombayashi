#!/bin/bash


# Switch to next layout for all keyboards
hyprctl switchxkblayout all next

# Determine the new layout for the notification
# We check the active layout of the first keyboard found in 'hyprctl devices'
STATUS=$(hyprctl devices -j | jq -r '.keyboards[] | select(.main == true) | .active_keymap' | head -1)

if [[ "$STATUS" == *"Spanish"* ]]; then
    notify-send "Hyprland" "Teclado: Español" -i input-keyboard -t 2000
    echo "es" > /tmp/hypr_keyboard_layout
else
    notify-send "Hyprland" "Teclado: Inglés (US)" -i input-keyboard -t 2000
    echo "us" > /tmp/hypr_keyboard_layout
fi
