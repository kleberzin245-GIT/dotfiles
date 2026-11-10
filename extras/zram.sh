#!/usr/bin/env bash
# Ativa zram (swap comprimido na RAM). Ajuda bastante em PCs com pouca memória (4 GB ou menos).
# Uso:  extras/zram.sh           ativa
#       extras/zram.sh --undo    desfaz
# Opcional: o bootstrap NÃO roda isto sozinho, porque mexe em /etc.
set -Eeuo pipefail

ROOT="${ZRAM_ROOT:-}"     # só para testes; deixe vazio no uso normal
die() { echo "ERRO: $*" >&2; exit 1; }

[[ $EUID -ne 0 ]] || die "não rode como root; o script usa sudo quando precisa."
command -v pacman >/dev/null 2>&1 || die "pacman não encontrado (Arch e derivados)."
command -v sudo   >/dev/null 2>&1 || die "sudo não encontrado."

CONF="$ROOT/etc/systemd/zram-generator.conf"
SYSCTL="$ROOT/etc/sysctl.d/99-zram.conf"

if [[ "${1:-}" == "--undo" ]]; then
  sudo systemctl stop systemd-zram-setup@zram0.service 2>/dev/null || true
  sudo rm -f "$CONF" "$SYSCTL"
  sudo systemctl daemon-reload || true
  echo "zram desativado e configs removidas (o pacote zram-generator continua instalado)."
  exit 0
fi

if command -v zramctl >/dev/null 2>&1 && [[ -n "$(zramctl --noheadings 2>/dev/null)" ]]; then
  echo "Já existe um dispositivo zram ativo:"; zramctl; swapon --show
  echo "Nada a fazer."; exit 0
fi

mem_mb=$(awk '/MemTotal/ {printf "%d", $2/1024}' /proc/meminfo)
echo "Memória: ${mem_mb} MiB"
if (( mem_mb > 12000 )); then
  echo "AVISO: com bastante RAM o ganho do zram é pequeno. Continuando mesmo assim."
fi

echo "==> Instalando zram-generator"
sudo pacman -S --needed --noconfirm zram-generator

echo "==> Escrevendo $CONF"
sudo mkdir -p "$(dirname "$CONF")" "$(dirname "$SYSCTL")"
sudo tee "$CONF" >/dev/null <<'EOT'
[zram0]
zram-size = min(ram, 4096)
compression-algorithm = zstd
swap-priority = 100
fs-type = swap
EOT

echo "==> Escrevendo $SYSCTL"
sudo tee "$SYSCTL" >/dev/null <<'EOT'
# zram é rápido: vale preferir trocar páginas por ele a descartar cache
vm.swappiness = 180
vm.page-cluster = 0
EOT

echo "==> Ativando"
sudo systemctl daemon-reload
sudo systemctl start systemd-zram-setup@zram0.service
sudo sysctl --system >/dev/null

echo
zramctl || true
swapon --show || true
echo "Pronto. Para desfazer: extras/zram.sh --undo"
