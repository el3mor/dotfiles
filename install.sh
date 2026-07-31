#!/usr/bin/env bash

set -e

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> Updating system..."
sudo pacman -Syu --noconfirm

echo "==> Installing required packages..."
sudo pacman -S --needed --noconfirm \
    git \
    base-devel \
    stow \
    python-pipx

#######################################
# Install yay
#######################################

if ! command -v yay >/dev/null 2>&1; then
    echo "==> Installing yay..."

    rm -rf /tmp/yay

    git clone https://aur.archlinux.org/yay.git /tmp/yay

    cd /tmp/yay

    makepkg -si --noconfirm

    cd "$REPO_DIR"

    rm -rf /tmp/yay
fi

#######################################
# Install Pywal
#######################################

if ! command -v wal >/dev/null 2>&1; then
    echo "==> Installing pywal..."
    pipx install pywal
fi

#######################################
# Native packages
#######################################

echo "==> Installing native packages..."

while read -r pkg; do
    [[ -z "$pkg" || "$pkg" =~ ^# ]] && continue
    sudo pacman -S --needed --noconfirm "$pkg"
done < packages/native.txt

#######################################
# AUR packages
#######################################

echo "==> Installing AUR packages..."

while read -r pkg; do
    [[ -z "$pkg" || "$pkg" =~ ^# ]] && continue
    yay -S --needed --noconfirm "$pkg"
done < packages/aur.txt

#######################################
# Fonts
#######################################

if [ -d "$REPO_DIR/fonts" ]; then
    echo "==> Installing fonts..."

    mkdir -p ~/.local/share/fonts
    cp "$REPO_DIR"/fonts/* ~/.local/share/fonts/

    fc-cache -fv
fi

#######################################
# SDDM Astronaut Theme
#######################################

if ! [ -d /usr/share/sddm/themes/sddm-astronaut-theme ]; then
    echo "==> Installing SDDM Astronaut Theme..."

    sudo git clone --depth 1 \
        https://github.com/Keyitdev/sddm-astronaut-theme.git \
        /usr/share/sddm/themes/sddm-astronaut-theme

    sudo cp -r \
        /usr/share/sddm/themes/sddm-astronaut-theme/Fonts/* \
        /usr/share/fonts/

    sudo fc-cache -fv

    echo "[Theme]
Current=sddm-astronaut-theme" | sudo tee /etc/sddm.conf >/dev/null
fi

#######################################
# Dotfiles
#######################################

echo "==> Installing dotfiles..."

cd "$REPO_DIR"

for dir in */; do
    case "$dir" in
        .git/|packages/|fonts/|wallpapers/)
            continue
            ;;
    esac

    stow --restow "${dir%/}"
done

#######################################
# Scripts
#######################################

chmod +x "$REPO_DIR"/bin/.local/bin/*

#######################################
# Done
#######################################

echo
echo "======================================="
echo " Installation completed successfully!"
echo "======================================="
echo
echo "Wallpapers:"
echo "  $REPO_DIR/wallpapers"
echo
echo "Run:"
echo "  setwall <wallpaper>"
echo
echo "Then logout/login."
