#!/usr/bin/env bash
# Menu de controle do rice (Fuzzel). Abre com SUPER+M ou pelo botão da Waybar.
# Entrypoint: configura o ambiente e inicia o loop de controle.

H=~/.config/hypr
CFG=$H/settings.env
BINDS=$H/binds.tsv
mkdir -p ~/.cache

# Biblioteca do menu (funções + constantes)
# shellcheck source=menu-lib.sh
. "$(dirname "${BASH_SOURCE[0]}")"/menu-lib.sh

# Atalhos: dados
default_binds
[ -f "$BINDS" ] || default_binds
gen_binds

if [ "$1" = "--init" ]; then
  gen_lua
  gen_binds
  exit 0
fi

if [ "$1" = "--extras" ]; then
  apply_extras
  exit 0
fi

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
