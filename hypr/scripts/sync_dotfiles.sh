#!/bin/bash
# ------------------------------------------------------------------------------
# Sincroniza el repo de dotfiles (bombayashi) al iniciar sesión en Hyprland.
#
# 1. git fetch de origin.
# 2. Actualiza las OTRAS ramas de estilo (main / larpeo) sin cambiarte de rama,
#    solo si es un fast-forward limpio.
# 3. Actualiza la rama actual con pull --ff-only, solo si:
#      - no hay cambios locales sin commitear, y
#      - la rama local y origin no divergieron.
# Si algo no se puede hacer, avisa por notificación para resolverlo a mano.
# Para cambiar de estilo: comando `estilo` (o SUPER + SHIFT + E).
# ------------------------------------------------------------------------------

set -uo pipefail

REPO_DIR="$HOME/bombayashi"
BRANCHES=(main larpeo)

notify() {
    command -v notify-send >/dev/null 2>&1 && notify-send -a "dotfiles" "$1" "$2"
}

cd "$REPO_DIR" || exit 1

# Dar tiempo a que la red levante al iniciar sesión
for _ in 1 2 3 4 5 6; do
    git ls-remote --exit-code origin HEAD >/dev/null 2>&1 && break
    sleep 5
done

if ! git fetch origin --quiet; then
    notify "Dotfiles sin sincronizar" "No se pudo hacer git fetch (¿sin internet?)."
    exit 0
fi

BRANCH=$(git rev-parse --abbrev-ref HEAD)
UPDATED=()

# --- Otras ramas: fast-forward sin hacer checkout ------------------------------
for b in "${BRANCHES[@]}"; do
    [ "$b" = "$BRANCH" ] && continue
    git show-ref --verify --quiet "refs/heads/$b" || continue
    git show-ref --verify --quiet "refs/remotes/origin/$b" || continue
    [ "$(git rev-parse "$b")" = "$(git rev-parse "origin/$b")" ] && continue
    if git merge-base --is-ancestor "$b" "origin/$b"; then
        git fetch origin "$b:$b" --quiet && UPDATED+=("$b")
    else
        notify "Dotfiles divergieron" "La rama '$b' y origin se separaron, hay que hacer merge a mano."
    fi
done

# --- Rama actual ---------------------------------------------------------------
if [ -n "$(git status --porcelain)" ]; then
    notify "Dotfiles sin sincronizar" "Hay cambios sin commitear en '$BRANCH', no se hizo pull."
elif git rev-parse "@{u}" >/dev/null 2>&1; then
    LOCAL=$(git rev-parse @)
    REMOTE=$(git rev-parse "@{u}")
    if [ "$LOCAL" != "$REMOTE" ]; then
        if git merge-base --is-ancestor "$LOCAL" "$REMOTE"; then
            if git pull --ff-only --quiet; then
                UPDATED+=("$BRANCH (actual)")
            else
                notify "Dotfiles sin sincronizar" "El fast-forward falló en '$BRANCH', revisar a mano."
            fi
        else
            notify "Dotfiles divergieron" "La rama '$BRANCH' y origin se separaron, hay que hacer merge a mano."
        fi
    fi
fi

if [ "${#UPDATED[@]}" -gt 0 ]; then
    notify "Dotfiles actualizados" "Ramas al día con GitHub: ${UPDATED[*]}"
fi

# Mantener al día la copia del comando `estilo` (vive fuera del repo)
if [ -f "$REPO_DIR/bin/estilo" ]; then
    mkdir -p "$HOME/.local/bin"
    cmp -s "$REPO_DIR/bin/estilo" "$HOME/.local/bin/estilo" || install -m 755 "$REPO_DIR/bin/estilo" "$HOME/.local/bin/estilo"
fi
