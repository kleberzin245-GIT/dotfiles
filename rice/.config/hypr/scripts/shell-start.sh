#!/usr/bin/env bash
set -euo pipefail
# Inicia a barra escolhida em RICE_SHELL (waybar por padrão).
# Uso: shell-start.sh [--restart]
#   --restart  encerra a barra atual antes de iniciar (usado ao trocar de estilo)

H=~/.config/hypr
STATE=${XDG_STATE_HOME:-$HOME/.local/state}/rice
RENDER=~/.config/rice/scripts/style-render.py

# shellcheck disable=SC1091
[ -f "$H/settings.env" ] && . "$H/settings.env"
# shellcheck disable=SC1091
[ -f "$H/settings.local.env" ] && . "$H/settings.local.env"

if [ "${1:-}" = "--restart" ]; then
  pkill -x waybar 2>/dev/null || true
  pkill -x quickshell 2>/dev/null || true
  sleep 0.4
fi

# Primeira execução depois de atualizar: gera os arquivos de estilo.
if [ ! -f "$STATE/waybar/config.jsonc" ] && [ -x "$RENDER" ]; then
  "$RENDER" --all --quiet >/dev/null 2>&1 || true
fi

case "${RICE_SHELL:-waybar}" in
  waybar)
    if [ -f "$STATE/waybar/config.jsonc" ] && [ -f "$STATE/waybar/style.css" ]; then
      exec waybar -c "$STATE/waybar/config.jsonc" -s "$STATE/waybar/style.css"
    fi
    exec waybar
    ;;
  quickshell)
    if command -v quickshell >/dev/null 2>&1; then
      exec quickshell -p "$HOME/.config/quickshell"
    fi
    echo "shell-start: quickshell não instalado; usando waybar." >&2
    exec waybar
    ;;
  *)
    echo "shell-start: RICE_SHELL inválido: ${RICE_SHELL}" >&2
    exit 1
    ;;
esac
