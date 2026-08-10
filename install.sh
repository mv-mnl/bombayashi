#!/bin/bash
# bombayashi — instalación completa
set -euo pipefail

# ── Colores ────────────────────────────────────────────────────────────────────
R='\033[0;31m' G='\033[0;32m' Y='\033[1;33m' B='\033[0;34m' N='\033[0m'
info() { echo -e "${B}==>${N} $*"; }
ok()   { echo -e "${G} ✓ ${N} $*"; }
warn() { echo -e "${Y} ! ${N} $*"; }
die()  { echo -e "${R}[x]${N} $*" >&2; exit 1; }

[[ -f /etc/arch-release ]] || die "Solo funciona en Arch Linux / derivados (CachyOS, EndeavourOS, etc.)"
[[ $EUID -eq 0 ]]          && die "No ejecutes esto como root"

DOTS="$(cd "$(dirname "$0")" && pwd)"

# ── yay ───────────────────────────────────────────────────────────────────────
install_yay() {
    if command -v yay &>/dev/null; then
        ok "yay ya instalado"
        return
    fi
    info "Instalando yay (AUR helper)..."
    sudo pacman -S --needed --noconfirm git base-devel
    local tmp; tmp=$(mktemp -d)
    git clone https://aur.archlinux.org/yay.git "$tmp/yay"
    (cd "$tmp/yay" && makepkg -si --noconfirm)
    rm -rf "$tmp"
    ok "yay instalado"
}

# ── Paquetes ──────────────────────────────────────────────────────────────────
PKGS=(
    # --- Hyprland ---
    hyprland
    xdg-desktop-portal-hyprland   # portales Wayland (file picker, screen share)
    xdg-desktop-portal-gtk
    qt5-wayland
    qt6-wayland

    # --- UI ---
    waybar                         # barra de estado
    hyprpaper                      # fondo de pantalla
    swaync                         # centro de notificaciones
    hyprlock                       # pantalla de bloqueo
    hypridle                       # bloqueo automático por inactividad
    libnotify                      # notify-send

    # --- Terminal ---
    kitty

    # --- Shell ---
    zsh
    zsh-autosuggestions
    zsh-syntax-highlighting
    starship                       # prompt
    zoxide                         # cd inteligente
    fzf
    eza                            # ls moderno
    bat                            # cat con colores
    pkgfile                        # command-not-found

    # --- Audio (PipeWire) ---
    pipewire
    pipewire-audio
    pipewire-pulse
    wireplumber
    easyeffects

    # --- Red ---
    networkmanager
    network-manager-applet

    # --- Bluetooth ---
    bluez
    bluez-utils

    # --- Autenticación ---
    polkit-kde-agent

    # --- Captura de pantalla ---
    grim
    slurp
    wl-clipboard                   # wl-copy / wl-paste

    # --- Brillo ---
    brightnessctl

    # --- Rofi + portapapeles ---
    rofi                           # lanzador (usa XWayland; instala rofi-wayland del AUR si prefieres nativo)
    cliphist                       # historial de portapapeles para wl-clipboard

    # --- Contraseñas ---
    jq

    # --- Display manager ---
    sddm

    # --- Apps ---
    firefox

    # ─── AUR ──────────────────────────────────────────────
    spotify
    zsh-history-substring-search
    bitwarden-cli                  # da el binario `bw`, usado por rofi/scripts/bitwarden.sh
)

install_packages() {
    info "Actualizando el sistema completo primero..."
    yay -Syu --noconfirm
    ok "Sistema actualizado"

    info "Instalando paquetes faltantes..."
    yay -S --needed --noconfirm "${PKGS[@]}"
    ok "Paquetes instalados"
}

# ── Servicios ─────────────────────────────────────────────────────────────────
enable_services() {
    info "Habilitando servicios del sistema..."

    sudo systemctl enable --now NetworkManager
    ok "NetworkManager activo"

    sudo systemctl enable --now bluetooth
    ok "Bluetooth activo"

    sudo systemctl enable sddm
    ok "SDDM habilitado (arrancará en el próximo boot)"

    info "Actualizando base de datos de pkgfile..."
    sudo pkgfile --update &>/dev/null || warn "pkgfile --update falló (no crítico)"
}

# ── Shell ─────────────────────────────────────────────────────────────────────
set_zsh() {
    local zsh_bin; zsh_bin=$(command -v zsh)
    if [[ "$SHELL" == "$zsh_bin" ]]; then
        ok "zsh ya es el shell por defecto"
        return
    fi
    info "Cambiando shell por defecto a zsh..."
    chsh -s "$zsh_bin"
    ok "Shell → zsh (efectivo al próximo login)"
}

# ── Directorios ───────────────────────────────────────────────────────────────
create_dirs() {
    info "Creando directorios necesarios..."
    mkdir -p "$HOME/Imágenes/Capturas"
    ok "~/Imágenes/Capturas creado"
}

# ── Symlinks ──────────────────────────────────────────────────────────────────
run_link() {
    info "Creando symlinks (~/.config/...)..."
    bash "$DOTS/link.sh"
}

# ── Main ──────────────────────────────────────────────────────────────────────
echo ""
echo "  bombayashi — instalación"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

install_yay
install_packages
enable_services
set_zsh
create_dirs
run_link

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
ok "Instalación completa."
echo ""
warn "Próximos pasos:"
warn "  1. Tema SDDM:   sudo bash $DOTS/sddm/apply.sh"
warn "  2. Bitwarden (autoalojado): bw config server <url> && bw login <tu@correo>"
warn "  3. Reinicia el sistema"
echo ""
