#!/bin/bash
# Snapshot de sistema para la barra de quickshell (una línea por métrica).
# La barra calcula los porcentajes de CPU y la velocidad de red con la diferencia
# entre dos snapshots, así que este script no duerme.

read -r _ u n s i w irq sirq st _ < /proc/stat
echo "cpu $((u + n + s + i + w + irq + sirq + st)) $((i + w))"

awk '/^MemTotal:/ {t=$2} /^MemAvailable:/ {a=$2} END {print "mem", t, a}' /proc/meminfo

# Suma rx/tx de todas las interfaces menos loopback
awk -F'[: ]+' 'NR > 2 && $2 != "lo" {rx += $3; tx += $11} END {print "net", rx + 0, tx + 0}' /proc/net/dev

for h in /sys/class/hwmon/hwmon*; do
    name=$(cat "$h/name" 2>/dev/null)
    if [ "$name" = "coretemp" ] || [ "$name" = "k10temp" ]; then
        echo "temp $(( $(cat "$h/temp1_input") / 1000 ))"
        break
    fi
done

echo "disk $(df --output=pcent / | tail -1 | tr -dc '0-9')"
