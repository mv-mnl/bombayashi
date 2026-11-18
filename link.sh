#!/bin/bash
# Enlaza los directorios de bombayashi a ~/.config/

DOTS="$(cd "$(dirname "$0")" && pwd)"
CONFIG="$HOME/.config"

for dir in hypr kitty rofi waybar; do
    [ -d "$CONFIG/$dir" ] && rm -rf "$CONFIG/$dir"
    ln -s "$DOTS/$dir" "$CONFIG/$dir"
    echo "  linked: $CONFIG/$dir -> $DOTS/$dir"
done

# Colores que genera quickshell en larpeo (SUPER + S). El rofi de larpeo falla si
# su @import no existe, así que se dejan archivos vacíos para cuando se cambie.
STATE="$HOME/.local/state/bombayashi"
mkdir -p "$STATE"
[ -e "$STATE/rofi-colors.rasi" ]  || : > "$STATE/rofi-colors.rasi"
[ -e "$STATE/kitty-colors.conf" ] || : > "$STATE/kitty-colors.conf"
echo "  created: $STATE"

# Carpetas de usuario que usan los atajos (y quickshell en larpeo)
mkdir -p "$HOME/Imágenes/Capturas" "$HOME/Imágenes/Wallpapers" "$HOME/.config/btop/themes"

# Comando `estilo` (cambiar entre main / larpeo). Se COPIA en vez de enlazar
# para que exista aunque la rama actual no tenga bin/estilo.
mkdir -p "$HOME/.local/bin"
install -m 755 "$DOTS/bin/estilo" "$HOME/.local/bin/estilo"
echo "  installed: $HOME/.local/bin/estilo"

# zsh
[ -d "$CONFIG/zsh" ] && rm -rf "$CONFIG/zsh"
ln -s "$DOTS/zsh" "$CONFIG/zsh"
echo "  linked: $CONFIG/zsh -> $DOTS/zsh"

[ -f "$HOME/.zshrc" ] && rm -f "$HOME/.zshrc"
ln -s "$DOTS/zsh/zshrc" "$HOME/.zshrc"
echo "  linked: $HOME/.zshrc -> $DOTS/zsh/zshrc"

echo "done."
