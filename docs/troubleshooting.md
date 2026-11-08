# Solução de problemas

Primeiro, veja se o Hyprland reclamou de algo:

```bash
hyprctl configerrors
```

## O Hyprland subiu "padrão" (borda azul, teclado em US)

A partir do Hyprland 0.55 a configuração é o **`hyprland.lua`**. O formato antigo (`hyprland.conf`) pode não ser mais lido. Confira que existe `~/.config/hypr/hyprland.lua` (deve ser um link para `~/dotfiles/rice/.config/hypr/hyprland.lua`).

## Aviso vermelho "your config has errors"

Rode `hyprctl configerrors`. Se o erro for numa regra de camada ou animação, a sintaxe do Lua pode ter mudado na sua versão do Hyprland. Abra uma *issue* com a saída do comando e a versão (`hyprctl version`).

## Cores faltando, tela de bloqueio ou barra sem tema

As cores só existem depois de gerar o tema uma vez:

```bash
~/.config/hypr/scripts/wallpaper.sh ~/Pictures/Wallpapers/SUA_IMAGEM.png
```

Se aparecer uma pergunta de cor no terminal, o `wallpaper.sh` está desatualizado (ele deve passar `--source-color-index`).

## Waybar com quadradinhos vazios no lugar de ícones

A Nerd Font v3 removeu alguns ícones antigos. Os usados aqui são da faixa que existe. Se aparecer um quadradinho, o ícone daquele módulo não existe na sua fonte: troque o caractere em `waybar/config.jsonc`.

## `ff` mostra `{percentage-bar}` ou o fastfetch padrão

```bash
~/.config/hypr/scripts/fastfetch-build.sh
cat ~/.cache/fastfetch-build.log.hist
```
O script testa a config contra o seu fastfetch e cai numa versão mais simples se algo for recusado; o motivo fica nesse arquivo.

## Aviso do Starship: "Scanning current directory timed out"

A pasta tem muitos arquivos. Suba o `scan_timeout` no template `matugen/templates/starship.tpl.toml` e no arquivo gerado `~/.config/starship.toml`.

## Bluetooth não funciona

```bash
sudo systemctl enable --now bluetooth.service
rfkill list
bluetoothctl show
```
Se não houver controlador, o PC não tem bluetooth embutido (um adaptador USB resolve). Para parear, use `bluetui` ou `bluetoothctl`.

## A grade de wallpapers não abre

- Confira se o `rofi` abre: `rofi -show drun`. O `rofi` oficial tem suporte a Wayland desde a versão 2.0; em versões antigas, instale `rofi-wayland`.
- Confira se há imagens em `~/Pictures/Wallpapers`.
- Para refazer as miniaturas: `rm -r ~/.cache/wallpaper-thumbs-sq`.

## Notificações sem o estilo certo

O `~/.config/mako/config` é montado pelo `mako-build.sh` a partir das cores do matugen e do estilo atual. Troque o wallpaper uma vez ou rode `~/.config/hypr/scripts/mako-build.sh`.

## `stow` reclama de conflitos

```bash
cd ~/dotfiles && stow --no --verbose --target="$HOME" rice
```
Mova os arquivos listados como conflito para fora do lugar (ou rode o `bootstrap.sh`, que faz o backup sozinho).

## `settings.env` com valores quebrados

Valores com espaço precisam estar entre aspas (`STYLE="Liquid Glass"`). O menu já grava assim.

## `git push` falha: "sem branch upstream"

O `dotsave` usa `git push -u origin HEAD`. Se rodar o push à mão: `git push -u origin <branch>`.

## `git diff` / `git log` falham com "cannot run less"

```bash
sudo pacman -S less
```
ou use `git --no-pager ...`.
