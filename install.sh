#!/usr/bin/env bash
# Entrada única para instalar o rice.
#
# Detecta a distribuição e segue o fluxo apropriado:
#   install.sh          -> Arch/derivados (executa o bootstrap.sh, completo)
#   install.sh debian   -> Ubuntu/Debian (guia de pacotes com apt)
#   install.sh fedora   -> Fedora/RPM (guia de pacotes com dnf)
#   install.sh ?        -> sistema não reconhecido (sugestão genérica)

cd "$(dirname "$0")"

say() { echo "$@"; }

# 1) Detectar o gerenciador de pacotes
if command -v pacman >/dev/null 2>&1; then
  MANAGER="pacman"
elif command -v apt >/dev/null 2>&1; then
  MANAGER="apt"
elif command -v dnf >/dev/null 2>&1; then
  MANAGER="dnf"
else
  MANAGER="unknown"
fi

# 2) Executar o fluxo
case "$MANAGER" in
  pacman)
    say "Detectado Arch Linux (ou derivado)."
    say "Executando o bootstrap.sh (pode levar uns minutos)..."
    echo
    echo "Os pacotes oficiais que serão instalados já são listados"
    echo "pelo próprio script. Só confirme e aguarde o login."
    echo
    if [ "${1:-}" = "--no-run" ]; then
      say "Nunca foi executado (--no-run)."
    else
      ./bootstrap.sh
    fi
    ;;
  apt)
    say "Detectado Ubuntu/Debian."
    echo "Instale os pacotes com:"
    echo
    echo "  sudo apt install -y git stow imagemagick pkg-config libglib2.0-dev libwayland-dev wayland-protocols libwayland-egl1 waybar libnotify gtk2.0 gtk3.0 libadwaita-1-dev starship eza bat rofi imagemagick fastfetch"
    echo
    say "Depois disso, rode: ./install.sh"
    ;;
  dnf)
    say "Detectado Fedora/RPM."
    echo "Instale os pacotes com:"
    echo
    echo "  sudo dnf install -y git stow imagemagick pkg-config libwayland-devel wayland-protocols waybar libnotify gtk3-devel libadwaita-devel starship eza bat rofi imagemagick fastfetch"
    echo
    say "Depois disso, rode: ./install.sh"
    ;;
  *)
    say "Sistema operacional não reconhecido."
    echo
    say "Se o seu sistema for Debian/Ubuntu, rode:"
    echo
    echo "  sudo apt install -y git stow imagemagick pkg-config libglib2.0-dev libwayland-dev wayland-protocols libwayland-egl1 waybar libnotify gtk2.0 gtk3.0 libadwaita-1-dev starship eza bat rofi imagemagick fastfetch"
    echo
    say "Se for Fedora/RPM, rode:"
    echo
    echo "  sudo dnf install -y git stow imagemagick pkg-config libwayland-devel wayland-protocols waybar libnotify gtk3-devel libadwaita-devel starship eza bat rofi imagemagick fastfetch"
    echo
    say "No final, reinicie a sessão e o rice será montado no login."
    ;;
esac
