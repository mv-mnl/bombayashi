#!/bin/bash
# Enlaza los configs de greetd desde bombayashi a /etc/greetd/
# Requiere sudo para modificar /etc/greetd/

DOTS="$(cd "$(dirname "$0")" && pwd)"

for file in config.toml regreet.toml; do
    sudo ln -sf "$DOTS/$file" "/etc/greetd/$file"
    echo "  linked: /etc/greetd/$file -> $DOTS/$file"
done

echo "done. reiniciando greetd..."
sudo systemctl restart greetd
