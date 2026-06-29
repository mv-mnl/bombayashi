#!/bin/bash
# Enlaza el tema SDDM desde bombayashi y activa SDDM como display manager.
# Reemplaza greetd si está activo.

DOTS="$(cd "$(dirname "$0")" && pwd)"
THEME_DIR="/usr/share/sddm/themes/pixel-coffee"

echo ">>> Copiando Main.qml..."
sudo cp "$DOTS/Main.qml" "$THEME_DIR/Main.qml"
echo "    copied: $DOTS/Main.qml -> $THEME_DIR/Main.qml"

echo ">>> Instalando configuración de SDDM..."
sudo mkdir -p /etc/sddm.conf.d
sudo ln -sf "$DOTS/10-sddm.conf" /etc/sddm.conf.d/10-sddm.conf
sudo install -m 755 "$DOTS/Xstop-custom" /etc/sddm.conf.d/Xstop-custom
echo "    config: /etc/sddm.conf.d/10-sddm.conf"
echo "    script: /etc/sddm.conf.d/Xstop-custom"

echo ">>> Activando SDDM..."
sudo systemctl disable --now greetd 2>/dev/null && echo "    greetd desactivado"
sudo systemctl enable --now sddm && echo "    sddm activado"

echo "done."
