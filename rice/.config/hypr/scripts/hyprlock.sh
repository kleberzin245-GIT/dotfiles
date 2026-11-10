#!/usr/bin/env bash
set -euo pipefail
# Abre o Hyprlock com o layout do estilo atual; cai no hyprlock.conf padrão se faltar.
STYLE=${XDG_STATE_HOME:-$HOME/.local/state}/rice/hyprlock/style.conf
if [ -f "$STYLE" ]; then
  exec hyprlock --config "$STYLE"
fi
exec hyprlock
