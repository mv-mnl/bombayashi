#!/bin/bash
# Salida JSON combinada de uso + temperatura de CPU para el módulo custom/cpu

read -r _ u1 n1 s1 i1 w1 irq1 sirq1 st1 _ < /proc/stat
sleep 0.3
read -r _ u2 n2 s2 i2 w2 irq2 sirq2 st2 _ < /proc/stat

idle1=$((i1 + w1))
idle2=$((i2 + w2))
total1=$((u1 + n1 + s1 + i1 + w1 + irq1 + sirq1 + st1))
total2=$((u2 + n2 + s2 + i2 + w2 + irq2 + sirq2 + st2))
totald=$((total2 - total1))
idled=$((idle2 - idle1))
usage=0
[ "$totald" -gt 0 ] && usage=$(( (100 * (totald - idled)) / totald ))

temp_file=$(find /sys/devices/pci0000:00/0000:00:18.3/hwmon -name temp1_input 2>/dev/null | head -1)
temp="n/d"
[ -n "$temp_file" ] && temp=$(( $(cat "$temp_file") / 1000 ))

class="normal"
[ "$temp" != "n/d" ] && [ "$temp" -ge 85 ] && class="critical"

printf '{"text":" %s%%   %s°C","tooltip":"CPU: %s%% · %s°C","class":"%s"}\n' \
    "$usage" "$temp" "$usage" "$temp" "$class"
