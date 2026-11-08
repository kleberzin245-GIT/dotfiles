# Troubleshooting

## Instalação

### `bootstrap.sh` para Arch e derivados

Se o script para logo com "pacman não encontrado", o sistema operacional não é Arch ou um
de seus derivados. Esse rice é focado em Arch; para Ubuntu, Debian ou Fedora, siga
[`docs/installation.md`](installation.md#-ubuntu--debian-manual).

### Packages não instalados

Se o `stow` ou `git` não estiver instalado, o script para com uma mensagem clara.
Instale `git` e `stow` antes de rodar.

---

## Uso

### `menu.sh` não abre

- Verifique se o `fuzzel` está instalado.
- Use `~/dotfiles/rice/.config/hypr/scripts/menu.sh` diretamente.
- Se o menu trava, rode `menu.sh --init` para regenerar os binds/settings.

### Wallpaper não aparece

1. Coloque a imagem em `~/Pictures/Wallpapers`.
2. Execute: `wallpaper.sh /caminho/sua_imagem.png`
3. Faça logout e login novamente (mudanças de compositor só rodam no login).

### Cores/tema não atualizam

- O Matugen gera `colors.lua`, `colors.conf`, `settings.lua`, `colors.css`, etc. Verifique
  se `matugen image` rodou com sucesso ao trocar wallpaper.
- Os arquivos gerados estão ignorados no `.gitignore` (gerados em runtime).

### Waybar não aparece

- A barra é iniciada no boot pelo `hyprland.lua` (`wallpaper.sh restore` → `waybar`).
- Se aparecer vazia, rode `pkill -x waybar` e tente logar novamente.

### Hi-DPI / escala

- O `hyprland.lua` define `scale = "auto"`. Ajuste o `scale` manualmente se a tela ficar
  muito grande/pequena.

### Texto ilegível (ícones faltando)

- Instale o **JetBrains Mono Nerd Font** e `Papirus-Icon-theme`.
- Os ícones nos Waybar, Fuzzel e Hyprlock dependem desse Nerd Font.
