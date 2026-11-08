#!/usr/bin/env bash
# Monta ~/.config/mako/config = formato do estilo atual + cores do matugen.
PARTS=~/.config/mako/colors.part
[ -f "$PARTS" ] || { echo "mako-build: $PARTS não existe (troque o wallpaper uma vez)"; exit 0; }
# shellcheck disable=SC1090
. ~/.config/hypr/settings.env 2>/dev/null

case "${STYLE:-Padrão}" in
  "Liquid Glass") A=aa; BS=1; BR=24; PAD=16; MAR=12; W=360 ;;
  "Omarchy")      A=f2; BS=2; BR=0;  PAD=10; MAR=8;  W=340 ;;
  *)              A=ee; BS=2; BR=12; PAD=12; MAR=10; W=340 ;;
esac

{
  cat <<EOT
font=JetBrainsMono Nerd Font 11
border-size=$BS
border-radius=$BR
padding=$PAD
margin=$MAR
width=$W
default-timeout=6000
anchor=top-right
layer=overlay

EOT
  if [ "${STYLE:-}" = "Liquid Glass" ]; then
    # borda de vidro: branco translúcido em vez da cor do tema
    sed "s/@ALPHA@/$A/g" "$PARTS" | sed '0,/^border-color=.*/s//border-color=#ffffff59/'
  else
    sed "s/@ALPHA@/$A/g" "$PARTS"
  fi
} > ~/.config/mako/config

makoctl reload 2>/dev/null || true
