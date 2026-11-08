#!/usr/bin/env bash
# Entrada única para instalar o rice.
# Dá o mesmo resultado que rodar ./bootstrap.sh, mas de forma mais enxuta.
# Ex: ./install.sh   ou   ./install.sh --help
cd "$(dirname "$0")"
exec ./bootstrap.sh "$@"
