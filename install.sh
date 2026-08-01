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
    python-pipx \
    zsh \
    curl

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
done < "$REPO_DIR/packages/native.txt"

#######################################
# AUR packages
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
    cp -f "$REPO_DIR"/fonts/* ~/.local/share/fonts/

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
fi

echo "[Theme]
Current=sddm-astronaut-theme" | sudo tee /etc/sddm.conf >/dev/null

#######################################
# Oh My Zsh
#######################################

echo "==> Installing Oh My Zsh..."

if [ ! -d "$HOME/.oh-my-zsh" ]; then
    RUNZSH=no CHSH=no \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

#######################################
# Zsh plugins
#######################################

echo "==> Installing zsh plugins..."

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

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autocomplete" ]; then
    git clone \
        https://github.com/marlonrichert/zsh-autocomplete.git \
        "$ZSH_CUSTOM/plugins/zsh-autocomplete"
fi

#######################################
# Default shell
#######################################

if [ "$SHELL" != "$(command -v zsh)" ]; then
    echo "==> Setting zsh as default shell..."
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
# Scripts
#######################################

echo "==> Installing scripts..."

mkdir -p ~/.local/bin

chmod +x "$REPO_DIR"/bin/.local/bin/*

for script in "$REPO_DIR"/bin/.local/bin/*; do
    ln -sf "$script" ~/.local/bin/"$(basename "$script")"
done

#######################################
# PATH
#######################################

if ! grep -q 'export PATH="$HOME/.local/bin:$PATH"' ~/.zshrc; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
fi

export PATH="$HOME/.local/bin:$PATH"

#######################################
# Kitty
#######################################

echo "==> Configuring kitty..."

mkdir -p ~/.config/kitty

touch ~/.config/kitty/kitty.conf

if ! grep -q "shell /usr/bin/zsh" ~/.config/kitty/kitty.conf; then
    echo "shell /usr/bin/zsh" >> ~/.config/kitty/kitty.conf
fi

#######################################
# Waybar Pywal
#######################################

mkdir -p ~/.config/waybar

ln -sf \
    ~/.cache/wal/colors-waybar.css \
    ~/.config/waybar/colors.css

#######################################
# Default wallpaper
#######################################

if [ -f "$REPO_DIR/wallpapers/obito-wallpaper.png" ]; then
    echo "==> Applying wallpaper..."

    ~/.local/bin/setwall \
        "$REPO_DIR/wallpapers/obito-wallpaper.png"
fi

#######################################
# Enable services
#######################################

sudo systemctl enable sddm.service
sudo systemctl enable NetworkManager.service

#######################################
# Done
#######################################

echo
echo "======================================="
echo " Installation completed successfully!"
echo "======================================="
echo
echo "Reboot the system."
