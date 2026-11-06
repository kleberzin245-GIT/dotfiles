# Meu rice (Hyprland + matugen)

Hyprland · Waybar · Kitty · Fuzzel · Mako · Hyprlock · matugen (tema dinâmico pelo wallpaper)

## Instalar numa máquina nova
```bash
git clone <URL-DO-REPO> ~/dotfiles
cd ~/dotfiles && ./bootstrap.sh
```

## Salvar mudanças
```bash
~/dotfiles/dotsave "descrição da mudança"
```

As configs em `~/.config` são symlinks para `~/dotfiles/rice/.config`.
Arquivos gerados pelo matugen (`colors.*`, `settings.lua`) ficam fora do git
e são recriados ao trocar de wallpaper / rodar `menu.sh --init`.
