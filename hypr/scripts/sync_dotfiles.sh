#!/bin/bash
# ------------------------------------------------------------------------------
# Sincroniza el repo de dotfiles (bombayashi) al iniciar sesión en Hyprland.
#
# Solo actualiza si es un fast-forward limpio:
#   - Si hay cambios locales (staged o no) sin commitear -> no toca nada.
#   - Si la rama local y origin divergieron -> no toca nada.
# En ambos casos avisa por notificación para resolverlo a mano.
# ------------------------------------------------------------------------------

set -uo pipefail

REPO_DIR="$HOME/bombayashi"

notify() {
    command -v notify-send >/dev/null 2>&1 && notify-send -a "dotfiles" "$1" "$2"
}

cd "$REPO_DIR" || exit 1

# No tocar nada si hay cambios locales sin commitear
if [ -n "$(git status --porcelain)" ]; then
    notify "Dotfiles sin sincronizar" "Hay cambios locales sin commitear en bombayashi, no se hizo pull."
    exit 0
fi

BRANCH=$(git rev-parse --abbrev-ref HEAD)

if ! git fetch origin --quiet; then
    notify "Dotfiles sin sincronizar" "No se pudo hacer git fetch (¿sin internet?)."
    exit 0
fi

if ! git rev-parse "@{u}" >/dev/null 2>&1; then
    exit 0  # rama sin upstream, nada que sincronizar
fi

LOCAL=$(git rev-parse @)
REMOTE=$(git rev-parse "@{u}")

[ "$LOCAL" = "$REMOTE" ] && exit 0  # ya está al día

if git merge-base --is-ancestor "$LOCAL" "$REMOTE"; then
    if git pull --ff-only --quiet; then
        notify "Dotfiles actualizados" "Rama '$BRANCH' sincronizada con origin."
    else
        notify "Dotfiles sin sincronizar" "El fast-forward falló en '$BRANCH', revisar a mano."
    fi
else
    notify "Dotfiles divergieron" "La rama '$BRANCH' y origin se separaron, hacé el merge a mano."
fi
