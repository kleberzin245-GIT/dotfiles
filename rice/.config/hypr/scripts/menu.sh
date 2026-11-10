#!/usr/bin/env bash
# Menu de controle do rice (Fuzzel). Abre com SUPER+M.
# Entrypoint: configura o ambiente e inicia o loop de controle.
set -euo pipefail

show_help() {
  cat <<'EOF'
Uso: menu.sh [OPÇÃO]

  (sem opção)          abre o menu interativo (Fuzzel)
  --init               gera settings.lua, binds.lua e os arquivos de estilo
  --extras             reaplica tela de bloqueio e notificações do estilo atual
  --apply-style NOME   aplica um estilo (Padrão, Liquid Glass, Omarchy)
  -h, --help           mostra esta ajuda
EOF
}

if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
  show_help
  exit 0
fi

H=~/.config/hypr
STATE=${XDG_STATE_HOME:-$HOME/.local/state}/rice
# shellcheck disable=SC2034  # CFG é usado pelas funções de menu-lib.sh
CFG=$H/settings.local.env
BINDS=$STATE/binds.tsv
SEED=$H/binds.tsv
mkdir -p ~/.cache "$STATE"

# Biblioteca do menu (funções + constantes)
# shellcheck source=menu-lib.sh
. "$(dirname "${BASH_SOURCE[0]}")"/menu-lib.sh

# Defaults versionados + estado do usuário (settings.local.env vence)
# shellcheck disable=SC1090,SC1091
[ -f "$H/settings.env" ] && . "$H/settings.env"
# shellcheck disable=SC1090,SC1091
[ -f "$CFG" ] && . "$CFG"
: "${GAPS:=Médio}" "${ROUNDING:=12}" "${BORDER:=Branca}" "${BLUR:=Leve}"
: "${INACTIVE:=0.94}" "${WOBBLE:=Wobbly}" "${WAYBAR_OP:=0.5}" "${KITTY_OP:=0.5}"
: "${STYLE:=Padrão}" "${RICE_SHELL:=waybar}"

# Atalhos: estado em ~/.local/state; o binds.tsv versionado é só a semente.
if [ ! -f "$BINDS" ]; then
  if [ -f "$SEED" ]; then
    cp "$SEED" "$BINDS"
  else
    default_binds
  fi
fi
gen_binds

case "${1:-}" in
  --init)
    ~/.config/rice/scripts/style-render.py --all
    gen_lua
    gen_binds
    exit 0
    ;;
  --extras)
    apply_extras
    exit 0
    ;;
  --apply-style)
    shift
    if [ -z "${1:-}" ]; then
      echo "ERRO: --apply-style exige o nome de um estilo." >&2
      exit 2
    fi
    apply_style "$1"
    exit 0
    ;;
  -h|--help)
    show_help
    exit 0
    ;;
  "")
    ;;
  *)
    echo "ERRO: opção desconhecida: $1" >&2
    show_help
    exit 2
    ;;
esac

# ---------------- Loop do menu ----------------
while true; do
  c=$( {
      ic "$I_WALL"  "Wallpaper"
      ic "$I_STYLE" "Estilo"
      ic "$I_THEME" "Tema"
      ic "$I_WIN"   "Janelas"
      ic "$I_BLUR"  "Blur"
      ic "$I_OPAC"  "Transparência"
      ic "$I_WOB"   "Gelatina"
      ic "$I_KEYS"  "Atalhos"
      ic "$I_POWER" "Energia"
    } | fz "Rice" 9 30 "$I_MENU" | strip)
  [ -z "$c" ] && exit 0
  case "$c" in
    "Wallpaper")     menu_wallpaper ;;
    "Estilo")        menu_estilo ;;
    "Tema")          menu_tema ;;
    "Janelas")       menu_janelas ;;
    "Blur")          menu_blur ;;
    "Transparência") menu_transp ;;
    "Gelatina")      menu_wobble ;;
    "Atalhos")       menu_atalhos ;;
    "Energia")       menu_energia ;;
  esac
done
