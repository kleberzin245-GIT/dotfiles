# 󰣇 dotfiles — Hyprland Rice

<p align="center">
  <b>A customized Linux desktop environment focused on aesthetics, functionality and personalization.</b>
</p>

<p align="center">
  Hyprland · Matugen · Waybar · Kitty · Fuzzel · Mako · Hyprlock
</p>

---

##  Preview

A look at my current desktop setup.

<p align="center">
  <img src="preview/01-desktop-info.jpg" width="49%" alt="Desktop overview">
  <img src="preview/02-wallpaper-picker.jpg" width="49%" alt="Wallpaper picker">
</p>

<p align="center">
  <img src="preview/03-desktop-widgets.jpg" width="49%" alt="Desktop widgets">
  <img src="preview/04-spotify-theme.jpg" width="49%" alt="Spotify integration">
</p>

<p align="center">
  <img src="preview/05-quick-menu.jpg" width="49%" alt="Customization menu">
  <img src="preview/06-keyboard-shortcuts.jpg" width="49%" alt="Keyboard shortcuts">
</p>

---

## About

This repository contains my personal Linux dotfiles, built around **Hyprland**.

The goal is to create a desktop that combines a distinctive visual identity with a practical and comfortable workflow.

The setup is continuously evolving, with custom scripts, dynamic colors and personalized desktop components.

## Features

- **Hyprland:** Dynamic tiling Wayland compositor.
- **Matugen:** Generates color schemes based on the current wallpaper.
- **Waybar:** Customized desktop status bar.
- **Kitty:** Terminal emulator configuration.
- **Fuzzel:** Application launcher.
- **Mako:** Notification daemon.
- **Hyprlock:** Customized lock screen.
- **Wallpaper customization:** Change wallpapers and adapt the desktop colors.
- **Custom scripts:** Tools for desktop personalization and configuration management.

## Tech Stack

| Component | Purpose |
|---|---|
| Hyprland | Wayland compositor |
| Matugen | Dynamic theming |
| Waybar | Status bar |
| Kitty | Terminal |
| Fuzzel | Application launcher |
| Mako | Notifications |
| Hyprlock | Screen locking |
| GNU Stow | Dotfiles management |

## Installation

Clone the repository:

```bash
git clone https://github.com/kleberzin245-GIT/dotfiles.git ~/dotfiles
```

Enter the directory:

```bash
cd ~/dotfiles
```

Run the bootstrap script:

```bash
./bootstrap.sh
```

**Note:** Review the installation script and its dependencies before running it on a new machine.

## Configuration Structure

```text
dotfiles/
├── docs/
├── rice/
│   └── .config/
├── preview/
├── bootstrap.sh
├── dotsave
└── README.md
```

The configurations inside `~/.config` are symlinks pointing to:

```text
~/dotfiles/rice/.config
```

This keeps the configuration centralized and easier to maintain.

## Saving Changes

Use the included `dotsave` script to save configuration changes:

```bash
~/dotfiles/dotsave "description of the change"
```

## Dynamic Theming

Matugen generates color configurations based on the current wallpaper.

Generated files such as `colors.*` and `settings.lua` are kept outside Git and recreated when changing wallpapers or running:

```bash
menu.sh --init
```

## Project Status

<em>Work in progress.</em>

This rice is constantly evolving. Configurations, scripts and visual elements may change as the project develops.

## Credits

Built and maintained by **kleberzin245-GIT**.

Feel free to explore, learn from the configurations and use ideas in your own desktop setup.

---

<p align="center">
  <b>Made with Linux, Hyprland and a lot of customization.</b>
</p>
