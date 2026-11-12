#!/bin/bash
# Barra de uso del disco / para el módulo custom/disk (estilo slider, con pango)

read -r size used avail pct < <(df -h --output=size,used,avail,pcent / | tail -1)
pct=${pct%\%}

width=20
filled=$(( (pct * width + 50) / 100 ))
track="#333333"

# Degradado del relleno: gris (#808080) -> blanco (#ffffff)
bar=""
for ((i = 0; i < width; i++)); do
    if   [ "$i" -eq 0 ];           then ch="╺"
    elif [ "$i" -eq $((width-1)) ]; then ch="╸"
    else                                ch="━"
    fi
    if [ "$i" -lt "$filled" ]; then
        if [ "$filled" -gt 1 ]; then
            v=$(( 128 + (127 * i) / (filled - 1) ))
        else
            v=255
        fi
        color=$(printf '#%02x%02x%02x' "$v" "$v" "$v")
    else
        color=$track
    fi
    bar+="<span color='${color}'>${ch}</span>"
done

class="normal"
[ "$pct" -ge 80 ] && class="warning"
[ "$pct" -ge 90 ] && class="critical"

printf '{"text":"󰋊  %s  %s%%","tooltip":"Disco /\\nUsado: %s\\nLibre: %s\\nTotal: %s","class":"%s","percentage":%s}\n' \
    "$bar" "$pct" "$used" "$avail" "$size" "$class" "$pct"
