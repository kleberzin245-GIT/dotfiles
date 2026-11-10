# Personalização

Quase tudo se ajusta pelo **menu de controle** (`SUPER+M`). Cada escolha é aplicada na hora e fica salva em `~/.config/hypr/settings.local.env` (o `settings.env` do repositório guarda só os defaults).

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

Ao trocar o wallpaper, o `matugen` gera as cores e os templates em `rice/.config/matugen/templates/` produzem os arquivos de cada programa. Os arquivos gerados **não** ficam no git (`colors.*`, `settings.lua`, `binds.lua`, `mako/config`, `~/.local/state/rice/*`).

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

1. Copie `rice/.config/rice/styles/padrao.json` para `rice/.config/rice/styles/<id>.json` e ajuste `id`, `name` e as seções (`hypr`, `waybar`, `kitty`, `fuzzel`, `mako`, `rofi`, `hyprlock`, `quickshell`).
2. Crie `rice/.config/waybar/themes/<id>/style.css` usando os tokens `{{opacity}}` e `{{radius}}`.
3. Crie `rice/.config/hypr/lock-styles/<id>.conf`.
4. Teste com `~/.config/rice/scripts/style-render.py --style "Seu Nome" --all`.
5. O estilo já aparece no menu (ele lê os manifestos automaticamente).

## Barra: Waybar ou Quickshell

A Waybar é o padrão. Para usar a barra/Central de Controle em Quickshell, instale
`quickshell` e defina:

```bash
echo 'RICE_SHELL="quickshell"' >> ~/.config/hypr/settings.local.env
~/.config/hypr/scripts/shell-start.sh --restart
```

`SUPER+M` abre a Central de Controle; sem Quickshell, abre o menu em Fuzzel.

## O que editar e o que é gerado

| Editar | Gerado (não versionado) |
|---|---|
| `hyprland.lua`, `binds.tsv`, `settings.env` | `settings.lua`, `binds.lua`, `colors.lua`, `colors.conf` |
| `rice/styles/*.json`, `waybar/themes/*/style.css` | `~/.local/state/rice/waybar/*`, `kitty/style.conf`, `fuzzel/overrides.env`, `rofi/overrides.rasi`, `hyprlock/style.conf` |
| `waybar/config.jsonc` | `~/.local/state/rice/waybar/config.jsonc` |
| `matugen/templates/*`, `config.toml` | `kitty/colors.conf`, `fuzzel/colors.ini`, `rofi/colors.rasi`, `mako/config`, `fastfetch/colors.env`, `quickshell/colors.json` |

Mudanças em arquivos versionados entram no git com `~/dotfiles/dotsave "descrição"`.
Inclua também as novas pastas (`git add rice/.config/rice rice/.config/quickshell`).
