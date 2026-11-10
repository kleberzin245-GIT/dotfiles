# Arquitetura do rice

Este repositório é um **dotfiles** para um ambiente Linux (Hyprland). O fluxo é:

```
git clone ... ~/dotfiles
./install.sh            → detecta a distro (instala automaticamente só no Arch)
./bootstrap.sh          → (chamado por install.sh no Arch) pacman + AUR + stow
rice/.config/           → configs do desktop, vinculadas via GNU Stow
rice/.config/matugen/   → templates de cores usados pelo Matugen
rice/.config/rice/      → manifestos de estilo + style-render.py
rice/.config/quickshell → barra/Central de Controle opcionais
```

## Fluxo de dados

```
Wallpaper
   ↓
wallpaper.sh (awww/swww)
   ↓
Matugen (tema dinâmico)
   ↓ gera cores
~/.config/hypr/colors.lua · ~/.config/waybar/colors.css · ~/.config/kitty/colors.conf
~/.config/fuzzel/colors.ini · ~/.config/rofi/colors.rasi · ~/.config/mako/colors.part
~/.config/fastfetch/colors.env · ~/.config/starship.toml
~/.local/state/rice/quickshell/colors.json
```

O `menu.sh` (aba **Tema**) pode regenerar essas cores a partir da paleta.

## Estilos

Cada estilo é um **manifesto JSON** em `rice/.config/rice/styles/` com valores de
Hyprland, Waybar, Kitty, Fuzzel, Mako, Rofi, Hyprlock e Quickshell. O
`style-render.py` lê o manifesto + os templates (CSS do Waybar, `.conf` do
Hyprlock, seção do Mako) e escreve tudo em `~/.local/state/rice/` — fora do
repositório. Assim, trocar de estilo não suja o git e o estado do usuário
(`settings.local.env`, `binds.tsv`) fica separado dos defaults versionados.

```
rice/.config/rice/styles/<id>.json
        ↓ style-render.py (--style NOME --all)
~/.local/state/rice/waybar/{config.jsonc,style.css,colors.css}
~/.local/state/rice/kitty/style.conf
~/.local/state/rice/fuzzel/overrides.env
~/.local/state/rice/hyprlock/style.conf
~/.local/state/rice/rofi/overrides.rasi
~/.local/state/rice/style.json
```

## Componentes principais

| Componente | Local | Papel |
|---|---|---|
| `hyprland.lua` | `rice/.config/hypr/` | Compositor Hyprland (gaps, blur, curvas, binds) |
| `settings.env` | `rice/.config/hypr/` | Defaults versionados (gaps, blur, borda, opacidade, `RICE_SHELL`) |
| `settings.local.env` | `~/.config/hypr/` | Estado do usuário; vence os defaults (gitignored) |
| `binds.tsv` | `rice/.config/hypr/` | Semente dos atalhos (copiada para o estado na 1ª vez) |
| `menu.sh` | `rice/.config/hypr/scripts/` | Menu de controle interativo (SUPER+M) |
| `rice-menu.sh` | `rice/.config/hypr/scripts/` | Abre a Central de Controle (Quickshell) ou o menu (Fuzzel) |
| `style-render.py` | `rice/.config/rice/scripts/` | Renderiza os manifestos de estilo |
| `wallpaper.sh` | `rice/.config/hypr/scripts/` | Troca de wallpaper com swww/awww + matugen |
| `shell-start.sh` | `rice/.config/hypr/scripts/` | Inicia a barra definida em `RICE_SHELL` |
| `dotsave` | raiz | Commit + push (ativa o hook pre-commit sozinho) |
| `bootstrap.sh` | raiz | Instala pacotes, linka configs (stow), configura o ambiente (Arch) |
| `install.sh` | raiz | Entrada: no Arch chama o bootstrap; nas outras distros imprime o guia manual |

## Fluxo de personalização

1. Você abre o menu (`SUPER + M`).
2. Escolhe uma opção (Wallpaper, Estilo, Tema, Janelas, Blur, Transparência,
   Gelatina, Atalhos, Energia).
3. O `menu.sh` grava o estado do usuário em `settings.local.env` e
   `~/.local/state/rice/binds.tsv`; o `style-render.py` gera os arquivos de estilo.
4. Algumas alterações exigem `hyprctl reload` (gerenciado por `apply_hypr`).
5. O `dotsave` fixa as mudanças do repositório: `git add -A && git commit && git push`.

## Arquivos gerados em runtime

| Arquivo | Origem | Comportamento |
|---|---|---|
| `settings.local.env` | menu.sh | Estado do usuário (gitignored) |
| `~/.local/state/rice/*` | style-render.py | Configs renderizadas do estilo atual |
| `~/.local/state/rice/quickshell/colors.json` | matugen | Cores do Quickshell |
| `colors.lua`, `settings.lua` | matugen / menu.sh | Regerados dinamicamente (gitignored) |
| `binds.lua` | menu.sh | Gerado a partir do `binds.tsv` (gitignored) |
| `mako/config`, `mako/colors.part` | style-render.py / matugen | Gerados em runtime (gitignored) |
| `current_wallpaper` | wallpaper.sh | Estado do wallpaper atual (gitignored) |
| `.config-backup-rice-*` | bootstrap.sh | Backup de conflitos do stow |

## Instalação rápida

```bash
git clone https://github.com/kleberzin245-GIT/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh            # detecta a distribuição e instala
```

## Licença

[The MIT License](LICENSE)
