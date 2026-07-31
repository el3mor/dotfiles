--------------------------------------------------
-- Window Rules
--------------------------------------------------

-- Ignore maximize requests
hl.window_rule({
    name = "suppress-maximize-events",

    match = {
        class = ".*",
    },

    suppress_event = "maximize",
})

-- Fix dragging issues with XWayland
hl.window_rule({
    name = "fix-xwayland-drags",

    match = {
        class = "^$",
        title = "^$",
        xwayland = true,
        float = true,
        fullscreen = false,
        pin = false,
    },

    no_focus = true,
})

-- Hyprland Run
hl.window_rule({
    name = "move-hyprland-run",

    match = {
        class = "hyprland-run",
    },

    move = "20 monitor_h-120",
    float = true,
})

--------------------------------------------------
-- Workspace Rules
--------------------------------------------------

-- Examples:
-- hl.workspace_rule({
--     workspace = "w[tv1]",
--     gaps_out = 0,
--     gaps_in = 0,
-- })

-- hl.workspace_rule({
--     workspace = "f[1]",
--     gaps_out = 0,
--     gaps_in = 0,
-- })

--------------------------------------------------
-- Layer Rules
--------------------------------------------------

-- Example:
-- hl.layer_rule({
--     name = "no-anim-overlay",
--
--     match = {
--         namespace = "^my-overlay$",
--     },
--
--     no_anim = true,
-- })
--
--
-- --------------------------------------------------
-- Waybar
--------------------------------------------------

--hl.layer_rule({
	
  --  name = "waybar",

    --match = {
      --  namespace = "waybar"
    --},

    --blur = true,
--})

--------------------------------------------------
-- SwayNC
--------------------------------------------------

hl.layer_rule({
    name = "swaync",

    match = {
        namespace = "^swaync-control-center$",
    },

    blur = true,
})

--hl.layer_rule({
  --  name = "swaync-notifications",

    --match = {
      --  namespace = "^swaync-notification-window$",
    --},

    --blur = true,
--})
--
--
hl.window_rule({
    name = "kitty",

    match = {
        class = "kitty",
    },

    opacity = "0.85 0.80",
})

hl.window_rule({
    name = "zen-browser",

    match = {
        class = "zen",
    },

    opacity = "0.96 0.92",
})
