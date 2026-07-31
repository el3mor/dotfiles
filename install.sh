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
# Oh My Zsh
#######################################

echo "==> Installing Oh My Zsh..."

if [ ! -d "$HOME/.oh-my-zsh" ]; then
    RUNZSH=no CHSH=no \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi


ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"


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


#######################################
# Default shell
#######################################

if [ "$SHELL" != "$(which zsh)" ]; then
    echo "==> Setting zsh as default shell..."
    chsh -s "$(which zsh)"
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

echo "==> Configuring kitty..."

mkdir -p ~/.config/kitty

if [ ! -f ~/.config/kitty/kitty.conf ]; then
    touch ~/.config/kitty/kitty.conf
fi

if ! grep -q "shell /usr/bin/zsh" ~/.config/kitty/kitty.conf; then
    echo "shell /usr/bin/zsh" >> ~/.config/kitty/kitty.conf
fi


#######################################
# Scripts
#######################################

echo "==> Installing scripts..."

chmod +x "$REPO_DIR"/bin/.local/bin/*


#######################################
# Set default wallpaper
#######################################

if [ -f "$REPO_DIR/wallpapers/obito-wallpaper.png" ]; then
    echo "==> Setting default wallpaper..."

    "$REPO_DIR/bin/.local/bin/setwall" \
    "$REPO_DIR/wallpapers/obito-wallpaper.png"
fi


#######################################
# Done
#######################################

echo
echo "======================================="
echo " Installation completed successfully!"
echo "======================================="
echo
echo "Wallpaper:"
echo "  obito-wallpaper.png"
echo
echo "Run:"
echo "  logout/login"
echo
