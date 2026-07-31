local walcolors = dofile(os.getenv("HOME") .. "/.cache/wal/hyprland-colors.lua")

hl.config({

    general = {

        gaps_in = 3,
        gaps_out = 10,

        border_size = 2,

        col = {
           active_border = "rgba(" .. walcolors.color4 .. "ee)",
                

            inactive_border = "rgba(595959aa)"
        },

        resize_on_border = false,
        allow_tearing = false,
        layout = "dwindle",
    },

    decoration = {
	    
        rounding = 8,
        rounding_power = 3,

        active_opacity = 0.96,
        inactive_opacity = 0.92,

        shadow = {
            enabled = true,

            range = 18,

            render_power = 3,

            color = "rgba(00000066)",
        },

        blur = {
            enabled = true,

            size = 8,

            passes = 4,

            vibrancy = 0.25,

            noise = 0.0,

            new_optimizations = true,
        },
    },

    dwindle = {
        preserve_split = true,
    },

    master = {
        new_status = "master",
    },

    misc = {
        force_default_wallpaper = -1,
        disable_hyprland_logo = true,
        
    }

})

hl.layer_rule({ match = { namespace = "waybar" }, blur = false })
