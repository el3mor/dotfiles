hl.on("hyprland.start", function()

    hl.exec_cmd("awww-daemon")
    hl.exec_cmd("waybar")
    hl.exec_cmd("swaync")
    hl.exec_cmd("hypridle")

    hl.exec_cmd("elephant")
    hl.exec_cmd("walker --gapplication-service")
end)
