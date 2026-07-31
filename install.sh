#!/usr/bin/env bash

set -e

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> Updating system..."
sudo pacman -Syu --noconfirm

echo "==> Installing required packages..."
sudo pacman -S --needed --noconfirm git base-devel stow

if ! command -v yay >/dev/null 2>&1; then
    echo "==> Installing yay..."

    git clone https://aur.archlinux.org/yay.git /tmp/yay
    cd /tmp/yay

    makepkg -si --noconfirm

    cd "$REPO_DIR"
    rm -rf /tmp/yay
fi

echo "==> Installing native packages..."

grep -vE '^(#|$)' packages/native.txt | while read -r pkg; do
    sudo pacman -S --needed --noconfirm "$pkg"
done

echo "==> Installing AUR packages..."

grep -vE '^(#|$)' packages/aur.txt | while read -r pkg; do
    yay -S --needed --noconfirm "$pkg"
done

echo "==> Installing fonts..."

mkdir -p ~/.local/share/fonts

if [ -d "$REPO_DIR/fonts" ]; then
    cp "$REPO_DIR"/fonts/* ~/.local/share/fonts/
    fc-cache -fv
fi

echo "==> Creating symlinks..."

cd "$REPO_DIR"

for dir in */; do
    case "$dir" in
        .git/|packages/|fonts/|wallpapers/)
            continue
            ;;
    esac

    stow "${dir%/}"
done

echo ""
echo "======================================"
echo " Installation completed successfully!"
echo "======================================"
echo ""
echo "Wallpapers are located in:"
echo "  $REPO_DIR/wallpapers"
echo ""
echo "Use:"
echo "  setwall <wallpaper>"
echo ""
echo "Then logout/login."
