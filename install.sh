#!/usr/bin/env bash

set -e

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

#######################################
# Update
#######################################

echo "==> Updating system..."

sudo pacman -Syu --noconfirm

#######################################
# Base packages
#######################################

echo "==> Installing base packages..."

sudo pacman -S --needed --noconfirm \
    git \
    base-devel \
    stow \
    python-pipx \
    zsh \
    curl

#######################################
# PATH
#######################################

mkdir -p "$HOME/.local/bin"

grep -qxF 'export PATH="$HOME/.local/bin:$PATH"' "$HOME/.zprofile" 2>/dev/null || \
echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.zprofile"

export PATH="$HOME/.local/bin:$PATH"

#######################################
# yay
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
# Pywal
#######################################

echo "==> Installing pywal..."

pipx install pywal || pipx upgrade pywal

export PATH="$HOME/.local/bin:$PATH"

#######################################
# Native Packages
#######################################

echo "==> Installing native packages..."

while read -r pkg; do
    [[ -z "$pkg" || "$pkg" =~ ^# ]] && continue
    sudo pacman -S --needed --noconfirm "$pkg"
done < "$REPO_DIR/packages/native.txt"

#######################################
# AUR Packages
#######################################

echo "==> Installing AUR packages..."

while read -r pkg; do
    [[ -z "$pkg" || "$pkg" =~ ^# ]] && continue
    yay -S --needed --noconfirm "$pkg"
done < "$REPO_DIR/packages/aur.txt"

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
# SDDM Astronaut
#######################################

if [ ! -d /usr/share/sddm/themes/sddm-astronaut-theme ]; then

    echo "==> Installing SDDM Astronaut Theme..."

    sudo git clone \
        --depth 1 \
        https://github.com/Keyitdev/sddm-astronaut-theme.git \
        /usr/share/sddm/themes/sddm-astronaut-theme

    sudo cp -r \
        /usr/share/sddm/themes/sddm-astronaut-theme/Fonts/* \
        /usr/share/fonts/

    sudo fc-cache -fv

fi

echo "[Theme]
Current=sddm-astronaut-theme" | sudo tee /etc/sddm.conf >/dev/null

#######################################
# Oh My Zsh
#######################################

if [ ! -d "$HOME/.oh-my-zsh" ]; then

RUNZSH=no CHSH=no \
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

#######################################
# Zsh Plugins
#######################################

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then

git clone \
https://github.com/zsh-users/zsh-autosuggestions \
"$ZSH_CUSTOM/plugins/zsh-autosuggestions"

fi

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then

git clone \
https://github.com/zsh-users/zsh-syntax-highlighting \
"$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"

fi

#######################################
# Default Shell
#######################################

if [ "$SHELL" != "$(command -v zsh)" ]; then

    chsh -s "$(command -v zsh)"

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
# Kitty
#######################################

mkdir -p ~/.config/kitty

touch ~/.config/kitty/kitty.conf

grep -q "^shell /usr/bin/zsh$" ~/.config/kitty/kitty.conf || \
echo "shell /usr/bin/zsh" >> ~/.config/kitty/kitty.conf

grep -q "^allow_remote_control yes$" ~/.config/kitty/kitty.conf || \
echo "allow_remote_control yes" >> ~/.config/kitty/kitty.conf

#######################################
# Scripts
#######################################

chmod +x "$REPO_DIR"/bin/.local/bin/*

#######################################
# Wallpaper
#######################################

if [ -f "$REPO_DIR/wallpapers/obito-wallpaper.png" ]; then

    echo "==> Generating Pywal colors..."

    "$REPO_DIR/bin/.local/bin/setwall" \
        "$REPO_DIR/wallpapers/obito-wallpaper.png"

    mkdir -p ~/.config/waybar

    ln -sf \
        ~/.cache/wal/colors-waybar.css \
        ~/.config/waybar/colors.css

fi

#######################################
# Services
#######################################

sudo systemctl enable NetworkManager.service || true
sudo systemctl enable sddm.service || true

#######################################
# Done
#######################################

echo
echo "=========================================="
echo " Installation completed successfully!"
echo "=========================================="
echo
echo "Please reboot your system."
