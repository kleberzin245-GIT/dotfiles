#!/usr/bin/env bash
# doctor.sh — diagnóstico do rice (somente leitura: não altera nada).
# Uso:  ./doctor.sh            relatório colorido
#       ./doctor.sh --report   texto limpo, sem o seu usuário, para colar numa issue
set -u

REPO="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"
REPORT=0; [[ "${1:-}" == "--report" ]] && REPORT=1
OK=0; WARN=0; FAIL=0
BUF="$(mktemp)"; trap 'rm -f "$BUF"' EXIT

if [[ -t 1 && $REPORT -eq 0 ]]; then
  G=$'\e[32m'; Y=$'\e[33m'; R=$'\e[31m'; B=$'\e[1m'; N=$'\e[0m'
else
  G=; Y=; R=; B=; N=
fi

out()  { if (( REPORT )); then printf '%s\n' "$*" >> "$BUF"; else printf '%s\n' "$*"; fi; }
ok()   { OK=$((OK+1));     out "  ${G}[ok]${N}     $*"; }
warn() { WARN=$((WARN+1)); out "  ${Y}[aviso]${N}  $*"; }
fail() { FAIL=$((FAIL+1)); out "  ${R}[erro]${N}   $*"; }
sec()  { out ""; out "${B}$*${N}"; }
have() { command -v "$1" >/dev/null 2>&1; }
ver()  { pacman -Q "$@" 2>/dev/null | head -1; }

out "${B}rice doctor${N} — $(date '+%Y-%m-%d %H:%M')"

# ---------------------------------------------------------------- sistema
sec "Sistema"
[[ -f /etc/os-release ]] && { . /etc/os-release; out "  distro:   ${PRETTY_NAME:-?}"; }
out "  kernel:   $(uname -r)"
for p in hyprland waybar kitty rofi fastfetch starship; do
  v="$(ver "$p")"; [[ -n "$v" ]] && out "  pacote:   $v"
done
v="$(ver matugen-bin matugen)"; [[ -n "$v" ]] && out "  pacote:   $v"

# ---------------------------------------------------------------- comandos
sec "Programas"
for c in Hyprland hyprctl waybar kitty fuzzel mako matugen; do
  have "$c" && ok "$c" || fail "$c não encontrado (necessário)"
done
if have awww || have swww; then ok "awww/swww"; else fail "nem awww nem swww encontrados (necessário)"; fi
if have magick || have convert; then ok "imagemagick"; else warn "imagemagick ausente (miniaturas dos wallpapers)"; fi
for c in rofi hyprlock hypridle starship fastfetch eza bat notify-send wpctl brightnessctl playerctl grim slurp wl-copy cliphist; do
  have "$c" && ok "$c" || warn "$c não encontrado"
done
if have fc-list && fc-list | grep -qi 'JetBrainsMono.*Nerd'; then ok "JetBrainsMono Nerd Font"; else warn "JetBrainsMono Nerd Font não encontrada (ícones podem aparecer como quadrados)"; fi

# ---------------------------------------------------------------- links
sec "Configs ligadas (stow)"
if have stow && [[ -d "$REPO/rice" ]]; then
  s="$(cd "$REPO" && stow --no --verbose --target="$HOME" rice 2>&1)"
  if grep -qE 'existing target|conflict' <<<"$s"; then
    fail "o stow encontrou conflitos (veja: cd ~/dotfiles && stow --no --verbose --target=\"\$HOME\" rice)"
  elif grep -q '^LINK:' <<<"$s"; then
    warn "há arquivos do repositório ainda não ligados em ~/.config (rode: stow --target=\"\$HOME\" rice)"
  else
    ok "todos os links do repositório estão íntegros"
  fi
else
  warn "stow ou a pasta rice/ não encontrados: pulei esta checagem"
fi

# ---------------------------------------------------------------- hyprland
sec "Hyprland"
H="$HOME/.config/hypr"
if [[ -e "$H/hyprland.lua" ]]; then
  ok "hyprland.lua presente"
  [[ -L "$H/hyprland.lua" ]] && ok "hyprland.lua é um link para o repositório" || warn "hyprland.lua não é um link (edições não vão para o git)"
else
  fail "hyprland.lua ausente (o Hyprland 0.55+ usa Lua e ignora o hyprland.conf)"
fi
if pgrep -x Hyprland >/dev/null 2>&1 && have hyprctl; then
  e="$(hyprctl configerrors 2>&1)"
  if [[ -z "$(tr -d '[:space:]' <<<"$e")" ]]; then ok "hyprctl configerrors: sem erros"
  else fail "hyprctl configerrors:"; while IFS= read -r l; do out "            $l"; done < <(head -5 <<<"$e"); fi
  for p in waybar mako; do pgrep -x "$p" >/dev/null 2>&1 && ok "$p está rodando" || warn "$p não está rodando"; done
else
  out "  (Hyprland não está rodando: pulei configerrors e os processos)"
fi

# ---------------------------------------------------------------- cores
sec "Cores geradas pelo matugen"
miss=()
for f in hypr/colors.lua hypr/colors.conf waybar/colors.css kitty/colors.conf fuzzel/colors.ini rofi/colors.rasi mako/colors.part; do
  [[ -s "$HOME/.config/$f" ]] || miss+=("$f")
done
if ((${#miss[@]}==0)); then ok "todos os arquivos de cor existem"
else warn "faltando: ${miss[*]} — troque o wallpaper uma vez (wallpaper.sh)"; fi

# ---------------------------------------------------------------- wallpaper
sec "Wallpaper"
W="$HOME/Pictures/Wallpapers"
n=0; [[ -d "$W" ]] && n=$(find "$W" -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) | wc -l)
(( n > 0 )) && ok "$n imagens em ~/Pictures/Wallpapers" || warn "nenhuma imagem em ~/Pictures/Wallpapers"
cw="$(cat "$HOME/.cache/current_wallpaper" 2>/dev/null || true)"
if [[ -n "$cw" && -f "$cw" ]]; then ok "wallpaper atual existe"
else warn "sem wallpaper atual salvo (rode wallpaper.sh com uma imagem)"; fi

# ---------------------------------------------------------------- arquivos de config
sec "Arquivos de configuração"
SE="$H/settings.env"
if [[ -f "$SE" ]]; then
  err="$(bash -c '. "$1"' _ "$SE" 2>&1 >/dev/null)"
  if [[ -n "$err" ]]; then fail "settings.env com erro: $err"
  elif grep -nE '^[A-Z_]+=[^"'\''].* ' "$SE" >/dev/null 2>&1; then warn "settings.env tem valor com espaço sem aspas"
  else ok "settings.env válido"; fi
else
  warn "settings.env não existe (rode menu.sh --init)"
fi
if have python3; then
  while IFS= read -r f; do
    if python3 - "$f" <<'PY' 2>/dev/null
import json, re, sys
raw = open(sys.argv[1], encoding="utf-8").read()
try:
    json.loads(raw)
except json.JSONDecodeError:
    json.loads(re.sub(r"^\s*//.*$", "", raw, flags=re.M))
PY
    then ok "JSON válido: ${f#"$HOME"/}"
    else fail "JSON inválido: ${f#"$HOME"/}"; fi
  done < <(find -L "$HOME/.config/waybar" -maxdepth 3 -name 'config.jsonc' 2>/dev/null)
fi
if [[ -s "$HOME/.cache/fastfetch-build.log.hist" ]]; then
  warn "o fastfetch recusou a config completa: $(tail -1 "$HOME/.cache/fastfetch-build.log.hist")"
fi
LE="$H/settings.local.env"
if [[ -f "$LE" ]]; then
  err="$(bash -c '. "$1"' _ "$LE" 2>&1 >/dev/null)"
  [[ -z "$err" ]] && ok "settings.local.env válido" || fail "settings.local.env com erro: $err"
fi

# ---------------------------------------------------------------- estilos
sec "Estilos e barra"
if [[ -x "$HOME/.config/rice/scripts/style-render.py" ]]; then
  ok "style-render.py executável"
else
  warn "style-render.py ausente ou sem permissão de execução"
fi
ST="${XDG_STATE_HOME:-$HOME/.local/state}/rice"
for f in style.json waybar/config.jsonc waybar/style.css kitty/style.conf fuzzel/overrides.env; do
  [[ -s "$ST/$f" ]] && ok "estado: $f" || warn "estado ausente: $f (rode: menu.sh --init)"
done
rs="$(grep -hE '^RICE_SHELL=' "$H/settings.env" "$LE" 2>/dev/null | tail -1 | cut -d= -f2- | tr -d '"')"
rs="${rs:-waybar}"
if [[ "$rs" = quickshell ]]; then
  have quickshell && ok "RICE_SHELL=quickshell (instalado)" || fail "RICE_SHELL=quickshell, mas quickshell não está instalado"
else
  ok "RICE_SHELL=$rs"
fi
if have python3 && [[ -d "$REPO/rice/.config/rice/styles" ]]; then
  while IFS= read -r f; do
    if python3 -c 'import json,sys; json.load(open(sys.argv[1], encoding="utf-8"))' "$f" 2>/dev/null; then
      ok "manifesto: ${f#"$REPO/rice/.config/rice/styles/"}"
    else
      fail "manifesto inválido: ${f#"$REPO/rice/.config/rice/styles/"}"
    fi
  done < <(find "$REPO/rice/.config/rice/styles" -maxdepth 1 -name '*.json' 2>/dev/null)
fi

# ---------------------------------------------------------------- serviços e git
sec "Serviços e repositório"
if have systemctl; then
  systemctl is-enabled bluetooth.service >/dev/null 2>&1 && ok "bluetooth habilitado" || out "  (bluetooth não habilitado; ignore se você não usa)"
fi
if git -C "$REPO" rev-parse --git-dir >/dev/null 2>&1; then
  out "  branch:   $(git -C "$REPO" rev-parse --abbrev-ref HEAD)"
  d="$(git -C "$REPO" status --porcelain | wc -l)"
  (( d == 0 )) && ok "repositório sem alterações pendentes" || out "  ($d arquivos com alterações ainda não commitadas)"
  lr="$(git -C "$REPO" rev-list --left-right --count '@{u}...HEAD' 2>/dev/null || true)"
  [[ -n "$lr" ]] && out "  atrás/à frente do remoto: $lr"
  hp="$(git -C "$REPO" config core.hooksPath 2>/dev/null || true)"
  [[ -n "$hp" ]] && out "  hooks do git: $hp"
fi

# ---------------------------------------------------------------- resumo
out ""
out "${B}Resumo:${N} $OK ok, $WARN avisos, $FAIL erros"

if (( REPORT )); then
  printf '```\n'; sed "s|$HOME|~|g" "$BUF"; printf '```\n'
fi
(( FAIL == 0 ))
