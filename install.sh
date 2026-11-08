#!/usr/bin/env bash
# Entrada única para instalar o rice.
#
# Detecta a distribuição e segue o fluxo apropriado:
#   install.sh          -> Arch/derivados (executa o bootstrap.sh, completo)
#   install.sh --no-run -> Modo secagem (nenhuma ação executada)
#   install.sh debian   -> Ubuntu/Debian (guia de pacotes com apt)
#   install.sh fedora   -> Fedora/RPM (guia de pacotes com dnf)
#   install.sh ?        -> sistema não reconhecido (sugestão genérica)
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")" || exit 1

say() { echo "$@" ; }

# 1) Verificar flags globais
DRY_RUN=0
if [ "${1:-}" = "--no-run" ]; then
  DRY_RUN=1
  shift
fi

# 2) Verificar dependências essenciais
check_deps() {
  local missing=0
  for cmd in git bash stow; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
      echo "ERRO: dependência essencial ausente: '$cmd'." >&2
      missing=1
    fi
  done
  if [ "$missing" -ne 0 ]; then
    echo "Verifique as dependências e rode novamente." >&2
    return 1
  fi
}

# 3) Detectar o gerenciador de pacotes
if command -v pacman >/dev/null 2>&1; then
  MANAGER="pacman"
elif command -v apt >/dev/null 2>&1; then
  MANAGER="apt"
elif command -v dnf >/dev/null 2>&1; then
  MANAGER="dnf"
else
  MANAGER="unknown"
fi

say "Sistema operacional detectado: ${MANAGER}"

if [ "${DRY_RUN}" -eq 1 ]; then
  say "Modo secagem (--no-run): nenhuma ação será executada."
fi

# 4) Executar o fluxo
case "$MANAGER" in
  pacman)
    say "Detectado Arch Linux (ou derivado)."
    if [ "${DRY_RUN}" -eq 1 ]; then
      say "Modo secagem: não executarei o bootstrap.sh."
      say "Para instalar, rode: ./bootstrap.sh"
    else
      check_deps || exit 1
      say "Executando o bootstrap.sh (pode levar alguns minutos)..."
      echo
      ./bootstrap.sh
    fi
    ;;
  apt)
    say "Detectado Ubuntu/Debian."
    if [ "${DRY_RUN}" -eq 1 ]; then
      say "Modo secagem: não executarei instalações com apt."
      say "Para instalar, rode:"
      echo
      echo "  sudo apt install -y git stow imagemagick pkg-config libglib2.0-dev libwayland-dev wayland-protocols libwayland-egl1 waybar libnotify gtk2.0 gtk3.0 libadwaita-1-dev starship eza bat rofi imagemagick fastfetch"
      echo
      say "Depois disso, rode: ./install.sh"
    else
      check_deps || exit 1
      say "Executando instalações com apt automaticamente."
      say "Para instalar, rode:"
      echo
      echo "  sudo apt install -y git stow imagemagick pkg-config libglib2.0-dev libwayland-dev wayland-protocols libwayland-egl1 waybar libnotify gtk2.0 gtk3.0 libadwaita-1-dev starship eza bat rofi imagemagick fastfetch"
      echo
      say "Depois disso, rode: ./install.sh"
    fi
    ;;
  dnf)
    say "Detectado Fedora/RPM."
    if [ "${DRY_RUN}" -eq 1 ]; then
      say "Modo secagem: não executarei instalações com dnf."
      say "Para instalar, rode:"
      echo
      echo "  sudo dnf install -y git stow imagemagick pkg-config libwayland-devel wayland-protocols waybar libnotify gtk3-devel libadwaita-devel starship eza bat rofi imagemagick fastfetch"
      echo
      say "Depois disso, rode: ./install.sh"
    else
      check_deps || exit 1
      say "Executando instalações com dnf automaticamente."
      say "Para instalar, rode:"
      echo
      echo "  sudo dnf install -y git stow imagemagick pkg-config libwayland-devel wayland-protocols waybar libnotify gtk3-devel libadwaita-devel starship eza bat rofi imagemagick fastfetch"
      echo
      say "Depois disso, rode: ./install.sh"
    fi
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
