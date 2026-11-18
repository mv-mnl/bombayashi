#!/bin/bash
# Abre btop en una kitty flotante con los colores del tema (pantalla de ajustes).
# Si ya está abierto, lo cierra (toggle).

if pkill -f "kitty --class btop-float" 2>/dev/null; then
    exit 0
fi

STATE="$HOME/.local/state/bombayashi/settings.json"
BG="#0d0d0d"; FG="#e6e6e6"; ACCENT="#ffffff"; OPACITY="0.88"
if [ -f "$STATE" ]; then
    BG=$(jq -r '.bg // "#0d0d0d"' "$STATE")
    FG=$(jq -r '.fg // "#e6e6e6"' "$STATE")
    ACCENT=$(jq -r '.accent // "#ffffff"' "$STATE")
    OPACITY=$(jq -r '.barOpacity // 0.88' "$STATE")
fi

exec kitty --class btop-float --title btop \
    -o background="$BG" -o foreground="$FG" -o cursor="$ACCENT" \
    -o selection_background="$ACCENT" -o selection_foreground="$BG" \
    -o background_opacity="$OPACITY" \
    -o window_padding_width=16 \
    -o tab_bar_style=hidden \
    -o confirm_os_window_close=0 \
    -e btop
