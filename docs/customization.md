# Personalização

Quase tudo se ajusta pelo **menu de controle** (`SUPER+M`). Cada escolha é aplicada na hora e fica salva em `settings.env`.

## Menu de controle

| Seção | O que muda |
|---|---|
| **Wallpaper** | Abre a grade de miniaturas (Rofi) |
| **Estilo** | Padrão, Liquid Glass ou Omarchy (veja abaixo) |
| **Tema** | Modo escuro/claro e qual das 4 cores do wallpaper o matugen usa de base |
| **Janelas** | Espaçamento (gaps), arredondamento, borda e opacidade das janelas inativas |
| **Blur** | Desligado, Leve, Médio, Forte ou Vidro |
| **Transparência** | Da Waybar e do Kitty |
| **Gelatina** | Intensidade das animações elásticas: Desligada, Suave, Wobbly ou Extrema |
| **Atalhos** | Ver e trocar os atalhos (veja [keybinds.md](keybinds.md)) |
| **Energia** | Bloquear, suspender, sair, reiniciar, desligar |

## Estilos

Um estilo muda várias coisas de uma vez: a barra, as janelas, o blur, a borda, as animações, o launcher, as notificações e a tela de bloqueio. As **cores** vêm sempre do wallpaper.

- **Padrão** — barra flutuante, borda branca, gelatina.
- **Liquid Glass** — barra em "pílulas" de vidro, blur forte, cantos bem arredondados.
- **Omarchy** — barra reta de largura total, cantos retos, animações rápidas sem gelatina.

Depois de aplicar um estilo, dá pra ajustar cada item separadamente pelo menu.

## Cores (matugen)

Ao trocar o wallpaper, o `matugen` gera as cores e os templates em `rice/.config/matugen/templates/` produzem os arquivos de cada programa. Os arquivos gerados **não** ficam no git (`colors.*`, `settings.lua`, `binds.lua`, `mako/config`).

Para mudar quais programas recebem as cores, edite `rice/.config/matugen/config.toml`.

## Grade de wallpapers

- Abre com `SUPER + SHIFT + W`.
- As miniaturas ficam em cache em `~/.cache/wallpaper-thumbs-sq`. Se trocar uma imagem por outra com o mesmo nome e a miniatura ficar desatualizada, apague a pasta.
- Para mudar o tamanho da grade, edite `columns`, `lines` e o `size` do `element-icon` em `rice/.config/rofi/wallpaper.rasi`.

## Terminal

- **Starship** — o prompt usa as cores do wallpaper (`rice/.config/matugen/templates/starship.tpl.toml`).
- **fastfetch** (`ff`) — logo do Arch em blocos com gradiente; a config é montada por `rice/.config/hypr/scripts/fastfetch-build.sh`.
- **eza** substitui o `ls` (`ls`, `ll`, `la`, `lt`) e **bat** substitui o `cat` (`catn` mostra com números de linha).
- Para usar o comando original: `\ls` ou `command cat`.
- Tudo isso é carregado por `rice/.config/shell/rice.sh`.

## Criar um estilo novo

1. Crie `rice/.config/waybar/themes/<id>/config.jsonc` e `style.css`.
2. Crie `rice/.config/hypr/lock-styles/<id>.conf`.
3. Em `rice/.config/hypr/scripts/menu.sh`, adicione o estilo no `case` de `apply_style` (valores de gaps, blur, etc.) e em `apply_extras`.
4. Em `rice/.config/hypr/scripts/mako-build.sh`, adicione o formato das notificações.
5. Em `rice/.config/hypr/scripts/wallpaper-picker.sh`, ajuste a função `overrides` se quiser mudar a grade.

## O que editar e o que é gerado

| Editar | Gerado (não versionado) |
|---|---|
| `hyprland.lua`, `binds.tsv`, `settings.env` | `settings.lua`, `binds.lua`, `colors.lua`, `colors.conf` |
| `waybar/config.jsonc`, `style.css`, `themes/*` | `waybar/colors.css` |
| `matugen/templates/*`, `config.toml` | `kitty/colors.conf`, `fuzzel/colors.ini`, `rofi/colors.rasi`, `mako/config` |

Mudanças em arquivos versionados entram no git com `~/dotfiles/dotsave "descrição"`.
