#!/usr/bin/env bash
# Remove os links criados pelo stow. Não apaga arquivos que não sejam links.
set -Eeuo pipefail

cd "$(dirname "$(readlink -f "$0")")" || exit 1

DRY_RUN=0
REMOVE_STATE=0

usage() {
  cat <<'EOF'
Uso: uninstall.sh [OPÇÕES]

  (sem opção)       remove os links de ~/.config criados pelo stow
  --dry-run         mostra o que seria removido, sem alterar nada
  --remove-state    também apaga o estado do rice (~/.local/state/rice)
  -h, --help        mostra esta ajuda

Os arquivos reais que já existiam antes da instalação continuam intactos.
Backups feitos pelo bootstrap ficam em ~/.config-backup-rice-*.
EOF
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --dry-run) DRY_RUN=1 ;;
    --remove-state) REMOVE_STATE=1 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "ERRO: opção desconhecida: $1" >&2; usage >&2; exit 2 ;;
  esac
  shift
done

command -v stow >/dev/null 2>&1 || { echo "ERRO: stow não encontrado." >&2; exit 1; }

echo "==> Removendo os links do stow"
if [ "$DRY_RUN" -eq 1 ]; then
  stow --no --delete --no-folding --verbose --target="$HOME" rice
else
  stow --delete --no-folding --target="$HOME" rice
fi

if [ "$REMOVE_STATE" -eq 1 ]; then
  STATE="${XDG_STATE_HOME:-$HOME/.local/state}/rice"
  echo "==> Removendo o estado do rice ($STATE)"
  if [ "$DRY_RUN" -eq 1 ]; then
    echo "+ rm -rf -- $STATE"
  else
    rm -rf -- "$STATE"
  fi
fi

echo
echo "Pronto. Seus arquivos pessoais e os backups em ~/.config-backup-rice-* foram mantidos."
