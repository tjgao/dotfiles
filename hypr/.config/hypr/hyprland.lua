-- Hyprland Lua configuration migrated from the old hyprland.conf.
-- Hyprland 0.55+ uses Lua configuration.
--
-- Original configuration preserved as closely as possible:
--   /mnt/data/hyprland.conf

local home = os.getenv("HOME")
local localBin = home .. "/.local/bin"
local wallpaperDir = home .. "/Pictures/wallpapers"

local terminal = "kitty"
local fileManager = "nautilus"
local menu = "rofi -font 'TerminessTTF Nerd Font 18' -show-icons -show run"
local menu2 = "rofi -font 'TerminessTTF Nerd Font 18' -show-icons -show drun"
local browser = "flatpak run app.zen_browser.zen"
local mainMod = "SUPER"

local bind = hl.bind
local dsp = hl.dsp

-- ---------------------------------------------------------------------------
-- Monitor
-- ---------------------------------------------------------------------------

hl.monitor({
    output = "DP-1",
    mode = "preferred",
    position = "auto",
    scale = 1,
})

-- ---------------------------------------------------------------------------
-- Environment
-- ---------------------------------------------------------------------------

hl.env("XCURSOR_SIZE", "48")
hl.env("QT_QPA_PLATFORMTHEME", "qt5ct")
hl.env(
    "PATH",
    home
        .. "/.local/bin:"
        .. home
        .. "/.local/kitty.app/bin:"
        .. "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/opt/neovim/bin"
)
hl.env("GTK_IM_MODULE", "fcitx")
hl.env("QT_IM_MODULE", "fcitx")
hl.env("XMODIFIERS", "@im=fcitx")
hl.env("INPUT_METHOD_DEFAULT", "fcitx")
hl.env("GLFW_IM_MODULE", "local")

-- ---------------------------------------------------------------------------
-- Input
-- ---------------------------------------------------------------------------

hl.config({
    input = {
        kb_layout = "us",
        kb_variant = "",
        kb_model = "",
        kb_options = "",
        kb_rules = "",
        sensitivity = 0,
        repeat_delay = 230,
        repeat_rate = 40,

        touchpad = {
            natural_scroll = false,
        },
    },

    general = {
        gaps_in = 5,
        gaps_out = 15,
        border_size = 1,

        col = {
            active_border = {
                colors = {
                    "rgba(aaaaaaee)",
                    "rgba(aaaaaaee)",
                },
                angle = 45,
            },
            inactive_border = "rgba(373737aa)",
        },

        layout = "master",
        allow_tearing = false,
    },

    decoration = {
        rounding = 5,

        blur = {
            enabled = true,
            size = 3,
            passes = 1,
        },

        shadow = {
            enabled = true,
            range = 4,
            render_power = 3,
            color = "rgba(1a1a1aee)",
        },
    },

    animations = {
        enabled = true,
    },

    dwindle = {
        preserve_split = true,
    },

    master = {
        new_status = "slave",
    },

    misc = {
        force_default_wallpaper = -1,
        enable_swallow = true,
        swallow_regex = "^(Alacritty|kitty|footclient)$",
        disable_splash_rendering = true,
        disable_hyprland_logo = true,
    },

    binds = {
        allow_workspace_cycles = true,
    },
})

-- ---------------------------------------------------------------------------
-- Animations
-- ---------------------------------------------------------------------------

hl.curve("myBezier", {
    type = "bezier",
    points = {
        { 0.05, 0.9 },
        { 0.1, 1.05 },
    },
})

hl.animation({
    leaf = "windows",
    enabled = true,
    speed = 5,
    bezier = "myBezier",
})

hl.animation({
    leaf = "windowsOut",
    enabled = true,
    speed = 7,
    bezier = "default",
    style = "popin 80%",
})

hl.animation({
    leaf = "border",
    enabled = true,
    speed = 10,
    bezier = "default",
})

hl.animation({
    leaf = "borderangle",
    enabled = true,
    speed = 8,
    bezier = "default",
})

hl.animation({
    leaf = "fade",
    enabled = true,
    speed = 7,
    bezier = "default",
})

hl.animation({
    leaf = "workspaces",
    enabled = true,
    speed = 3,
    bezier = "default",
})

-- ---------------------------------------------------------------------------
-- Per-device configuration
-- ---------------------------------------------------------------------------

hl.device({
    name = "epic-mouse-v1",
    sensitivity = -0.5,
})

-- ---------------------------------------------------------------------------
-- Window rules
-- ---------------------------------------------------------------------------

hl.window_rule({
    match = {
        class = ".*",
    },
    suppress_event = "maximize",
})

-- ---------------------------------------------------------------------------
-- Startup
-- ---------------------------------------------------------------------------
--
-- exec-once is represented by the hyprland.start event in the Lua config.
-- hl.exec_cmd() is asynchronous and uses a shell, so the original command
-- substitutions, globs, pipes and redirections continue to work.

hl.on("hyprland.start", function()
    -- Keep dbus/systemd user activation environment in sync with this session.
    hl.exec_cmd(
        "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE HYPRLAND_INSTANCE_SIGNATURE"
    )

    -- On non-uwsm sessions, xdg-desktop-portal may fail systemd deps.
    -- Start a local portal backend fallback so browser idle-inhibit can work.
    hl.exec_cmd("pidof xdg-desktop-portal >/dev/null || /usr/libexec/xdg-desktop-portal")
    hl.exec_cmd("pidof xdg-desktop-portal-gtk >/dev/null || /usr/libexec/xdg-desktop-portal-gtk")

    hl.exec_cmd("waybar")
    hl.exec_cmd("swaync")
    hl.exec_cmd("fcitx5")
    -- hl.exec_cmd("hypridle >> /tmp/hypridle.log")
    hl.exec_cmd("hyprpaper")
    hl.exec_cmd("nm-applet --indicator")
    hl.exec_cmd("blueman-applet")

    hl.exec_cmd(
        localBin
            .. "/swww.py --bin-path "
            .. localBin
            .. ' --daemon --image "$(ls -d '
            .. wallpaperDir
            .. '/* | shuf | head -n1)"'
    )

    hl.exec_cmd(
        localBin .. "/swww.py --bin-path " .. localBin .. " --period 1800 --image-list " .. wallpaperDir .. "/*"
    )

    hl.exec_cmd("fcitx5 -d")
end)

-- ---------------------------------------------------------------------------
-- Key bindings
-- ---------------------------------------------------------------------------

-- Programs
bind(mainMod .. " + Return", dsp.exec_cmd(terminal))
bind(mainMod .. " + Escape", dsp.window.close())
bind(mainMod .. " + SHIFT + Escape", dsp.exec_cmd("wlogout -b 4"))
bind(mainMod .. " + E", dsp.exec_cmd(fileManager))
bind(mainMod .. " + F", dsp.window.fullscreen())
bind(
    mainMod .. " + SHIFT + I",
    dsp.exec_cmd(localBin .. "/swww.py --bin-path " .. localBin .. " --image-list " .. wallpaperDir .. "/*")
)

bind(mainMod .. " + N", dsp.exec_cmd("swaync-client -t -sw"))
bind(mainMod .. " + R", dsp.exec_cmd("$(pidof waybar && killall -9 waybar) || waybar"))
bind(mainMod .. " + V", dsp.window.float({ action = "toggle" }))
bind(mainMod .. " + W", dsp.exec_cmd(browser))
bind(mainMod .. " + B", dsp.exec_cmd("killall -SIGUSR1 waybar"))
bind(mainMod .. " + SHIFT + L", dsp.exec_cmd("hyprlock"))
bind(mainMod .. " + SPACE", dsp.exec_cmd(menu))
bind(mainMod .. " + SHIFT + SPACE", dsp.exec_cmd(menu2))

-- Master layout
bind(mainMod .. " + COMMA", dsp.layout("swapwithmaster"))
bind(mainMod .. " + PERIOD", dsp.layout("swapprev"))

-- Previous workspace
bind(mainMod .. " + TAB", dsp.focus({ workspace = "previous" }))

-- Volume
bind(mainMod .. " + Page_Up", dsp.exec_cmd("amixer -q set Master 5%+"))
bind(mainMod .. " + Page_Down", dsp.exec_cmd("amixer -q set Master 5%-"))
bind(mainMod .. " + SHIFT + Page_Up", dsp.exec_cmd("amixer -q set Master 1%+"))
bind(mainMod .. " + SHIFT + Page_Down", dsp.exec_cmd("amixer -q set Master 1%-"))
bind(mainMod .. " + Home", dsp.exec_cmd("amixer -q set Master 0%"))
bind(mainMod .. " + End", dsp.exec_cmd("amixer -q set Master 100%"))
bind(mainMod .. " + INSERT", dsp.exec_cmd(localBin .. "/switch_audio.sh"))

-- Screenshots
bind(mainMod .. " + PRINT", dsp.exec_cmd(localBin .. "/screenshot.py --clipboard --notify"))
bind(mainMod .. " + SHIFT + PRINT", dsp.exec_cmd(localBin .. "/screenshot.py --notify"))
bind("CTRL + PRINT", dsp.exec_cmd(localBin .. "/screenshot.py --clipboard --full --notify"))
bind("CTRL + ALT + PRINT", dsp.exec_cmd(localBin .. "/screenshot.py --full --notify"))

-- Focus movement
bind(mainMod .. " + L", dsp.focus({ direction = "left" }))
bind(mainMod .. " + H", dsp.focus({ direction = "right" }))
bind(mainMod .. " + K", dsp.focus({ direction = "up" }))
bind(mainMod .. " + J", dsp.focus({ direction = "down" }))

-- Resize windows (equivalent to old binde = ..., resizeactive ...).
bind(mainMod .. " + SHIFT + RIGHT", dsp.window.resize({ x = 10, y = 0, relative = true }), { repeating = true })
bind(mainMod .. " + SHIFT + LEFT", dsp.window.resize({ x = -10, y = 0, relative = true }), { repeating = true })
bind(mainMod .. " + SHIFT + UP", dsp.window.resize({ x = 0, y = -10, relative = true }), { repeating = true })
bind(mainMod .. " + SHIFT + DOWN", dsp.window.resize({ x = 0, y = 10, relative = true }), { repeating = true })

-- Switch workspaces
for i = 1, 9 do
    bind(mainMod .. " + " .. i, dsp.focus({ workspace = i }))
end
bind(mainMod .. " + 0", dsp.focus({ workspace = 10 }))

-- Move active window to a workspace
for i = 1, 9 do
    bind(mainMod .. " + SHIFT + " .. i, dsp.window.move({ workspace = i }))
end
bind(mainMod .. " + SHIFT + 0", dsp.window.move({ workspace = 10 }))

-- Scratchpads
bind(mainMod .. " + Y", dsp.exec_cmd(localBin .. "/scratchpads.py --name yazi"))
bind(mainMod .. " + U", dsp.exec_cmd(localBin .. "/scratchpads.py --name kitty"))

-- Scroll through existing workspaces
bind(mainMod .. " + mouse_down", dsp.focus({ workspace = "e+1" }))
bind(mainMod .. " + mouse_up", dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mouse
bind(mainMod .. " + mouse:272", dsp.window.drag(), { mouse = true })
bind(mainMod .. " + mouse:273", dsp.window.resize(), { mouse = true })

-- End of configuration
