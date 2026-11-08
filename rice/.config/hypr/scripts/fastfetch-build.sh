#!/usr/bin/env bash
set -euo pipefail
# Monta ~/.config/fastfetch/{config.jsonc,logo.txt} com as cores do matugen.
# Cores: usa fastfetch/colors.env (matugen); se não existir, lê do kitty/colors.conf (também do matugen).
CFGDIR=~/.config/fastfetch
CFG=$CFGDIR/config.jsonc
LOGO=$CFGDIR/logo.txt
ENV=$CFGDIR/colors.env
KC=~/.config/kitty/colors.conf
CAND=~/.cache/fastfetch-candidate.jsonc
ERRF=~/.cache/fastfetch-build.log
mkdir -p "$CFGDIR" ~/.cache

if [ -f "$ENV" ]; then
  # shellcheck disable=SC1090
  . "$ENV"
elif [ -f "$KC" ]; then
  kget() { awk -v k="$1" '$1==k {sub(/^#/,"",$2); print $2}' "$KC"; }
  PRIMARY=$(kget color4); SECONDARY=$(kget color3); TERTIARY=$(kget color2)
  OUTLINE=$(kget color8); ON_SURFACE=$(kget foreground)
fi
PRIMARY=${PRIMARY:-a8c8ff}; SECONDARY=${SECONDARY:-bbc7db}; TERTIARY=${TERTIARY:-d6bee5}
OUTLINE=${OUTLINE:-8e9099}; ON_SURFACE=${ON_SURFACE:-e0e2e8}

dec() { printf '%d' "0x$1"; }
rgb() { printf '38;2;%d;%d;%d' "0x${1:0:2}" "0x${1:2:2}" "0x${1:4:2}"; }
# mistura a->b no passo i de n, devolvendo "38;2;r;g;b"
mix() {
  local a=$1 b=$2 i=$3 n=$4 off x y out=""
  for off in 0 2 4; do
    x=$(dec "${a:$off:2}"); y=$(dec "${b:$off:2}")
    out+="$(( (x*(n-i) + y*i) / n ));"
  done
  printf '38;2;%s' "${out%;}"
}

P=$(rgb "$PRIMARY"); S=$(rgb "$SECONDARY"); O=$(rgb "$OUTLINE"); F=$(rgb "$ON_SURFACE")
C1=$(mix "$PRIMARY" "$TERTIARY" 0 4); C2=$(mix "$PRIMARY" "$TERTIARY" 1 4); C3=$(mix "$PRIMARY" "$TERTIARY" 2 4)
C4=$(mix "$PRIMARY" "$TERTIARY" 3 4); C5=$(mix "$PRIMARY" "$TERTIARY" 4 4)

# ---- logo do Arch em blocos ($1..$5 = faixas do gradiente) ----
cat > "$LOGO" <<'EOLOGO'
$1                    ██
$1                  ██████
$1                  ██████
$1                ██████████
$2                ██████████
$2              ██████████████
$2            ████████  ████████
$3            ████████  ████████
$3          ████████      ████████
$3        ████████████  ████████████
$3        ██████████      ██████████
$4      ████████████      ████████████
$4    ████████████          ████████████
$4    ██████████              ██████████
$5  ████████████              ████████████
$5████████████                  ████████████
$5████████████                  ████████████
EOLOGO

write_full() {
  local MEM="" DSK="" BAT=""
  if [ "$1" = rich ]; then
    MEM=', "percent": { "type": ["bar", "num"] }, "format": "{percentage-bar} {used} / {total} ({percentage})"'
    DSK=', "percent": { "type": ["bar", "num"] }, "format": "{size-percentage-bar} {size-used} / {size-total} · {filesystem}"'
    BAT=', "percent": { "type": ["bar", "num"], "green": 30, "yellow": 15 }, "format": "{capacity-bar} {capacity}"'
  fi
cat <<EOT
{
  "\$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",
  "logo": {
    "type": "file",
    "source": "$LOGO",
    "padding": { "top": 1, "left": 2, "right": 4 },
    "color": { "1": "$C1", "2": "$C2", "3": "$C3", "4": "$C4", "5": "$C5" }
  },
  "display": {
    "key": { "width": 15 },
    "separator": "  ",
    "percent": { "type": ["num"] },
    "bar": {
      "char": { "elapsed": "━", "total": "━" },
      "border": { "left": "", "right": "", "leftElapsed": "", "rightElapsed": "" },
      "color": { "elapsed": "$P", "total": "$O" },
      "width": 12
    },
    "color": { "keys": "$P", "title": "$S", "separator": "$O", "output": "$F" }
  },
  "modules": [
    "title",
    { "type": "separator", "string": "─" },
    { "type": "os",       "key": "\uf303  Sistema" },
    { "type": "kernel",   "key": "\uf17c  Kernel" },
    { "type": "uptime",   "key": "\uf017  Uptime" },
    { "type": "packages", "key": "\uf487  Pacotes" },
    { "type": "shell",    "key": "\uf489  Shell" },
    { "type": "wm",       "key": "\uf2d0  WM" },
    { "type": "terminal", "key": "\uf120  Terminal" },
    "break",
    { "type": "cpu",      "key": "\uf2db  CPU" },
    { "type": "gpu",      "key": "\uf108  GPU" },
    { "type": "memory",   "key": "\udb80\udf5b  RAM"$MEM },
    { "type": "disk",     "key": "\uf0a0  Disco", "folders": "/"$DSK },
    { "type": "battery",  "key": "\uf240  Bateria"$BAT },
    "break",
    { "type": "colors" }
  ]
}
EOT
}

# versão simples: só cores e logo padrão (usada se a completa não passar na validação)
write_safe() {
cat <<EOT
{
  "display": { "color": { "keys": "$P", "title": "$S", "separator": "$O" } },
  "modules": ["title", "separator", "os", "kernel", "uptime", "packages", "shell", "wm", "terminal", "cpu", "gpu", "memory", "disk", "battery", "break", "colors"]
}
EOT
}

# 0 = ok | 1 = fastfetch recusou | 2 = sobrou {placeholder} sem resolver na saída
try_config() {
  write_full "$1" > "$CAND"
  command -v fastfetch >/dev/null 2>&1 || return 0
  OUT=$(fastfetch -c "$CAND" 2>"$ERRF"); rc=$?
  [ "$rc" -eq 0 ] || return 1
  grep -qiE 'error|invalid|unknown|unrecogni[sz]ed' "$ERRF" && return 1
  printf '%s' "$OUT" | grep -qE '\{[a-z][a-z0-9-]*\}' && return 2
  return 0
}

try_config rich; r=$?
if [ "$r" -eq 2 ]; then
  echo "--- $(date): placeholders sem resolver nesta versão; usando os formatos padrão" >> "$ERRF.hist"
  try_config plain; r=$?
fi
if [ "$r" -ne 0 ]; then
  { echo "--- $(date) r=$r: config recusada pelo fastfetch, usando a versão simples"; cat "$ERRF"; } >> "$ERRF.hist"
  write_safe > "$CFG"
  echo "fastfetch-build: config recusada; usei a simples (detalhes em $ERRF.hist)" >&2
  exit 0
fi
cp "$CAND" "$CFG"
