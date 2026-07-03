#!/bin/bash
# Busca la unica imagen dentro de wallpaper/ y la aplica como fondo con hyprpaper

set -euo pipefail

DOTS="$(cd "$(dirname "$(readlink -f "$0")")/../.." && pwd)"
WALLPAPER_DIR="$DOTS/wallpaper"

mapfile -t IMAGES < <(find "$WALLPAPER_DIR" -maxdepth 1 -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.webp" -o -iname "*.bmp" \) | sort)

if [ "${#IMAGES[@]}" -eq 0 ]; then
    notify-send "Wallpaper" "No hay ninguna imagen en $WALLPAPER_DIR" 2>/dev/null || true
    echo "No hay ninguna imagen en $WALLPAPER_DIR" >&2
    exit 1
fi

IMG="${IMAGES[0]}"

if ! pgrep -x hyprpaper >/dev/null; then
    hyprpaper &
    sleep 0.5
fi

hyprctl hyprpaper wallpaper ",$IMG"
