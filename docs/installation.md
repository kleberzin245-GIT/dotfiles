# Installation

> Ver também: [Troubleshooting](troubleshooting.md) e [Customization](customization.md).

## Pré-requisitos

- Distribuição **Linux** com compositor Wayland (recomendado: Arch + derivados)
- Git e `stow` (pacote `stow`)
- Atalhos de teclado e ponteiro Wayland

## Instalação

### 1. Clonar

```bash
git clone https://github.com/kleberzin245-GIT/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

### 2. Rodar o bootstrap

```bash
./bootstrap.sh
```

O script gerencia a instalação de pacotes, o `stow`, os backups e a geração dos atalhos.

### 3. Visualizar

- `menu.sh` → painel principal (`SUPER + M` no ambiente carregado)
- `wallpaper.sh` para trocar o wallpaper

---

## Estrutura do repo

```
dotfiles/
├── bootstrap.sh          instalação (Arch + derivados)
├── dotsave               commit + push dos mudanças
├── rice/.config          configs vinculadas ao $HOME via stow
├── preview/              capturas do desktop
├── docs/                 documentação
└── LICENSE
```
