-- ~/.config/hypr/hyprland.lua  (rice com matugen)
-- Cores dinâmicas geradas pelo matugen em ~/.config/hypr/colors.lua
local ok, c = pcall(require, "colors")
if not ok then
    c = {
        primary = "rgba(cba6f7ff)", tertiary = "rgba(89b4faff)",
        outline_variant = "rgba(595959aa)",
    }
end

------------------ MONITOR ------------------
hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = "auto",
})

------------------ PROGRAMAS ------------------
local terminal = "kitty"
local menu     = "fuzzel"
local mainMod  = "SUPER"

------------------ AUTOSTART ------------------
hl.on("hyprland.start", function()
    hl.exec_cmd("~/.config/hypr/scripts/wallpaper.sh restore")
    hl.exec_cmd("waybar")
    hl.exec_cmd("mako")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("systemctl --user start hyprpolkitagent")
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
end)

------------------ ENV ------------------
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("QT_QPA_PLATFORM", "wayland")
hl.env("GTK_THEME", "adw-gtk3-dark")

------------------ VISUAL ------------------
hl.config({
    general = {
        gaps_in  = 5,
        gaps_out = 12,
        border_size = 2,

        col = {
            -- Borda branca. Para voltar ao tema dinâmico use:
            -- active_border = { colors = { c.primary, c.tertiary }, angle = 45 },
            active_border   = "rgba(ffffffff)",
            inactive_border = c.outline_variant,
        },

        resize_on_border = true,
        allow_tearing = false,
        layout = "dwindle",
    },

    decoration = {
        rounding       = 12,
        rounding_power = 2,
        active_opacity   = 1.0,
        inactive_opacity = 0.94,

        shadow = {
            enabled      = true,
            range        = 18,
            render_power = 3,
            color        = 0x66000000,
        },

        blur = {
            enabled   = true,
            size      = 4,
            passes    = 2,
            vibrancy  = 0.2,
            noise     = 0.02,
        },
    },

    animations = {
        enabled = true,
    },

    dwindle = {
        preserve_split = true,
    },

    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo   = true,
    },

    input = {
        kb_layout  = "br",
        kb_variant = "",
        kb_model   = "abnt2",
        kb_options = "",
        kb_rules   = "",
        follow_mouse = 1,
        sensitivity = 0,
        touchpad = {
            natural_scroll = true,
        },
    },
})

------------------ ANIMAÇÕES ------------------
-- GELATINA: mola subamortecida (passa do ponto e balança até assentar).
--   damping menor  = mais gelatina   (tente 8 a 18)
--   stiffness maior = mais rápida     (tente 150 a 300)
hl.curve("jelly",     { type = "spring", mass = 1, stiffness = 210, damping = 10 })
hl.curve("jellySoft", { type = "spring", mass = 1, stiffness = 170, damping = 14 })
hl.curve("smooth",    { type = "bezier", points = { {0.05, 0.9}, {0.1, 1.05} } })
hl.curve("snappy",    { type = "bezier", points = { {0.16, 1},   {0.3, 1}    } })

-- janelas: abrir, mover/redimensionar (pula e balança) e fechar
hl.animation({ leaf = "windows",     enabled = true, speed = 5, spring = "jelly" })
hl.animation({ leaf = "windowsIn",   enabled = true, speed = 5, spring = "jelly", style = "popin 55%" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 5, spring = "jelly" })
hl.animation({ leaf = "windowsOut",  enabled = true, speed = 3, bezier = "snappy", style = "popin 70%" })

-- launcher, notificações e barra: "pop" de gelatina
hl.animation({ leaf = "layersIn",    enabled = true, speed = 5, spring = "jellySoft", style = "popin 60%" })
hl.animation({ leaf = "layersOut",   enabled = true, speed = 3, bezier = "snappy",    style = "popin 70%" })

-- workspaces escorregam e balançam
hl.animation({ leaf = "workspaces",  enabled = true, speed = 6, spring = "jellySoft", style = "slidevert" })

-- opacidade e borda sem overshoot (senão pisca)
hl.animation({ leaf = "fade",   enabled = true, speed = 5,  bezier = "smooth" })
hl.animation({ leaf = "border", enabled = true, speed = 10, bezier = "smooth" })

------------------ BINDS ------------------

hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

for i = 1, 10 do
    local key = i % 10
    hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",  hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                  { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown",hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                  { locked = true, repeating = true })
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })

------------------ REGRAS ------------------
hl.window_rule({
    name  = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})

-- Blur leve atrás da Waybar
hl.layer_rule({
    name  = "waybar-blur",
    match = { namespace = "^waybar$" },
    blur = true,
    ignore_alpha = 0.1,
})

-- Launcher (fuzzel): cai do topo e quica
hl.layer_rule({
    name  = "launcher-anim",
    match = { namespace = "^launcher$" },
    animation = "slide top",
})

-- Ajustes feitos pelo menu de controle (sobrescrevem os valores acima)
pcall(require, "settings")

