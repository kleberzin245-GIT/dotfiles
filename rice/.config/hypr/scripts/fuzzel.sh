#!/usr/bin/env bash
set -euo pipefail
# Abre o Fuzzel com os ajustes do estilo atual (borda/raio), sem alterar o fuzzel.ini.
OVERRIDES=${XDG_STATE_HOME:-$HOME/.local/state}/rice/fuzzel/overrides.env
args=()
if [ -f "$OVERRIDES" ]; then
  # shellcheck disable=SC1090
  . "$OVERRIDES"
  args+=(--override="border.width=${FUZZEL_BORDER_WIDTH:-2}")
  args+=(--override="border.radius=${FUZZEL_BORDER_RADIUS:-16}")
fi
exec fuzzel "${args[@]}" "$@"
