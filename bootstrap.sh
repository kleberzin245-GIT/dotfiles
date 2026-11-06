#!/usr/bin/env bash
# Restaura o rice numa máquina nova (Arch/CachyOS/EndeavourOS).
set -e
cd "$(dirname "$0")"

echo "==> Pacotes oficiais"
sudo pacman -S --needed --noconfirm \
  git stow base-devel \
  hyprland hyprlock hypridle hyprpolkitagent xdg-desktop-portal-hyprland \
  waybar kitty fuzzel mako libnotify \
  pipewire wireplumber pavucontrol brightnessctl playerctl \
  grim slurp wl-clipboard cliphist \
  ttf-jetbrains-mono-nerd papirus-icon-theme adw-gtk-theme nwg-look

echo "==> AUR (matugen + awww/swww)"
if ! command -v paru >/dev/null && ! command -v yay >/dev/null; then
  git clone https://aur.archlinux.org/yay-bin.git /tmp/yay-bin
  (cd /tmp/yay-bin && makepkg -si --noconfirm)
fi
if command -v paru >/dev/null; then AUR=paru; else AUR=yay; fi
$AUR -S --needed --noconfirm matugen-bin
$AUR -S --needed --noconfirm awww || $AUR -S --needed --noconfirm swww

echo "==> Ligando as configs (stow)"
# --adopt puxa arquivos que já existem pra dentro do repo; o checkout devolve a versão do repo
stow --adopt -t "$HOME" rice
git checkout -- .

mkdir -p ~/Pictures/Wallpapers
chmod +x ~/.config/hypr/scripts/*.sh
~/.config/hypr/scripts/menu.sh --init

echo
echo "Pronto! Agora:"
echo "  1) Coloque wallpapers em ~/Pictures/Wallpapers"
echo "  2) ~/.config/hypr/scripts/wallpaper.sh ~/Pictures/Wallpapers/SUA_IMAGEM.png"
echo "  3) Faça logout e login"
