#!/bin/bash
# Salida JSON para el módulo custom/gpu de waybar (NVIDIA vía nvidia-smi)

read -r usage temp mem_used mem_total <<< "$(nvidia-smi \
    --query-gpu=utilization.gpu,temperature.gpu,memory.used,memory.total \
    --format=csv,noheader,nounits 2>/dev/null | tr -d ',')"

if [ -z "$usage" ]; then
    printf '{"text":" n/d","tooltip":"nvidia-smi no disponible","class":"disconnected"}\n'
    exit 0
fi

class="normal"
[ "$temp" -ge 80 ] && class="critical"

printf '{"text":" %s%%  %s°C","tooltip":"VRAM: %s/%s MiB","class":"%s"}\n' \
    "$usage" "$temp" "$mem_used" "$mem_total" "$class"
