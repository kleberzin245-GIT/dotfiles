#!/usr/bin/env bash
# shellcheck disable=SC2034  # ícones/constantes são usados por menu.sh após o source
set -euo pipefail
# menu-lib.sh — funções do menu de controle (separadas para manutenção).
# Esta biblioteca é fonte do menu.sh (entry point). Não executa nada sozinha.

# ---------------- ícones (Nerd Font / Font Awesome) ----------------
I_MENU=$'\xef\x80\x93';   I_WALL=$'\xef\x80\xbe';   I_THEME=$'\xef\x87\xbc';  I_WIN=$'\xef\x8b\x90'
I_BLUR=$'\xef\x81\xae';   I_OPAC=$'\xef\x81\x82';   I_WOB=$'\xef\x83\x90';    I_KEYS=$'\xef\x84\x9c'
I_POWER=$'\xef\x80\x91';  I_MOON=$'\xef\x86\x86';   I_SUN=$'\xef\x86\x85';    I_ARROWS=$'\xef\x81\x87'
I_CIRCLE=$'\xef\x84\x8c'; I_SQUARE=$'\xef\x82\x96'; I_BARS=$'\xef\x83\x89';   I_TERM=$'\xef\x84\xa0'
I_LOCK=$'\xef\x80\xa3';   I_OUT=$'\xef\x82\x8b';    I_REFRESH=$'\xef\x80\xa1'; I_INFO=$'\xef\x81\x9a'
I_UNDO=$'\xef\x83\xa2';   I_RANDOM=$'\xef\x81\xb4'; I_IMG=$'\xef\x80\xbe'
I_STYLE=$'\xef\x88\x99'

# Teclas oferecidas ao editar atalhos (nomes aceitos pelo Hyprland).
KEYS='1 2 3 4 5 6 7 8 9 0
q w e r t y u i o p
a s d f g h j k l
z x c v b n m
F1 F2 F3 F4 F5 F6 F7 F8 F9 F10 F11 F12
Return space Escape Tab BackSpace Delete Insert Home End Page_Up Page_Down Left Right Up Down Print'

ic()    { printf '%s  %s\n' "$1" "$2"; }          # "ícone  texto"
strip() { sed -E 's/^[^ ]+  //'; }                 # tira o ícone da escolha

# save "chave" "valor" -> escreve no settings.local.env (estado do usuário)
save() {
  mkdir -p "$(dirname "$CFG")"
  [ -f "$CFG" ] || : > "$CFG"
  if grep -q "^$1=" "$CFG"; then sed -i "s|^$1=.*|$1=\"$2\"|" "$CFG"; else echo "$1=\"$2\"" >> "$CFG"; fi
  # shellcheck disable=SC1090
  source "$CFG"
}

# ---------------- atalhos: dados ----------------
default_binds() {
  row() { printf '%s\t%s\t%s\t%s\t%s\n' "$@"; }
  {
    row terminal   "SUPER + RETURN"    "Abrir terminal"                  exec "kitty"
    # shellcheck disable=SC2088  # ~ é literal e expandido pelo shell do Hyprland
    row launcher   "SUPER + D"         "Abrir launcher"                  exec "~/.config/hypr/scripts/fuzzel.sh"
    row close      "SUPER + Q"         "Fechar janela"                   dsp  'hl.dsp.window.close()'
    row exit       "SUPER + SHIFT + E" "Sair do Hyprland"                exec "hyprctl dispatch 'hl.dsp.exit()'"
    row fullscreen "SUPER + F"         "Tela cheia"                      dsp  'hl.dsp.window.fullscreen()'
    row float      "SUPER + V"         "Alternar janela flutuante"       dsp  'hl.dsp.window.float({ action = "toggle" })'
    row pseudo     "SUPER + P"         "Pseudo-tile"                     dsp  'hl.dsp.window.pseudo()'
    row split      "SUPER + J"         "Alternar divisão"                dsp  'hl.dsp.layout("togglesplit")'
    # shellcheck disable=SC2088  # ~ é literal e expandido pelo shell do Hyprland
    row lock       "SUPER + L"         "Bloquear a tela"                 exec "~/.config/hypr/scripts/hyprlock.sh"
    # shellcheck disable=SC2088  # ~ é literal e expandido pelo shell do Hyprland
    row wallpaper  "SUPER + W"         "Wallpaper aleatório"             exec "~/.config/hypr/scripts/wallpaper.sh"
    # shellcheck disable=SC2088
    row wallpickr  "SUPER + SHIFT + W" "Escolher wallpaper (miniaturas)" exec "~/.config/hypr/scripts/wallpaper-picker.sh"
    row clipboard  "SUPER + C"         "Histórico da área de transf."    exec 'cliphist list | ~/.config/hypr/scripts/fuzzel.sh --dmenu | cliphist decode | wl-copy'
    # shellcheck disable=SC2088
    row menu       "SUPER + M"         "Menu / Central de controle"      exec "~/.config/hypr/scripts/rice-menu.sh"
    row screenshot "Print"             "Captura de tela (área)"          exec 'grim -g "$(slurp)" - | wl-copy'
  } > "$BINDS"
}

gen_binds() {
  local id key label kind payload esc
  {
    echo "-- GERADO pelo menu de controle (Atalhos). Não edite à mão."
    while IFS=$'\t' read -r id key label kind payload; do
      [ -z "$id" ] && continue
      case "$kind" in
        exec) esc=${payload//\\/\\\\}; esc=${esc//\"/\\\"}
              echo "hl.bind(\"$key\", hl.dsp.exec_cmd(\"$esc\"))" ;;
        dsp)  echo "hl.bind(\"$key\", $payload)" ;;
      esac
    done < "$BINDS"
  } > "$H/binds.lua"
}

gen_lua() {
  local GI GO BE BS BP BX BSZ INACT ACTIVE ST DP SPRING ST2 DP2
  case "$GAPS" in
    "Sem gaps") GI=0; GO=0 ;;
    "Pequeno")  GI=3; GO=6 ;;
    "Grande")   GI=8; GO=20 ;;
    *)          GI=5; GO=12 ;;
  esac
  BX=''
  case "$BLUR" in
    "Desligado") BE=false; BS=4; BP=2 ;;
    "Médio")     BE=true;  BS=6; BP=3 ;;
    "Forte")     BE=true;  BS=9; BP=4 ;;
    "Vidro")     BE=true;  BS=14; BP=4; BX=', vibrancy = 0.35, noise = 0.015' ;;
    *)           BE=true;  BS=4; BP=2 ;;
  esac
  INACT='c.outline_variant'
  case "$BORDER" in
    "Dinâmica")   ACTIVE='{ colors = { c.primary, c.tertiary }, angle = 45 }'; BSZ=2 ;;
    "Vidro")      ACTIVE='{ colors = { "rgba(ffffffcc)", "rgba(ffffff44)" }, angle = 45 }'; INACT='"rgba(ffffff26)"'; BSZ=1 ;;
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
            inactive_border = $INACT,
        },
    },
    decoration = {
        rounding = $ROUNDING,
        inactive_opacity = $INACTIVE,
        blur = { enabled = $BE, size = $BS, passes = $BP$BX },
    },
})

hl.curve("smooth", { type = "bezier", points = { {0.05, 0.9}, {0.1, 1.05} }  })
hl.curve("snappy", { type = "bezier", points = { {0.16, 1},   {0.3, 1}    }  })
EOT
  if [ "$SPRING" = 1 ]; then
  cat <<EOT

hl.curve("jelly",     { type = "spring", mass = 1, stiffness = $ST,  damping = $DP  })
hl.curve("jellySoft", { type = "spring", mass = 1, stiffness = $ST2, damping = $DP2 })

hl.animation({ leaf = "windows",     enabled = true, speed = 5, spring = "jelly"  })
hl.animation({ leaf = "windowsIn",   enabled = true, speed = 5, spring = "jelly", style = "popin 55%"  })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 5, spring = "jelly"  })
hl.animation({ leaf = "windowsOut",  enabled = true, speed = 3, bezier = "snappy", style = "popin 70%"  })
hl.animation({ leaf = "layersIn",    enabled = true, speed = 5, spring = "jellySoft", style = "popin 60%"  })
hl.animation({ leaf = "layersOut",   enabled = true, speed = 3, bezier = "snappy",    style = "popin 70%"  })
hl.animation({ leaf = "workspaces",  enabled = true, speed = 6, spring = "jellySoft", style = "slidevert"  })
EOT
  else
  cat <<EOT
hl.animation({ leaf = "windows",     enabled = true, speed = 4, bezier = "smooth"  })
hl.animation({ leaf = "windowsIn",   enabled = true, speed = 4, bezier = "smooth", style = "popin 90%"  })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 4, bezier = "smooth", style = "popin 90%"  })
hl.animation({ leaf = "windowsOut",  enabled = true, speed = 3, bezier = "snappy", style = "popin 90%"  })
hl.animation({ leaf = "layersIn",    enabled = true, speed = 4, bezier = "smooth", style = "fade"  })
hl.animation({ leaf = "layersOut",   enabled = true, speed = 3, bezier = "snappy", style = "fade"  })
hl.animation({ leaf = "workspaces",  enabled = true, speed = 5, bezier = "smooth", style = "slidevert"  })
EOT
  fi
  echo
  echo '-- blur atrás das notificações (mako)'
  echo 'hl.layer_rule({ name = "mako-blur", match = { namespace = "^notifications$" }, blur = true, ignore_alpha = 0.1 })'
  echo 'hl.layer_rule({ name = "rofi-blur", match = { namespace = "^rofi$" }, blur = true, ignore_alpha = 0.1 })'
  echo
  echo '-- atalhos editáveis (menu > Atalhos)'
  echo 'pcall(require, "binds")'
  } > "$H/settings.lua"
}

apply_hypr() { gen_lua; gen_binds; hyprctl reload >/dev/null 2>&1 || true; }

# ---------------- helpers de menu ----------------
fz() {
  local p="$1  "
  [ -n "${4:-}" ] && p="$4  $p"
  ~/.config/hypr/scripts/fuzzel.sh --dmenu --prompt "$p" --lines "${2:-8}" --width "${3:-30}" || true
}

pick() {
  local title="$1" cur="$2" out="" o; shift 2
  for o in "$@"; do
    if [ "$o" = "$cur" ]; then out+="● $o\n"; else out+="  $o\n"; fi
  done
  printf '%b' "$out" | fz "$title" "$#" | sed 's/^● //; s/^  //'
}

regen_theme() {
  local wp; wp="$(cat ~/.cache/current_wallpaper 2>/dev/null || true)"
  [ -f "$wp" ] && ~/.config/hypr/scripts/wallpaper.sh "$wp"
}

menu_wallpaper() {
  if [ -x ~/.config/hypr/scripts/wallpaper-picker.sh ] && command -v rofi >/dev/null; then
    ~/.config/hypr/scripts/wallpaper-picker.sh
    exit 0
  fi
  menu_wallpaper_lista
}

menu_wallpaper_lista() {
  local dir=~/Pictures/Wallpapers sel f
  sel=$( {
      ic "$I_RANDOM" "Aleatório"
      find "$dir" -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) -printf '%f\n' | sort \
        | while IFS= read -r f; do ic "$I_IMG" "$f"; done
    } | fz "Wallpaper" 10 30 "$I_WALL" | strip)
  [ -z "$sel" ] && return
  if [ "$sel" = "Aleatório" ]; then ~/.config/hypr/scripts/wallpaper.sh
  else ~/.config/hypr/scripts/wallpaper.sh "$dir/$sel"; fi
}

menu_tema() {
  local sel i
  sel=$( {
      ic "$I_MOON" "Modo: escuro"
      ic "$I_SUN"  "Modo: claro"
      for i in 1 2 3 4; do ic "$I_THEME" "Cor base: $i"; done
    } | fz "Tema" 6 30 "$I_THEME" | strip)
  case "$sel" in
    "Modo: escuro") echo dark  > ~/.cache/matugen_mode; regen_theme ;;
    "Modo: claro")  echo light > ~/.cache/matugen_mode; regen_theme ;;
    "Cor base: "*)  echo $(( ${sel##* } - 1 )) > ~/.cache/matugen_index; regen_theme ;;
  esac
}

menu_janelas() {
  local sel v
  sel=$( {
      ic "$I_ARROWS" "Espaçamento (gaps)"
      ic "$I_CIRCLE" "Arredondamento"
      ic "$I_SQUARE" "Borda"
      ic "$I_OPAC"   "Opacidade das inativas"
    } | fz "Janelas" 4 30 "$I_WIN" | strip)
  case "$sel" in
    "Espaçamento (gaps)")
      v=$(pick "Gaps" "$GAPS" "Sem gaps" "Pequeno" "Médio" "Grande"); [ -n "$v" ] && { save GAPS "$v"; apply_hypr; } ;;
    "Arredondamento")
      v=$(pick "Arredondamento" "$ROUNDING" 0 6 12 20); [ -n "$v" ] && { save ROUNDING "$v"; apply_hypr; } ;;
    "Borda")
      v=$(pick "Borda" "$BORDER" "Branca" "Dinâmica" "Vidro" "Sem borda"); [ -n "$v" ] && { save BORDER "$v"; apply_hypr; } ;;
    "Opacidade das inativas")
      v=$(pick "Inativas" "$INACTIVE" 1.0 0.94 0.85 0.7); [ -n "$v" ] && { save INACTIVE "$v"; apply_hypr; } ;;
  esac
}

menu_blur() {
  local v; v=$(pick "Blur" "$BLUR" "Desligado" "Leve" "Médio" "Forte" "Vidro")
  [ -n "$v" ] && { save BLUR "$v"; apply_hypr; }
}

menu_transp() {
  local sel v
  sel=$( {
      ic "$I_BARS" "Waybar"
      ic "$I_TERM" "Kitty"
    } | fz "Transparência" 2 30 "$I_OPAC" | strip)
  case "$sel" in
    "Waybar")
      v=$(pick "Waybar" "$WAYBAR_OP" 1.0 0.8 0.5 0.3)
      [ -n "$v" ] && { save WAYBAR_OP "$v"
        ~/.config/rice/scripts/style-render.py --waybar
        if [ "${RICE_SHELL:-waybar}" = waybar ]; then
          pkill -x waybar 2>/dev/null || true; sleep 0.4
          setsid ~/.config/hypr/scripts/shell-start.sh >/dev/null 2>&1 &
        fi; } ;;
    "Kitty")
      v=$(pick "Kitty" "$KITTY_OP" 1.0 0.97 0.85 0.7 0.5)
      [ -n "$v" ] && { save KITTY_OP "$v"
        ~/.config/rice/scripts/style-render.py --kitty
        pkill -SIGUSR1 kitty 2>/dev/null || true; } ;;
  esac
}

menu_wobble() {
  local v; v=$(pick "Gelatina" "$WOBBLE" "Desligada" "Suave" "Wobbly" "Extrema")
  [ -n "$v" ] && { save WOBBLE "$v"; apply_hypr; }
}

# ---------------- estilos completos ----------------
apply_extras() {
  ~/.config/rice/scripts/style-render.py --hyprlock --mako
}

apply_style() {
  local name="$1" preset k
  case "$name" in
    "Liquid Glass"|"Omarchy"|"Padrão") ;;
    *) name="Padrão" ;;
  esac

  preset=$(~/.config/rice/scripts/style-render.py --style "$name" --print-preset-shell) || {
    notify-send "Estilo" "Manifesto do estilo não encontrado"; return; }
  eval "$preset"

  for k in GAPS ROUNDING BORDER BLUR INACTIVE WOBBLE WAYBAR_OP KITTY_OP; do
    save "$k" "${!k}"
  done
  save STYLE "$name"

  ~/.config/rice/scripts/style-render.py --style "$name" --all
  apply_hypr
  setsid ~/.config/hypr/scripts/shell-start.sh --restart >/dev/null 2>&1 &
  pkill -SIGUSR1 kitty 2>/dev/null || true
  notify-send "Estilo" "$name aplicado"
}

menu_estilo() {
  local v; v=$(pick "Estilo" "${STYLE:-Padrão}" "Padrão" "Liquid Glass" "Omarchy")
  [ -n "$v" ] && apply_style "$v"
}

# ---------------- atalhos: ver e mudar ----------------
lc() { printf '%s' "$1" | tr 'A-Z' 'a-z'; }

conflict() {
  local new_l id key label rest
  new_l=$(lc "$1")
  while IFS=$'\t' read -r id key label rest; do
    [ "$id" = "$2" ] && continue
    [ "$(lc "$key")" = "$new_l" ] && { echo "$label"; return; }
  done < "$BINDS"
  case "$new_l" in
    "super + left"|"super + right"|"super + up"|"super + down") echo "Mover foco entre janelas" ;;
    "super + "[0-9]) echo "Ir para o workspace" ;;
    "super + shift + "[0-9]) echo "Mover janela para o workspace" ;;
  esac
}

edit_bind() {
  local n=$1 id key label kind payload mods k new c
  IFS=$'\t' read -r id key label kind payload <<< "$(sed -n "${n}p" "$BINDS")"
  mods=$(printf '%s\n' "SUPER" "SUPER + SHIFT" "SUPER + CTRL" "SUPER + ALT" "CTRL + ALT" "CTRL + SHIFT" "ALT" "Sem modificador" \
         | fz "$label (hoje: $key)" 8 44 "$I_KEYS")
  [ -z "$mods" ] && return
  k=$(printf '%s\n' "$KEYS" | fz "Tecla (digite pra filtrar)" 12 44 "$I_KEYS")
  [ -z "$k" ] && return
  if [ "$mods" = "Sem modificador" ]; then new="$k"; else new="$mods + $k"; fi

  c=$(conflict "$new" "$id")
  if [ -n "$c" ]; then
    notify-send "Atalhos" "$new já é usado em: $c. Escolha outro."
    return
  fi
  awk -F'\t' -v OFS='\t' -v n="$n" -v k="$new" 'NR==n{$2=k}1' "$BINDS" > "$BINDS.tmp"
  cat "$BINDS.tmp" > "$BINDS"; rm -f "$BINDS.tmp"
  apply_hypr
  notify-send "Atalhos" "$label agora é $new"
}

show_fixed() {
  printf '%s\n' \
    "SUPER + setas                  Mover foco entre janelas" \
    "SUPER + 1 … 0                  Ir para o workspace" \
    "SUPER + SHIFT + 1 … 0          Mover janela para o workspace" \
    "SUPER + scroll                 Trocar de workspace" \
    "SUPER + mouse (esq./dir.)      Mover / redimensionar janela" \
    "Teclas de volume e brilho      Ajustam volume e brilho" \
    "Teclas de mídia                Play, pausa, próxima, anterior" \
    | fz "Atalhos fixos (só leitura)" 7 62 "$I_INFO" >/dev/null
}

restore_binds() {
  local a; a=$(pick "Restaurar atalhos padrão?" "" "Não" "Sim, restaurar")
  if [ "$a" = "Sim, restaurar" ]; then default_binds; apply_hypr; notify-send "Atalhos" "Atalhos padrão restaurados"; fi
}

menu_atalhos() {
  local lines n idx id key label kind payload
  while true; do
    lines=""; n=0
    while IFS=$'\t' read -r id key label kind payload; do
      [ -z "$id" ] && continue
      lines+="$(printf '%-19s  %s' "$key" "$label")"$'\n'
      n=$((n+1))
    done < "$BINDS"
    lines+="$(ic "$I_INFO" "Atalhos fixos (só leitura)")"$'\n'"$(ic "$I_UNDO" "Restaurar atalhos padrão")"
    idx=$(printf '%s' "$lines" | ~/.config/hypr/scripts/fuzzel.sh --dmenu --index --prompt "$I_KEYS  Atalhos  " --lines $((n+2)) --width 58 || true)
    [ -z "$idx" ] && return
    if   [ "$idx" -lt "$n" ];  then edit_bind $((idx+1))
    elif [ "$idx" -eq "$n" ];  then show_fixed
    else restore_binds; fi
  done
}

menu_energia() {
  local sel
  sel=$( {
      ic "$I_LOCK"    "Bloquear"
      ic "$I_MOON"    "Suspender"
      ic "$I_OUT"     "Sair"
      ic "$I_REFRESH" "Reiniciar"
      ic "$I_POWER"   "Desligar"
    } | fz "Energia" 5 30 "$I_POWER" | strip)
  case "$sel" in
    "Bloquear")  ~/.config/hypr/scripts/hyprlock.sh ;;
    "Suspender") systemctl suspend ;;
    "Sair")      hyprctl dispatch 'hl.dsp.exit()' ;;
    "Reiniciar") systemctl reboot ;;
    "Desligar")  systemctl poweroff ;;
  esac
  exit 0
}
