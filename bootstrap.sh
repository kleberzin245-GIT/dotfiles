#!/usr/bin/env bash
# Restaura o rice numa máquina nova (Arch/CachyOS/EndeavourOS).
set -Eeuo pipefail

DRY_RUN=0
MINIMAL=0
NO_BLUETOOTH=0
NO_AUR=0

die() { echo "ERRO: $*" >&2; exit 1; }

run() {
  if [ "$DRY_RUN" -eq 1 ]; then
    printf '+ '
    printf '%q ' "$@"
    echo
  else
    "$@"
  fi
}

usage() {
  cat <<'EOF'
Uso: bootstrap.sh [OPÇÕES]

Instala os pacotes (Arch/CachyOS/EndeavourOS), liga as configs com stow e
gera o estado inicial do rice. Pode ser executado mais de uma vez.

Opções:
  --dry-run        mostra o que seria feito, sem alterar o sistema
  --minimal        instala só o essencial (sem bluetooth, btop e nwg-look)
  --no-bluetooth   não instala nem ativa os pacotes de bluetooth
  --no-aur         não instala matugen/awww pelo AUR (você já os tem)
  -h, --help       mostra esta ajuda
EOF
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    -h|--help) usage; exit 0 ;;
    --dry-run) DRY_RUN=1 ;;
    --minimal) MINIMAL=1 ;;
    --no-bluetooth) NO_BLUETOOTH=1 ;;
    --no-aur) NO_AUR=1 ;;
    *) die "opção desconhecida: $1 (use --help)" ;;
  esac
  shift
done

command -v pacman >/dev/null 2>&1 || die "pacman não encontrado (este instalador é para Arch e derivados)."
command -v sudo   >/dev/null 2>&1 || die "sudo não encontrado. Instale-o antes de continuar."
[[ $EUID -ne 0 ]] || die "não execute como root. Use o seu usuário normal."

echo "==> Sistema detectado: Arch Linux (ou derivado)."
[ "$DRY_RUN" -eq 1 ] && echo "==> Modo secagem (--dry-run): nada será alterado."

cd "$(dirname "$0")"

# Ativa o hook de proteção contra dados sensíveis (se ainda não estiver ativo).
if [ -d .git ] && [ -f hooks/pre-commit ]; then
  run chmod +x hooks/pre-commit
  run git config core.hooksPath hooks
fi

BASE_PKGS=(
  git stow base-devel
  hyprland hyprlock hypridle hyprpolkitagent xdg-desktop-portal-hyprland
  waybar kitty fuzzel mako libnotify
  pipewire wireplumber pipewire-pulse pavucontrol brightnessctl playerctl
  grim slurp wl-clipboard cliphist
  ttf-jetbrains-mono-nerd papirus-icon-theme adw-gtk-theme
  rofi imagemagick starship fastfetch eza bat less python3
)
OPTIONAL_PKGS=(bluez bluez-utils bluetui btop nwg-look)

PKGS=("${BASE_PKGS[@]}")
if [ "$MINIMAL" -eq 0 ]; then
  PKGS+=("${OPTIONAL_PKGS[@]}")
fi
if [ "$NO_BLUETOOTH" -eq 1 ]; then
  filtered=()
  for p in "${PKGS[@]}"; do
    case "$p" in bluez|bluez-utils|bluetui) ;; *) filtered+=("$p") ;; esac
  done
  PKGS=("${filtered[@]}")
fi

echo "==> Pacotes oficiais"
run sudo pacman -S --needed --noconfirm "${PKGS[@]}"

if [ "$NO_BLUETOOTH" -eq 0 ] && [ "$MINIMAL" -eq 0 ] && command -v bluetoothctl >/dev/null 2>&1; then
  run sudo systemctl enable --now bluetooth.service || echo "AVISO: não consegui ativar o bluetooth (sem adaptador?)."
else
  echo "==> Bluetooth não será ativado (--minimal/--no-bluetooth ou sem suporte)."
fi

if [ "$NO_AUR" -eq 1 ]; then
  echo "==> AUR ignorado (--no-aur)."
elif [ "$DRY_RUN" -eq 1 ]; then
  echo "==> AUR (matugen + awww/swww) seria instalado agora."
else
  echo "==> AUR (matugen + awww/swww)"
  if command -v paru >/dev/null 2>&1; then
    AUR=paru
  elif command -v yay >/dev/null 2>&1; then
    AUR=yay
  else
    echo "Nenhum helper AUR encontrado. Instalando yay-bin..."
    BUILD_DIR="$(mktemp -d)"
    trap 'rm -rf -- "$BUILD_DIR"' EXIT
    git clone https://aur.archlinux.org/yay-bin.git "$BUILD_DIR/yay-bin"
    (cd "$BUILD_DIR/yay-bin" && makepkg -si --noconfirm)
    command -v yay >/dev/null 2>&1 || die "não foi possível instalar o yay."
    AUR=yay
  fi

  "$AUR" -S --needed --noconfirm matugen-bin
  if ! "$AUR" -S --needed --noconfirm awww; then
    echo "awww não pôde ser instalado. Tentando swww..."
    "$AUR" -S --needed --noconfirm swww
  fi
fi

echo "==> Ligando as configs (stow)"
# Num PC novo o Hyprland/Kitty já podem ter criado configs padrão no mesmo lugar.
# Em vez de apagar ou sobrescrever, mandamos os arquivos que conflitam para um backup.
backup_conflicts() {
  local out dest target
  command -v stow >/dev/null 2>&1 || return 0
  out="$(stow --no --no-folding --target="$HOME" rice 2>&1)" || true
  dest="$HOME/.config-backup-rice-$(date +%Y%m%d-%H%M%S)"
  while IFS= read -r target; do
    [[ -n "$target" ]] || continue
    [[ -e "$HOME/$target" || -L "$HOME/$target" ]] || continue
    if [ "$DRY_RUN" -eq 1 ]; then
      echo "   [dry-run] backup: ~/$target -> $dest/$target"
      continue
    fi
    mkdir -p "$dest/$(dirname "$target")"
    mv -- "$HOME/$target" "$dest/$target"
    echo "   backup: ~/$target -> $dest/$target"
  done < <(sed -nE 's/^.*existing target (is neither a link nor a directory|is not owned by stow):[[:space:]]*(.*)$/\2/p' <<<"$out")
}
backup_conflicts
if [ "$DRY_RUN" -eq 1 ]; then
  run stow --restow --no-folding --target="$HOME" rice
else
  stow --restow --no-folding --target="$HOME" rice || die "o stow ainda encontrou conflitos. Rode: stow --no --no-folding --verbose --target=\"\$HOME\" rice"
fi

# starship.toml e fastfetch/config.jsonc são regenerados pelo matugen e pelo
# fastfetch-build (por isso ficam fora do stow); instala o default se faltar.
if [ "$DRY_RUN" -eq 0 ]; then
  for f in starship.toml fastfetch/config.jsonc; do
    [[ -L "$HOME/.config/$f" ]] && rm "$HOME/.config/$f"
    if [[ ! -e "$HOME/.config/$f" ]]; then
      install -Dm644 "rice/.config/$f" "$HOME/.config/$f"
      echo "   default: ~/.config/$f"
    fi
  done
fi

run mkdir -p "$HOME/Pictures/Wallpapers"

if [ "$DRY_RUN" -eq 0 ] && [[ -f "$HOME/.config/shell/rice.sh" ]]; then
  # shellcheck disable=SC2016
  RICE_LINE='[ -f "$HOME/.config/shell/rice.sh" ] && . "$HOME/.config/shell/rice.sh"'
  touch "$HOME/.bashrc"
  if ! grep -qF 'shell/rice.sh' "$HOME/.bashrc"; then
    printf '\n%s\n' "$RICE_LINE" >> "$HOME/.bashrc"
  fi
  # A linha funciona no zsh também; só adiciona se o zsh estiver instalado.
  if command -v zsh >/dev/null 2>&1; then
    touch "$HOME/.zshrc"
    if ! grep -qF 'shell/rice.sh' "$HOME/.zshrc"; then
      printf '\n%s\n' "$RICE_LINE" >> "$HOME/.zshrc"
    fi
  fi
fi

if [ "$DRY_RUN" -eq 0 ]; then
  if [[ -d "$HOME/.config/hypr/scripts" ]]; then
    find -L "$HOME/.config/hypr/scripts" -maxdepth 1 -type f -name '*.sh' -exec chmod +x {} +
  else
    echo "AVISO: diretório de scripts do Hyprland não encontrado."
  fi
  if [[ -f "$HOME/.config/rice/scripts/style-render.py" ]]; then
    chmod +x "$HOME/.config/rice/scripts/style-render.py"
  fi
  if [[ -x "$HOME/.config/hypr/scripts/menu.sh" ]]; then
    "$HOME/.config/hypr/scripts/menu.sh" --init \
      || echo "AVISO: não consegui gerar o estado inicial (rode: menu.sh --init)."
  else
    echo "AVISO: menu.sh não encontrado; o estado inicial não foi gerado."
  fi
fi

check_hyprland_version() {
  local raw ver major minor
  raw=$( { hyprctl version 2>/dev/null || pacman -Q hyprland 2>/dev/null; } | head -1 )
  [ -n "$raw" ] || return 0
  ver=$(grep -oE '[0-9]+\.[0-9]+' <<<"$raw" | head -1 || true)
  [ -n "$ver" ] || return 0
  major=${ver%%.*}
  minor=${ver#*.}
  if [ "$major" -eq 0 ] && [ "$minor" -lt 55 ]; then
    echo "AVISO: Hyprland $ver detectado; este rice usa a configuração em Lua (0.55+)." >&2
    echo "       Atualize o Hyprland ou use uma versão anterior do repositório." >&2
  else
    echo "==> Hyprland $ver (configuração em Lua OK)."
  fi
}

check_hyprland_version

# Verifica se os binários essenciais estão instalados
check_deps() {
  local cmd missing=0
  for cmd in git stow bash python3 hyprctl hyprlock hypridle hyprpolkitagent xdg-desktop-portal-hyprland waybar kitty fuzzel mako matugen rofi brightnessctl playerctl starship eza bat fastfetch; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
      echo "AVISO: '$cmd' não encontrado. Pode estar faltando." >&2
      missing=1
    fi
  done
  if ! command -v magick >/dev/null 2>&1 && ! command -v convert >/dev/null 2>&1; then
    echo "AVISO: imagemagick (magick/convert) não encontrado." >&2
    missing=1
  fi
  if ! command -v awww >/dev/null 2>&1 && ! command -v swww >/dev/null 2>&1; then
    echo "AVISO: engine de wallpaper (awww/swww) não encontrado." >&2
    missing=1
  fi
  if [ "$missing" -eq 1 ]; then
    echo "Verifique a lista de dependências em docs/installation.md." >&2
  else
    echo "Dependências essenciais presentes."
  fi
  return 0
}

check_deps

echo
echo "Pronto! Agora:"
echo "  1) Coloque wallpapers em ~/Pictures/Wallpapers"
echo "  2) ~/.config/hypr/scripts/wallpaper.sh ~/Pictures/Wallpapers/SUA_IMAGEM.png"
echo "  3) Faça logout e login"
