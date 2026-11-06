#!/usr/bin/env bash
# Menu de controle do rice (Fuzzel). Abre com SUPER+M ou pelo botão da Waybar.
H=~/.config/hypr
CFG=$H/settings.env
mkdir -p ~/.cache

if [ ! -f "$CFG" ]; then
cat > "$CFG" <<EOT
GAPS=Médio
ROUNDING=12
BORDER=Branca
BLUR=Leve
INACTIVE=0.94
WOBBLE=Wobbly
WAYBAR_OP=0.5
KITTY_OP=0.5
EOT
fi
# shellcheck disable=SC1090
source "$CFG"

save() {
  if grep -q "^$1=" "$CFG"; then sed -i --follow-symlinks "s|^$1=.*|$1=$2|" "$CFG"; else echo "$1=$2" >> "$CFG"; fi
  source "$CFG"
}

gen_lua() {
  case "$GAPS" in
    "Sem gaps") GI=0; GO=0 ;;
    "Pequeno")  GI=3; GO=6 ;;
    "Grande")   GI=8; GO=20 ;;
    *)          GI=5; GO=12 ;;
  esac
  case "$BLUR" in
    "Desligado") BE=false; BS=4; BP=2 ;;
    "Médio")     BE=true;  BS=6; BP=3 ;;
    "Forte")     BE=true;  BS=9; BP=4 ;;
    *)           BE=true;  BS=4; BP=2 ;;
  esac
  case "$BORDER" in
    "Dinâmica")   ACTIVE='{ colors = { c.primary, c.tertiary }, angle = 45 }'; BSZ=2 ;;
    "Sem borda")  ACTIVE='"rgba(ffffffff)"'; BSZ=0 ;;
    *)            ACTIVE='"rgba(ffffffff)"'; BSZ=2 ;;
  esac
  case "$WOBBLE" in
    "Suave")   ST=190; DP=16; SPRING=1 ;;
    "Extrema") ST=240; DP=5;  SPRING=1 ;;
    "Desligada") ST=210; DP=10; SPRING=0 ;;
    *)         ST=210; DP=10; SPRING=1 ;;
  esac
  ST2=$((ST - 40)); DP2=$((DP + 4))

  {
  cat <<EOT
-- GERADO pelo menu de controle (SUPER+M). Não edite à mão.
local ok, c = pcall(require, "colors")
if not ok then
    c = { primary = "rgba(cba6f7ff)", tertiary = "rgba(89b4faff)", outline_variant = "rgba(595959aa)" }
end

hl.config({
    general = {
        gaps_in = $GI,
        gaps_out = $GO,
        border_size = $BSZ,
        col = {
            active_border   = $ACTIVE,
            inactive_border = c.outline_variant,
        },
    },
    decoration = {
        rounding = $ROUNDING,
        inactive_opacity = $INACTIVE,
        blur = { enabled = $BE, size = $BS, passes = $BP },
    },
})

hl.curve("smooth", { type = "bezier", points = { {0.05, 0.9}, {0.1, 1.05} } })
hl.curve("snappy", { type = "bezier", points = { {0.16, 1},   {0.3, 1}    } })
EOT
  if [ "$SPRING" = 1 ]; then
  cat <<EOT

hl.curve("jelly",     { type = "spring", mass = 1, stiffness = $ST,  damping = $DP })
hl.curve("jellySoft", { type = "spring", mass = 1, stiffness = $ST2, damping = $DP2 })

hl.animation({ leaf = "windows",     enabled = true, speed = 5, spring = "jelly" })
hl.animation({ leaf = "windowsIn",   enabled = true, speed = 5, spring = "jelly", style = "popin 55%" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 5, spring = "jelly" })
hl.animation({ leaf = "windowsOut",  enabled = true, speed = 3, bezier = "snappy", style = "popin 70%" })
hl.animation({ leaf = "layersIn",    enabled = true, speed = 5, spring = "jellySoft", style = "popin 60%" })
hl.animation({ leaf = "layersOut",   enabled = true, speed = 3, bezier = "snappy",    style = "popin 70%" })
hl.animation({ leaf = "workspaces",  enabled = true, speed = 6, spring = "jellySoft", style = "slidevert" })
EOT
  else
  cat <<EOT

hl.animation({ leaf = "windows",     enabled = true, speed = 4, bezier = "smooth" })
hl.animation({ leaf = "windowsIn",   enabled = true, speed = 4, bezier = "smooth", style = "popin 90%" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 4, bezier = "smooth" })
hl.animation({ leaf = "windowsOut",  enabled = true, speed = 3, bezier = "snappy", style = "popin 90%" })
hl.animation({ leaf = "layersIn",    enabled = true, speed = 4, bezier = "smooth", style = "fade" })
hl.animation({ leaf = "layersOut",   enabled = true, speed = 3, bezier = "snappy", style = "fade" })
hl.animation({ leaf = "workspaces",  enabled = true, speed = 5, bezier = "smooth", style = "slidevert" })
EOT
  fi
  } > "$H/settings.lua"
}

apply_hypr() { gen_lua; hyprctl reload >/dev/null 2>&1; }

if [ "$1" = "--init" ]; then gen_lua; exit 0; fi

# --- helpers de menu ---
fz() { fuzzel --dmenu --prompt "$1  " --lines "${2:-8}" --width 30; }

# pick "Título" "valor-atual" op1 op2 ...  (marca o atual com ●)
pick() {
  local title="$1" cur="$2" out="" o; shift 2
  for o in "$@"; do
    if [ "$o" = "$cur" ]; then out+="● $o\n"; else out+="  $o\n"; fi
  done
  printf '%b' "$out" | fz "$title" "$#" | sed 's/^● //; s/^  //'
}

regen_theme() {
  local wp; wp="$(cat ~/.cache/current_wallpaper 2>/dev/null)"
  [ -f "$wp" ] && ~/.config/hypr/scripts/wallpaper.sh "$wp"
}

menu_wallpaper() {
  local dir=~/Pictures/Wallpapers
  local sel
  sel=$( { echo "Aleatório"; find "$dir" -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) -printf '%f\n' | sort; } | fz "Wallpaper" 10)
  [ -z "$sel" ] && return
  if [ "$sel" = "Aleatório" ]; then ~/.config/hypr/scripts/wallpaper.sh
  else ~/.config/hypr/scripts/wallpaper.sh "$dir/$sel"; fi
}

menu_tema() {
  local mode idx sel
  mode="$(cat ~/.cache/matugen_mode 2>/dev/null || echo dark)"
  idx="$(cat ~/.cache/matugen_index 2>/dev/null || echo 0)"
  sel=$(printf '%s\n' "Modo: escuro" "Modo: claro" "Cor base: 1" "Cor base: 2" "Cor base: 3" "Cor base: 4" | fz "Tema" 6)
  case "$sel" in
    "Modo: escuro") echo dark  > ~/.cache/matugen_mode; regen_theme ;;
    "Modo: claro")  echo light > ~/.cache/matugen_mode; regen_theme ;;
    "Cor base: "*)  echo $(( ${sel##* } - 1 )) > ~/.cache/matugen_index; regen_theme ;;
  esac
}

menu_janelas() {
  local sel v
  sel=$(printf '%s\n' "Espaçamento (gaps)" "Arredondamento" "Borda" "Opacidade das inativas" | fz "Janelas" 4)
  case "$sel" in
    "Espaçamento (gaps)")
      v=$(pick "Gaps" "$GAPS" "Sem gaps" "Pequeno" "Médio" "Grande"); [ -n "$v" ] && { save GAPS "$v"; apply_hypr; } ;;
    "Arredondamento")
      v=$(pick "Arredondamento" "$ROUNDING" 0 6 12 20); [ -n "$v" ] && { save ROUNDING "$v"; apply_hypr; } ;;
    "Borda")
      v=$(pick "Borda" "$BORDER" "Branca" "Dinâmica" "Sem borda"); [ -n "$v" ] && { save BORDER "$v"; apply_hypr; } ;;
    "Opacidade das inativas")
      v=$(pick "Inativas" "$INACTIVE" 1.0 0.94 0.85 0.7); [ -n "$v" ] && { save INACTIVE "$v"; apply_hypr; } ;;
  esac
}

menu_blur() {
  local v; v=$(pick "Blur" "$BLUR" "Desligado" "Leve" "Médio" "Forte")
  [ -n "$v" ] && { save BLUR "$v"; apply_hypr; }
}

menu_transp() {
  local sel v
  sel=$(printf '%s\n' "Waybar" "Kitty" | fz "Transparência" 2)
  case "$sel" in
    "Waybar")
      v=$(pick "Waybar" "$WAYBAR_OP" 1.0 0.8 0.5 0.3)
      [ -n "$v" ] && { save WAYBAR_OP "$v"
        sed -i --follow-symlinks -E "s/(background-color: alpha\(@surface, )[0-9.]+\)/\1$v)/" ~/.config/waybar/style.css
        pkill -SIGUSR2 waybar; } ;;
    "Kitty")
      v=$(pick "Kitty" "$KITTY_OP" 1.0 0.85 0.7 0.5)
      [ -n "$v" ] && { save KITTY_OP "$v"
        sed -i --follow-symlinks -E "s/^background_opacity .*/background_opacity $v/" ~/.config/kitty/kitty.conf
        pkill -SIGUSR1 kitty; } ;;
  esac
}

menu_wobble() {
  local v; v=$(pick "Gelatina" "$WOBBLE" "Desligada" "Suave" "Wobbly" "Extrema")
  [ -n "$v" ] && { save WOBBLE "$v"; apply_hypr; }
}

menu_energia() {
  local sel; sel=$(printf '%s\n' "Bloquear" "Suspender" "Sair" "Reiniciar" "Desligar" | fz "Energia" 5)
  case "$sel" in
    "Bloquear")  hyprlock ;;
    "Suspender") systemctl suspend ;;
    "Sair")      hyprctl dispatch 'hl.dsp.exit()' ;;
    "Reiniciar") systemctl reboot ;;
    "Desligar")  systemctl poweroff ;;
  esac
  exit 0
}

while true; do
  c=$(printf '%s\n' "Wallpaper" "Tema" "Janelas" "Blur" "Transparência" "Gelatina" "Energia" | fz "Rice" 7)
  [ -z "$c" ] && exit 0
  case "$c" in
    "Wallpaper")     menu_wallpaper ;;
    "Tema")          menu_tema ;;
    "Janelas")       menu_janelas ;;
    "Blur")          menu_blur ;;
    "Transparência") menu_transp ;;
    "Gelatina")      menu_wobble ;;
    "Energia")       menu_energia ;;
  esac
done
