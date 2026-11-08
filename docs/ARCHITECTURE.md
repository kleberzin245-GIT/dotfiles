# Arquitetura do rice

Este repositório é um **dotfiles** para um ambiente Linux (Hyprland). O fluxo é:

```
git clone ... ~/dotfiles
./install.sh            → detecta a distro (instala automaticamente só no Arch)
./bootstrap.sh          → (chamado por install.sh no Arch) pacman + AUR + stow
rice/.config/            → configs do desktop, vinculadas via GNU Stow
rice/.config/matugen/    → templates de cores usados pelo Matugen
rice/.config/hypr/scripts/menu.sh → menu de controle interativo (SUPER+M)
```

## Fluxo de data (what comes from where)

```
Matugen (tema dinâmico)
   ↓ gera cores
~/.config/hypr/colors.lua + ~/.config/waybar/colors.css + ~/.config/kitty/colors.conf
~/.config/fastfetch/colors.env   (lido por fastfetch-build.sh)
~/.config/starship.toml
~/.cache/matugen_mode
```

O `menu.sh` pode regenerar essas cores a partir da paleta (menu > Tema).

## Componentes principais

| Componente | Local | Papel |
|---|---|---|
| `hyprland.lua` | `rice/.config/hypr/` | Compositor Hyprland (gaps, blur, curvas, binds) |
| `settings.env` | `rice/.config/hypr/` | Valores atualizáveis pelo menu (gaps, blur, borda, opacidade) |
| `binds.tsv` | `rice/.config/hypr/` | Atalhos experimentais (gerados pelo menu, escritos em Lua) |
| `menu.sh` | `rice/.config/hypr/scripts/` | Menu de controle interativo (SUPER+M) |
| `wallpaper.sh` | `rice/.config/hypr/scripts/` | Troca de wallpaper com swww/awww + matugen |
| `dotsave` | raiz | Commit + push dos arquivos de configuração |
| `bootstrap.sh` | raiz | Instala pacotes, linka configs (stow), configura o ambiente (Arch) |
| `install.sh` | raiz | Entrada: no Arch chama o bootstrap; nas outras distros imprime o guia manual |

## Fluxo de personalização

1. Você abre o menu (`SUPER + M`).
2. Escolhe uma opção (Wallpaper, Estilo, Tema, Janelas, Blur, Transparência,
   Gelatina, Atalhos, Energia).
3. O `menu.sh` escreve/altera os arquivos em `rice/.config/`.
4. Algumas alterações exigem `hyprctl reload` (gerenciado por `apply_hypr`).
5. O `dotsave` fixa as mudanças: `git add -A && git commit && git push`.

## Arquivos gerados em runtime (gitignored ou defaults commitados)

| Arquivo | Origem | Comportamento |
|---|---|---|
| `fastfetch/config.jsonc` | matugen | Default commitado; regerado em wallpaper |
| `starship.toml` | matugen | Default commitado; regerado em wallpaper |
| `colors.lua`, `settings.lua` | matugen | Regerados dinamicamente |
| `binds.lua` | menu.sh | Gerado; supre os binds padrão |
| `mako/config`, `mako/colors.part` | menu.sh | Gerados em runtime |
| `current_wallpaper` | wallpaper.sh | Estado do wallpaper atual |
| `.config-backup-rice-*` | bootstrap.sh | Backup de conflitos do stow |

## Instalação rápida

```bash
git clone https://github.com/kleberzin245-GIT/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh            # detecta a distribuição e instala
```

## Licença

[The MIT License](LICENSE)
