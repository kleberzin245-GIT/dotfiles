#!/usr/bin/env bash
set -euo pipefail
# Uso: wallpaper.sh            -> wallpaper aleatório
#      wallpaper.sh restore    -> reaplica o último (usado no boot)
#      wallpaper.sh /caminho/img.jpg
DIR="$HOME/Pictures/Wallpapers"
STATE="$HOME/.cache/current_wallpaper"
mkdir -p "$(dirname "$STATE")" "$DIR"

# swww foi renomeado para awww em versões recentes; suporta os dois
if command -v awww >/dev/null; then W=awww; else W=swww; fi
pgrep -x "$W-daemon" >/dev/null || { "$W-daemon" >/dev/null 2>&1 & sleep 1; }

ARG="${1:-}"
case "$ARG" in
  restore) WP="$(cat "$STATE" 2>/dev/null || true)" ;;
  "")      WP="$(find "$DIR" -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) | shuf -n1)" ;;
  *)       WP="$ARG" ;;
esac

# primeira execução: sem wallpaper salvo, usa um da pasta
if [ ! -f "$WP" ] && [ "$ARG" = restore ]; then
  WP="$(find "$DIR" -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) | shuf -n1)"
fi

if [ ! -f "$WP" ]; then
  notify-send "Wallpaper" "Nenhuma imagem encontrada em $DIR"
  exit 1
fi

"$W" img "$WP" --transition-type grow --transition-pos center --transition-duration 1.5 --transition-fps 60
echo "$WP" > "$STATE"

# Gera o tema dinâmico a partir do wallpaper (cores + configurações).
# Se falhar, avisa para não deixar o ambiente consistente.
if ! matugen image "$WP" -m "$(cat ~/.cache/matugen_mode 2>/dev/null || echo dark)" --source-color-index "$(cat ~/.cache/matugen_index 2>/dev/null || echo 0)"; then
  echo "ERRO: o matugen não gerou o tema. Verifique se o wallpaper foi carregado." >&2
fi

# Ainda assim garante que o Mako e Fastfetch rodem com o tema atual
[ -x ~/.config/hypr/scripts/mako-build.sh ]      && ~/.config/hypr/scripts/mako-build.sh
[ -x ~/.config/hypr/scripts/fastfetch-build.sh ] && ~/.config/hypr/scripts/fastfetch-build.sh
