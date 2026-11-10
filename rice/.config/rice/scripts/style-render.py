#!/usr/bin/env python3
"""Renderiza os arquivos de estilo do rice a partir dos manifestos compartilhados.

Fonte de verdade:
  ~/.config/rice/styles/<id>.json       valores por estilo
  ~/.config/waybar/config.jsonc         estrutura da Waybar (editável)
  ~/.config/waybar/themes/<id>/style.css  layout do CSS (tokens {{opacity}}/{{radius}})
  ~/.config/hypr/lock-styles/<id>.conf  layout da tela de bloqueio
  ~/.config/mako/colors.part            cores geradas pelo Matugen

Saídas (fora do repositório):
  ~/.local/state/rice/waybar/{config.jsonc,style.css}
  ~/.local/state/rice/kitty/style.conf
  ~/.local/state/rice/fuzzel/overrides.env
  ~/.local/state/rice/hyprlock/style.conf
  ~/.local/state/rice/rofi/overrides.rasi
  ~/.local/state/rice/style.json
  ~/.config/mako/config                 (gerado, gitignored)
"""

from __future__ import annotations

import argparse
import copy
import json
import os
import re
import shlex
import subprocess
import sys
from pathlib import Path

SCRIPT_DIR = Path(__file__).resolve().parent
CONFIG_DIR = Path(os.environ.get("XDG_CONFIG_HOME", Path.home() / ".config"))
STATE_DIR = Path(os.environ.get("XDG_STATE_HOME", Path.home() / ".local/state")) / "rice"

STYLES_DIR = SCRIPT_DIR.parent / "styles"
if not STYLES_DIR.is_dir():
    STYLES_DIR = CONFIG_DIR / "rice" / "styles"

WAYBAR_BASE = CONFIG_DIR / "waybar" / "config.jsonc"
WAYBAR_THEMES = CONFIG_DIR / "waybar" / "themes"
WAYBAR_FALLBACK = CONFIG_DIR / "waybar" / "style.css"
LOCK_STYLES = CONFIG_DIR / "hypr" / "lock-styles"
SETTINGS_DEFAULT = CONFIG_DIR / "hypr" / "settings.env"
SETTINGS_LOCAL = CONFIG_DIR / "hypr" / "settings.local.env"
MAKO_COLORS = CONFIG_DIR / "mako" / "colors.part"
MAKO_CONFIG = CONFIG_DIR / "mako" / "config"

PRESET_KEYS = ("GAPS", "ROUNDING", "BORDER", "BLUR", "INACTIVE", "WOBBLE")

FALLBACK_COLORS_CSS = """@define-color primary #cba6f7;
@define-color on_primary #1e1e2e;
@define-color primary_container #45475a;
@define-color on_primary_container #cdd6f4;
@define-color secondary #89b4fa;
@define-color tertiary #94e2d5;
@define-color error #f38ba8;
@define-color surface #1e1e2e;
@define-color surface_container #313244;
@define-color on_surface #cdd6f4;
@define-color on_surface_variant #bac2de;
@define-color outline #6c7086;
"""


def strip_jsonc(text: str) -> str:
    out: list[str] = []
    in_string = False
    escape = False
    i = 0
    while i < len(text):
        ch = text[i]
        if in_string:
            out.append(ch)
            if escape:
                escape = False
            elif ch == "\\":
                escape = True
            elif ch == '"':
                in_string = False
            i += 1
            continue
        if ch == '"':
            in_string = True
            out.append(ch)
        elif ch == "/" and i + 1 < len(text) and text[i + 1] == "/":
            while i < len(text) and text[i] != "\n":
                i += 1
            continue
        elif ch == "/" and i + 1 < len(text) and text[i + 1] == "*":
            i += 2
            while i + 1 < len(text) and not (text[i] == "*" and text[i + 1] == "/"):
                i += 1
            i += 2
            continue
        else:
            out.append(ch)
        i += 1
    return re.sub(r",(\s*[}\]])", r"\1", "".join(out))


def load_jsonc(path: Path) -> dict:
    if not path.exists():
        return {}
    raw = path.read_text(encoding="utf-8")
    if not raw.strip():
        return {}
    return json.loads(strip_jsonc(raw))


def load_env_file(path: Path) -> dict[str, str]:
    values: dict[str, str] = {}
    if not path.exists():
        return values
    for line in path.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        key, _, raw = line.partition("=")
        key = key.strip()
        try:
            parts = shlex.split(raw, comments=True)
        except ValueError:
            parts = [raw.strip().strip('"').strip("'")]
        values[key] = parts[0] if parts else ""
    return values


def load_settings() -> dict[str, str]:
    values = load_env_file(SETTINGS_DEFAULT)
    values.update(load_env_file(SETTINGS_LOCAL))
    return values


def find_manifest(name: str | None, settings: dict[str, str]) -> dict:
    wanted = (name or settings.get("STYLE") or "Padrão").strip()
    manifests = []
    if STYLES_DIR.is_dir():
        for path in sorted(STYLES_DIR.glob("*.json")):
            try:
                manifests.append(json.loads(path.read_text(encoding="utf-8")))
            except json.JSONDecodeError as exc:
                print(f"style-render: manifesto inválido {path}: {exc}", file=sys.stderr)
    for manifest in manifests:
        if wanted.lower() in (str(manifest.get("id", "")).lower(), str(manifest.get("name", "")).lower()):
            return manifest
    for manifest in manifests:
        if manifest.get("id") == "padrao":
            return manifest
    raise SystemExit(f"style-render: nenhum manifesto encontrado em {STYLES_DIR}")


def apply_manifest_presets(settings: dict[str, str], manifest: dict) -> dict[str, str]:
    merged = dict(settings)
    hypr = manifest.get("hypr", {})
    for key in PRESET_KEYS:
        if key in hypr:
            merged[key] = str(hypr[key])
    if "opacity" in manifest.get("waybar", {}):
        merged["WAYBAR_OP"] = str(manifest["waybar"]["opacity"])
    if "opacity" in manifest.get("kitty", {}):
        merged["KITTY_OP"] = str(manifest["kitty"]["opacity"])
    merged["STYLE"] = str(manifest.get("name", merged.get("STYLE", "Padrão")))
    return merged


def ensure_state() -> None:
    STATE_DIR.mkdir(parents=True, exist_ok=True)


def render_waybar(manifest: dict, settings: dict[str, str], quiet: bool) -> None:
    base = load_jsonc(WAYBAR_BASE)
    waybar = manifest.get("waybar", {})
    for key, manifest_key in (
        ("height", "height"),
        ("margin-top", "margin_top"),
        ("margin-left", "margin_left"),
        ("margin-right", "margin_right"),
    ):
        if manifest_key in waybar:
            base[key] = waybar[manifest_key]

    out_dir = STATE_DIR / "waybar"
    out_dir.mkdir(parents=True, exist_ok=True)
    (out_dir / "config.jsonc").write_text(
        json.dumps(base, indent=4, ensure_ascii=False) + "\n", encoding="utf-8"
    )

    colors_src = CONFIG_DIR / "waybar" / "colors.css"
    colors_dst = out_dir / "colors.css"
    if colors_dst.exists() or colors_dst.is_symlink():
        colors_dst.unlink()
    if colors_src.exists():
        colors_dst.symlink_to(colors_src)
    else:
        colors_dst.write_text(FALLBACK_COLORS_CSS, encoding="utf-8")

    style_id = manifest.get("id", "padrao")
    template = WAYBAR_THEMES / style_id / "style.css"
    if template.exists():
        css = template.read_text(encoding="utf-8")
    elif WAYBAR_FALLBACK.exists():
        css = WAYBAR_FALLBACK.read_text(encoding="utf-8")
    else:
        css = ""

    opacity = settings.get("WAYBAR_OP", waybar.get("opacity", 0.5))
    radius = waybar.get("radius", 14)
    css = css.replace("{{opacity}}", str(opacity)).replace("{{radius}}", str(radius))
    if "{{" in css:
        raise SystemExit(f"style-render: token não substituído em {template}")
    (out_dir / "style.css").write_text(css, encoding="utf-8")
    if not quiet:
        print(f"waybar: {style_id} (opacidade {opacity}, raio {radius})")


def render_kitty(manifest: dict, settings: dict[str, str], quiet: bool) -> None:
    out_dir = STATE_DIR / "kitty"
    out_dir.mkdir(parents=True, exist_ok=True)
    opacity = settings.get("KITTY_OP", manifest.get("kitty", {}).get("opacity", 0.5))
    (out_dir / "style.conf").write_text(f"background_opacity {opacity}\n", encoding="utf-8")
    if not quiet:
        print(f"kitty: opacidade {opacity}")


def render_fuzzel(manifest: dict, quiet: bool) -> None:
    out_dir = STATE_DIR / "fuzzel"
    out_dir.mkdir(parents=True, exist_ok=True)
    fuzzel = manifest.get("fuzzel", {})
    width = fuzzel.get("border_width", 2)
    radius = fuzzel.get("border_radius", 16)
    (out_dir / "overrides.env").write_text(
        f"FUZZEL_BORDER_WIDTH={width}\nFUZZEL_BORDER_RADIUS={radius}\n", encoding="utf-8"
    )
    if not quiet:
        print(f"fuzzel: borda {width}px, raio {radius}px")


def render_hyprlock(manifest: dict, quiet: bool) -> None:
    out_dir = STATE_DIR / "hyprlock"
    out_dir.mkdir(parents=True, exist_ok=True)
    lock_id = manifest.get("hyprlock", manifest.get("id", "padrao"))
    source = LOCK_STYLES / f"{lock_id}.conf"
    if not source.exists():
        source = LOCK_STYLES / "padrao.conf"
    if not source.exists():
        print(f"style-render: lock style não encontrado em {LOCK_STYLES}", file=sys.stderr)
        return
    (out_dir / "style.conf").write_text(source.read_text(encoding="utf-8"), encoding="utf-8")
    if not quiet:
        print(f"hyprlock: {source.stem}")


def render_mako(manifest: dict, quiet: bool) -> None:
    if not MAKO_COLORS.exists():
        if not quiet:
            print("style-render: mako/colors.part ausente; troque o wallpaper uma vez", file=sys.stderr)
        return
    mako = manifest.get("mako", {})
    body = MAKO_COLORS.read_text(encoding="utf-8").replace("@ALPHA@", str(mako.get("alpha", "ee")))
    if mako.get("glass_border"):
        body = re.sub(r"^border-color=.*$", "border-color=#ffffff59", body, count=1, flags=re.M)
    header = (
        "font=JetBrainsMono Nerd Font 11\n"
        f"border-size={mako.get('border_size', 2)}\n"
        f"border-radius={mako.get('border_radius', 12)}\n"
        f"padding={mako.get('padding', 12)}\n"
        f"margin={mako.get('margin', 10)}\n"
        f"width={mako.get('width', 340)}\n"
        "default-timeout=6000\n"
        "anchor=top-right\n"
        "layer=overlay\n\n"
    )
    MAKO_CONFIG.parent.mkdir(parents=True, exist_ok=True)
    MAKO_CONFIG.write_text(header + body, encoding="utf-8")
    subprocess.run(
        ["makoctl", "reload"],
        check=False,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )
    if not quiet:
        print("mako: config atualizada")


def render_rofi(manifest: dict, quiet: bool) -> None:
    out_dir = STATE_DIR / "rofi"
    out_dir.mkdir(parents=True, exist_ok=True)
    overrides = str(manifest.get("rofi", {}).get("overrides", ""))
    (out_dir / "overrides.rasi").write_text(overrides + ("\n" if overrides else ""), encoding="utf-8")
    if not quiet:
        print("rofi: overrides do wallpaper picker")


def render_resolved(manifest: dict, settings: dict[str, str], quiet: bool) -> None:
    ensure_state()
    resolved = copy.deepcopy(manifest)
    resolved["settings"] = {key: settings.get(key) for key in PRESET_KEYS + ("WAYBAR_OP", "KITTY_OP", "STYLE")}
    resolved.setdefault("waybar", {})["opacity"] = float(
        settings.get("WAYBAR_OP", manifest.get("waybar", {}).get("opacity", 0.5))
    )
    resolved.setdefault("kitty", {})["opacity"] = float(
        settings.get("KITTY_OP", manifest.get("kitty", {}).get("opacity", 0.5))
    )
    (STATE_DIR / "style.json").write_text(
        json.dumps(resolved, indent=2, ensure_ascii=False) + "\n", encoding="utf-8"
    )
    if not quiet:
        print(f"estado: {STATE_DIR / 'style.json'}")


def print_preset(manifest: dict) -> None:
    hypr = manifest.get("hypr", {})
    values = {key: hypr.get(key, "") for key in PRESET_KEYS}
    values["WAYBAR_OP"] = manifest.get("waybar", {}).get("opacity", 0.5)
    values["KITTY_OP"] = manifest.get("kitty", {}).get("opacity", 0.5)
    values["STYLE"] = manifest.get("name", "Padrão")
    for key, value in values.items():
        print(f"{key}={shlex.quote(str(value))}")


def main() -> int:
    parser = argparse.ArgumentParser(description="Renderiza o estilo atual do rice.")
    parser.add_argument("--style", help="nome ou id do estilo (Padrão, Liquid Glass, Omarchy)")
    parser.add_argument("--all", action="store_true", help="renderiza todas as saídas")
    parser.add_argument("--waybar", action="store_true")
    parser.add_argument("--kitty", action="store_true")
    parser.add_argument("--fuzzel", action="store_true")
    parser.add_argument("--hyprlock", action="store_true")
    parser.add_argument("--mako", action="store_true")
    parser.add_argument("--rofi", action="store_true")
    parser.add_argument("--resolved", action="store_true")
    parser.add_argument("--print-preset-shell", action="store_true")
    parser.add_argument("--print-style-id", action="store_true")
    parser.add_argument("--quiet", action="store_true")
    args = parser.parse_args()

    settings = load_settings()
    manifest = find_manifest(args.style, settings)
    if args.style:
        settings = apply_manifest_presets(settings, manifest)

    if args.print_preset_shell:
        print_preset(manifest)
        return 0
    if args.print_style_id:
        print(manifest.get("id", "padrao"))
        return 0

    ensure_state()
    selected = {
        "waybar": args.waybar,
        "kitty": args.kitty,
        "fuzzel": args.fuzzel,
        "hyprlock": args.hyprlock,
        "mako": args.mako,
        "rofi": args.rofi,
        "resolved": args.resolved,
    }
    if args.all or not any(selected.values()):
        selected = {key: True for key in selected}

    if selected["waybar"]:
        render_waybar(manifest, settings, args.quiet)
    if selected["kitty"]:
        render_kitty(manifest, settings, args.quiet)
    if selected["fuzzel"]:
        render_fuzzel(manifest, args.quiet)
    if selected["hyprlock"]:
        render_hyprlock(manifest, args.quiet)
    if selected["mako"]:
        render_mako(manifest, args.quiet)
    if selected["rofi"]:
        render_rofi(manifest, args.quiet)
    if selected["resolved"]:
        render_resolved(manifest, settings, args.quiet)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
