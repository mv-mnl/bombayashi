#!/bin/bash
# Enlaza los directorios de bombayashi a ~/.config/

DOTS="$(cd "$(dirname "$0")" && pwd)"
CONFIG="$HOME/.config"

for dir in hypr kitty rofi waybar; do
    [ -d "$CONFIG/$dir" ] && rm -rf "$CONFIG/$dir"
    ln -s "$DOTS/$dir" "$CONFIG/$dir"
    echo "  linked: $CONFIG/$dir -> $DOTS/$dir"
done

# zsh
[ -d "$CONFIG/zsh" ] && rm -rf "$CONFIG/zsh"
ln -s "$DOTS/zsh" "$CONFIG/zsh"
echo "  linked: $CONFIG/zsh -> $DOTS/zsh"

[ -f "$HOME/.zshrc" ] && rm -f "$HOME/.zshrc"
ln -s "$DOTS/zsh/zshrc" "$HOME/.zshrc"
echo "  linked: $HOME/.zshrc -> $DOTS/zsh/zshrc"

echo "done."
