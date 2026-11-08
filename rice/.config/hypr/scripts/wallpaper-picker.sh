#!/usr/bin/env bash
set -euo pipefail
# Grade de miniaturas dos wallpapers (rofi). Uso: wallpaper-picker.sh [--warm]
DIR=~/Pictures/Wallpapers
CACHE=~/.cache/wallpaper-thumbs-sq
THEME=~/.config/rofi/wallpaper.rasi
STATE=~/.cache/current_wallpaper
# shellcheck disable=SC1090
. ~/.config/hypr/settings.env 2>/dev/null

mkdir -p "$CACHE" "$DIR"
IM=$(command -v magick || command -v convert) || { notify-send "Wallpaper" "Instale o imagemagick"; exit 1; }

# miniatura em cache (chave = caminho + data de modificação)
thumb() {
  local f="$1" key t
  key=$(printf '%s' "$f" | md5sum | cut -d' ' -f1)-$(stat -c %Y "$f")
  t="$CACHE/$key.png"
  [ -f "$t" ] || "$IM" "${f}[0]" -auto-orient -thumbnail 400x400^ -gravity center -extent 400x400 "$t" 2>/dev/null
  printf '%s\n' "$t"
}
export -f thumb
export CACHE IM

mapfile -d '' FILES < <(find "$DIR" -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) -print0 | sort -z)
if [ "${#FILES[@]}" -eq 0 ]; then
  notify-send "Wallpaper" "Nenhuma imagem em $DIR"
  exit 1
fi

# gera as miniaturas que faltam, 4 por vez
printf '%s\0' "${FILES[@]}" | xargs -0 -P 4 -I{} bash -c 'thumb "$1" >/dev/null' _ {}
if [ "$1" = "--warm" ]; then echo "${#FILES[@]} miniaturas prontas"; exit 0; fi

# pequenos ajustes de formato conforme o estilo escolhido
overrides() {
  case "${STYLE:-Padrão}" in
    "Liquid Glass")
      echo 'window { border-radius: 30px; border: 1px; border-color: #ffffff59; background-color: @surface-glass; }
            inputbar { border-radius: 24px; } element { border-radius: 20px; } element-icon { border-radius: 16px; }' ;;
    "Omarchy")
      echo 'window { border-radius: 0px; } inputbar { border-radius: 0px; } element { border-radius: 0px; } element-icon { border-radius: 0px; }' ;;
    *) echo '' ;;
  esac
}

# monta a lista (arquivo temporário: o texto tem bytes NUL que não passam por variável)
LIST=$(mktemp)
cur=$(cat "$STATE" 2>/dev/null)
sel_row=0; i=1
printf 'Aleatório\x00icon\x1fmedia-playlist-shuffle\n' > "$LIST"
for f in "${FILES[@]}"; do
  n=$(basename "$f"); n=${n%.*}; n=${n//[_-]/ }
  printf '%s\x00icon\x1f%s\n' "$n" "$(thumb "$f")" >> "$LIST"
  [ "$f" = "$cur" ] && sel_row=$i
  i=$((i+1))
done

idx=$(rofi -dmenu -i -show-icons -p "Wallpaper" -format i -selected-row "$sel_row" \
        -theme "$THEME" -theme-str "$(overrides)" < "$LIST")
rm -f "$LIST"
[ -z "$idx" ] && exit 0

if [ "$idx" -eq 0 ]; then
  ~/.config/hypr/scripts/wallpaper.sh
else
  ~/.config/hypr/scripts/wallpaper.sh "${FILES[$((idx-1))]}"
fi
