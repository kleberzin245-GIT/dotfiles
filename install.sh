#!/usr/bin/env bash
# Entrada única para instalar o rice.
#
# O fluxo automatizado é suportado apenas no Arch/derivados (via bootstrap.sh).
# Nas demais distribuições o script imprime um guia de pacotes; a instalação
# manual completa está em docs/installation.md.
#
# Uso:
#   install.sh              -> Arch: executa o bootstrap.sh
#   install.sh --no-run     -> modo secagem (passa --dry-run ao bootstrap)
#   install.sh --minimal    -> instala só o essencial (repassado ao bootstrap)
#   install.sh --no-aur     -> não instala matugen/awww pelo AUR
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")" || exit 1

say() { echo "$@" ; }

usage() {
  cat <<'EOF'
Uso: install.sh [OPÇÕES DO BOOTSTRAP]

  --no-run, --dry-run   mostra o que seria feito (nada é alterado)
  --minimal             instala só o essencial
  --no-bluetooth        não instala/ativa bluetooth
  --no-aur              não instala matugen/awww pelo AUR
  -h, --help            mostra esta ajuda

No Arch, as opções são repassadas ao bootstrap.sh.
EOF
}

BOOTSTRAP_ARGS=()
PASSTHROUGH=0
for arg in "$@"; do
  case "$arg" in
    -h|--help) usage; exit 0 ;;
    --no-run|--dry-run) BOOTSTRAP_ARGS+=(--dry-run) ;;
    --minimal|--no-bluetooth|--no-aur) BOOTSTRAP_ARGS+=("$arg") ;;
    *) echo "ERRO: opção desconhecida: $arg" >&2; usage >&2; exit 2 ;;
  esac
  PASSTHROUGH=1
done

check_deps() {
  local missing=0 cmd
  for cmd in "$@"; do
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

APT_GUIDE='sudo apt install -y git stow imagemagick pkg-config libglib2.0-dev libwayland-dev wayland-protocols libwayland-egl1 libgtk-3-dev libadwaita-1-dev libnotify-bin waybar rofi fastfetch'
DNF_GUIDE='sudo dnf install -y git stow ImageMagick pkgconf-pkg-config glib2-devel wayland-devel wayland-protocols-devel libwayland-egl libgtk3-devel libadwaita-devel libnotify waybar rofi fastfetch'

if command -v pacman >/dev/null 2>&1; then
  say "Sistema detectado: Arch Linux (ou derivado)."
  # o stow é instalado pelo próprio bootstrap, então não o exigimos aqui
  check_deps git bash || exit 1
  say "Executando o bootstrap.sh (pode levar alguns minutos)..."
  echo
  exec ./bootstrap.sh "${BOOTSTRAP_ARGS[@]}"
fi

if [ "$PASSTHROUGH" -eq 1 ]; then
  say "Estas opções só se aplicam ao fluxo automático no Arch; ignorando-as."
fi

if command -v apt >/dev/null 2>&1; then
  say "Sistema detectado: Ubuntu/Debian."
  say "Este rice é automatizado apenas no Arch. Instale os pacotes manualmente:"
  echo
  echo "  $APT_GUIDE"
  echo
  say "Depois ligue as configs com: stow --no-folding --target=\"\$HOME\" rice"
  say "E siga docs/installation.md para os passos restantes."
  exit 0
fi

if command -v dnf >/dev/null 2>&1; then
  say "Sistema detectado: Fedora/RPM."
  say "Este rice é automatizado apenas no Arch. Instale os pacotes manualmente:"
  echo
  echo "  $DNF_GUIDE"
  echo
  say "Depois ligue as configs com: stow --no-folding --target=\"\$HOME\" rice"
  say "E siga docs/installation.md para os passos restantes."
  exit 0
fi

say "Sistema operacional não reconhecido."
say "Veja docs/installation.md para instalar manualmente."
exit 1
