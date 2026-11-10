#!/usr/bin/env bash
set -euo pipefail
# Monta ~/.config/mako/config a partir do manifesto do estilo atual + cores do Matugen.
exec ~/.config/rice/scripts/style-render.py --mako
