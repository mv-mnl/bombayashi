#!/bin/bash
# Genera miniaturas de las imágenes del historial de cliphist (para el panel)
DIR="${XDG_RUNTIME_DIR:-/tmp}/qs-clip"
mkdir -p "$DIR"
cliphist list | head -80 | awk -F'\t' '$2 ~ /^\[\[ binary data .* (png|jpe?g|webp|bmp) / {print $1}' |
while read -r id; do
    [ -f "$DIR/$id.png" ] || cliphist decode "$id" > "$DIR/$id.png" 2>/dev/null
done
echo "$DIR"
