#!/bin/bash
# Salida JSON para el módulo custom/gpu de waybar (Intel iGPU vía intel_gpu_top)
# Requiere: intel-gpu-tools + setcap cap_perfmon,cap_sys_ptrace=ep sobre intel_gpu_top

sample=$(intel_gpu_top -d drm:/dev/dri/card1 -J -s 800 -n 2 2>/dev/null)
usage=$(echo "$sample" | jq -r '[.[-1].engines[].busy] | max | floor' 2>/dev/null)

if [ -z "$usage" ] || [ "$usage" = "null" ]; then
    printf '{"text":" n/d","tooltip":"intel_gpu_top no disponible","class":"disconnected"}\n'
    exit 0
fi

# El iGPU comparte die con el CPU: no tiene hwmon propio, se usa coretemp.
temp_file=$(for h in /sys/class/hwmon/hwmon*; do
    [ "$(cat "$h/name" 2>/dev/null)" = "coretemp" ] && echo "$h/temp1_input" && break
done)
temp="n/d"
[ -n "$temp_file" ] && [ -r "$temp_file" ] && temp=$(( $(cat "$temp_file") / 1000 ))

class="normal"
[ "$temp" != "n/d" ] && [ "$temp" -ge 80 ] && class="critical"

printf '{"text":" %s%%  %s°C","tooltip":"GPU: %s%% · %s°C","class":"%s"}\n' \
    "$usage" "$temp" "$usage" "$temp" "$class"
