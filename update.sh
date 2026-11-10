#!/usr/bin/env bash
# Atualiza o repositório e reaplica as configs nos lugares certos.
set -Eeuo pipefail

cd "$(dirname "$(readlink -f "$0")")" || exit 1

DRY_RUN=0
RUN_DOCTOR=1

usage() {
  cat <<'EOF'
Uso: update.sh [OPÇÕES]

  (sem opção)   git pull --ff-only + stow --restow + menu.sh --init + doctor.sh
  --dry-run     mostra os comandos sem alterar nada
  --no-doctor   não roda o doctor.sh no final
  -h, --help    mostra esta ajuda
EOF
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --dry-run) DRY_RUN=1 ;;
    --no-doctor) RUN_DOCTOR=0 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "ERRO: opção desconhecida: $1" >&2; usage >&2; exit 2 ;;
  esac
  shift
done

run() {
  if [ "$DRY_RUN" -eq 1 ]; then
    printf '+ '
    printf '%q ' "$@"
    echo
  else
    "$@"
  fi
}

command -v git >/dev/null 2>&1 || { echo "ERRO: git não encontrado." >&2; exit 1; }
command -v stow >/dev/null 2>&1 || { echo "ERRO: stow não encontrado." >&2; exit 1; }

echo "==> Atualizando o repositório"
if [ "$DRY_RUN" -eq 1 ]; then
  run git pull --ff-only
else
  # Evita perder alterações locais não commitadas.
  if [ -n "$(git status --porcelain)" ]; then
    echo "ERRO: há alterações locais não commitadas. Rode ./dotsave ou faça stash antes." >&2
    git status --short >&2
    exit 1
  fi
  git pull --ff-only
fi

echo "==> Reaplicando as configs (stow --restow)"
if [ "$DRY_RUN" -eq 1 ]; then
  run stow --restow --no-folding --target="$HOME" rice
else
  stow --restow --no-folding --target="$HOME" rice
fi

echo "==> Regerando o estado inicial"
if [ "$DRY_RUN" -eq 1 ]; then
  run "$HOME/.config/hypr/scripts/menu.sh" --init
else
  "$HOME/.config/hypr/scripts/menu.sh" --init
fi

if [ "$RUN_DOCTOR" -eq 1 ]; then
  echo "==> Diagnóstico"
  run ./doctor.sh
fi

echo
echo "Pronto. Se algo visual não atualizou, faça logout e login."
