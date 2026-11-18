#!/bin/bash
# Spotify: si ya está abierto, lleva a su ventana; si no, lo abre.
if hyprctl clients -j | jq -e '.[] | select(.class | test("spotify"; "i"))' >/dev/null; then
    hyprctl dispatch 'hl.dsp.focus({ window = "class:(?i)spotify" })'
else
    flatpak run com.spotify.Client >/dev/null 2>&1 &
    disown
fi
