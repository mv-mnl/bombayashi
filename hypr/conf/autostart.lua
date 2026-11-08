-- ------------------------------------------------------------------------------
-- 2. INICIO AUTOMÁTICO (Autostart)
-- ------------------------------------------------------------------------------
hl.on("hyprland.start", function()
    hl.exec_cmd("waybar & hyprpaper & swaync")
    hl.exec_cmd("~/.config/hypr/scripts/wallpaper.sh")
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
    hl.exec_cmd("~/.config/hypr/scripts/detect_monitor_scale.sh")
    hl.exec_cmd("~/.config/hypr/scripts/sync_dotfiles.sh")
    hl.exec_cmd("nm-applet --indicator")
    hl.exec_cmd("hypridle")
    -- Gestor de autenticación (Necesario para apps que piden contraseña de root)
    hl.exec_cmd("/usr/lib/polkit-kde-authentication-agent-1")

    -- Lanzar en el arranque directamente al espacio oculto
    hl.exec_cmd("bash -c 'sleep 5 && easyeffects'")
end)
