#!/bin/bash
# ------------------------------------------------------------------------------
# Detecta el ancho del monitor principal y genera conf/monitors.lua con la
# escala adecuada. Pensado para correr como exec-once al iniciar Hyprland.
#
# conf/monitors.lua queda ignorado por git (ver conf/.gitignore) porque su
# contenido depende de la máquina: así una laptop HiDPI y un desktop normal
# no pisan la config del otro al sincronizar el repo entre equipos.
# ------------------------------------------------------------------------------

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONF_DIR="$(cd "$SCRIPT_DIR/.." && pwd)/conf"
TARGET_FILE="$CONF_DIR/monitors.lua"

# A partir de este ancho en píxeles se considera pantalla HiDPI
HIDPI_WIDTH_THRESHOLD=3000
HIDPI_SCALE="1.50"
NORMAL_SCALE="1"

# hyprctl puede tardar un instante en responder justo al arrancar
WIDTH=""
for _ in $(seq 1 10); do
    WIDTH=$(hyprctl monitors -j 2>/dev/null | jq -r '.[0].width // empty')
    [ -n "$WIDTH" ] && break
    sleep 0.5
done

if [ -n "$WIDTH" ] && [ "$WIDTH" -ge "$HIDPI_WIDTH_THRESHOLD" ]; then
    SCALE="$HIDPI_SCALE"
else
    SCALE="$NORMAL_SCALE"
fi

cat > "$TARGET_FILE" <<EOF
-- ------------------------------------------------------------------------------
-- 1. MONITORES
-- ------------------------------------------------------------------------------
-- Generado automáticamente por scripts/detect_monitor_scale.sh
-- el $(date '+%Y-%m-%d %H:%M:%S') (ancho detectado: ${WIDTH:-desconocido}px).
-- No editar a mano: este archivo está ignorado por git (conf/.gitignore).

hl.monitor({ output = "", mode = "preferred", position = "auto", scale = $SCALE })
EOF

# Aplicar sin reiniciar Hyprland
hyprctl reload >/dev/null 2>&1 || true
