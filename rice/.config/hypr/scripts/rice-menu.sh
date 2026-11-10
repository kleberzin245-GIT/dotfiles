#!/usr/bin/env bash
set -euo pipefail
# Abre o painel principal do rice.
#   RICE_SHELL=quickshell -> alterna a Central de Controle (via IPC)
#   caso contrário        -> menu de controle em Fuzzel (SUPER+M)
# Se o Quickshell não estiver rodando (ou o IPC falhar), cai no Fuzzel.

H="$HOME/.config/hypr"

# shellcheck disable=SC1091
[ -f "$H/settings.env" ] && . "$H/settings.env"
# shellcheck disable=SC1091
[ -f "$H/settings.local.env" ] && . "$H/settings.local.env"

if [ "${RICE_SHELL:-waybar}" = "quickshell" ] && command -v quickshell >/dev/null 2>&1; then
  if quickshell ipc -p "$HOME/.config/quickshell" call rice toggleControlCenter >/dev/null 2>&1; then
    exit 0
  fi
fi

exec "$H/scripts/menu.sh"
