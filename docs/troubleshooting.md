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

O `~/.config/mako/config` é montado pelo `style-render.py --mako` a partir das cores do matugen e do estilo atual. Troque o wallpaper uma vez ou rode:

```bash
~/.config/rice/scripts/style-render.py --all
```

## Trocar de estilo não fez efeito

O estado gerado fica em `~/.local/state/rice/`. Force a regeração e reinicie a barra:

```bash
~/.config/rice/scripts/style-render.py --all
~/.config/hypr/scripts/shell-start.sh --restart
hyprctl reload
```

Se o menu mostrar um estilo que não existe, confira o manifesto em
`rice/.config/rice/styles/` e rode `menu.sh --apply-style "Padrão"`.

## Quickshell: barra/Central de Controle não abre

1. Instale o Quickshell e confirme: `quickshell --version`.
2. Use `RICE_SHELL="quickshell"` em `~/.config/hypr/settings.local.env`.
3. Reinicie: `~/.config/hypr/scripts/shell-start.sh --restart`.
4. Abra o painel: `SUPER+M` (ou `quickshell ipc -p ~/.config/quickshell call rice toggleControlCenter`).

Se o Quickshell falhar ao subir, o `shell-start.sh` volta para a Waybar automaticamente.
Veja o log com `quickshell -p ~/.config/quickshell --verbose`.

## `stow` reclama de conflitos

```bash
cd ~/dotfiles && stow --no --no-folding --verbose --target="$HOME" rice
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

## Atualizei e algo quebrou

```bash
cd ~/dotfiles
./update.sh --dry-run   # veja o que será feito
git log --oneline -10   # identifique a mudança
./doctor.sh --report    # cole o resultado numa issue
```

Se o problema for visual, faça logout e login (ou `hyprctl reload`).
Para testar uma versão antiga: `git switch --detach <tag-ou-commit>` e rode
`~/.config/hypr/scripts/menu.sh --init`; para voltar, use `git switch -`.
