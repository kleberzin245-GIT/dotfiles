#!/usr/bin/env bash
# Restaura o rice numa máquina nova (Arch/CachyOS/EndeavourOS).
set -Eeuo pipefail

die() { echo "ERRO: $*" >&2; exit 1; }

command -v pacman >/dev/null 2>&1 || die "pacman não encontrado (este instalador é para Arch e derivados)."
command -v sudo   >/dev/null 2>&1 || die "sudo não encontrado. Instale-o antes de continuar."
[[ $EUID -ne 0 ]] || die "não execute como root. Use o seu usuário normal."

# Detecta o gerenciador de pacotes e orienta a instalação
if command -v pacman >/dev/null 2>&1; then
  DISTRO="arch"
elif command -v apt >/dev/null 2>&1; then
  DISTRO="debian"
elif command -v dnf >/dev/null 2>&1; then
  DISTRO="fedora"
else
  DISTRO="unknown"
fi

case "$DISTRO" in
  arch)
    echo "==> Sistema detectado: Arch Linux (ou derivado)."
    ;;
  debian)
    echo "AVISO: Ubuntu/Debian detectado. Essa máquina não é Arch."
    echo "       Siga os passos de instalação em docs/installation.md#2-ubuntu--debian-manual."
    exit 1
    ;;
  fedora)
    echo "AVISO: Fedora detectado. Essa máquina não é Arch."
    echo "       Siga os passos de instalação em docs/installation.md#3-fedora--rpm-manual."
    exit 1
    ;;
  *)
    echo "AVISO: Sistema operacional desconhecido. Siga docs/installation.md."
    exit 1
    ;;
esac

cd "$(dirname "$0")"

echo "==> Pacotes oficiais"
sudo pacman -S --needed --noconfirm \
  git stow base-devel \
  hyprland hyprlock hypridle hyprpolkitagent xdg-desktop-portal-hyprland \
  waybar kitty fuzzel mako libnotify \
  pipewire wireplumber pipewire-pulse pavucontrol brightnessctl playerctl \
  bluez bluez-utils bluetui btop \
  grim slurp wl-clipboard cliphist \
  ttf-jetbrains-mono-nerd papirus-icon-theme adw-gtk-theme nwg-look \
  rofi imagemagick starship fastfetch eza bat

sudo systemctl enable --now bluetooth.service || echo "AVISO: não consegui ativar o bluetooth (sem adaptador?)."

echo "==> AUR (matugen + awww/swww)"
if command -v paru >/dev/null 2>&1; then
  AUR=paru
elif command -v yay >/dev/null 2>&1; then
  AUR=yay
else
  echo "Nenhum helper AUR encontrado. Instalando yay-bin..."
  BUILD_DIR="$(mktemp -d)"
  trap 'rm -rf -- "$BUILD_DIR"' EXIT
  git clone https://aur.archlinux.org/yay-bin.git "$BUILD_DIR/yay-bin"
  (cd "$BUILD_DIR/yay-bin" && makepkg -si --noconfirm)
  command -v yay >/dev/null 2>&1 || die "não foi possível instalar o yay."
  AUR=yay
fi

"$AUR" -S --needed --noconfirm matugen-bin
if ! "$AUR" -S --needed --noconfirm awww; then
  echo "awww não pôde ser instalado. Tentando swww..."
  "$AUR" -S --needed --noconfirm swww
fi

echo "==> Ligando as configs (stow)"
# Num PC novo o Hyprland/Kitty já podem ter criado configs padrão no mesmo lugar.
# Em vez de apagar ou sobrescrever, mandamos os arquivos que conflitam para um backup.
backup_conflicts() {
  local out dest target
  out="$(stow --no --target="$HOME" rice 2>&1)" || true
  dest="$HOME/.config-backup-rice-$(date +%Y%m%d-%H%M%S)"
  while IFS= read -r target; do
    [[ -n "$target" ]] || continue
    [[ -e "$HOME/$target" || -L "$HOME/$target" ]] || continue
    mkdir -p "$dest/$(dirname "$target")"
    mv -- "$HOME/$target" "$dest/$target"
    echo "   backup: ~/$target -> $dest/$target"
  done < <(sed -nE 's/^[[:space:]]*\* existing target (is neither a link nor a directory|is not owned by stow): (.*)$/\2/p' <<<"$out")
}
backup_conflicts
stow --target="$HOME" rice || die "o stow ainda encontrou conflitos. Rode: stow --no --verbose --target=\"\$HOME\" rice"

mkdir -p "$HOME/Pictures/Wallpapers"

if [[ -f "$HOME/.config/shell/rice.sh" ]]; then
  touch "$HOME/.bashrc"
  if ! grep -qF 'shell/rice.sh' "$HOME/.bashrc"; then
    # shellcheck disable=SC2016
    printf '\n%s\n' '[ -f "$HOME/.config/shell/rice.sh" ] && . "$HOME/.config/shell/rice.sh"' >> "$HOME/.bashrc"
  fi
fi

if [[ -d "$HOME/.config/hypr/scripts" ]]; then
  find -L "$HOME/.config/hypr/scripts" -maxdepth 1 -type f -name '*.sh' -exec chmod +x {} +
else
  echo "AVISO: diretório de scripts do Hyprland não encontrado."
fi
"$HOME/.config/hypr/scripts/menu.sh" --init

echo
echo "Pronto! Agora:"
echo "  1) Coloque wallpapers em ~/Pictures/Wallpapers"
echo "  2) ~/.config/hypr/scripts/wallpaper.sh ~/Pictures/Wallpapers/SUA_IMAGEM.png"
echo "  3) Faça logout e login"
