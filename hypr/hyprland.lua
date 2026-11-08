-- ==============================================================================
-- CONFIGURACIÓN COMPLETA DE HYPRLAND (Lua, Hyprland >= 0.57)
-- ==============================================================================
-- Desde 0.57 Hyprland solo lee hyprland.lua (el formato .conf/hyprlang se quitó).
-- Este archivo solo carga los módulos de conf/. Cada require corre en su propio
-- scope: si un módulo tiene un error, los demás siguen cargando.

-- Monitores: conf/monitors.lua lo genera scripts/detect_monitor_scale.sh y está
-- ignorado por git. Si todavía no existe, usar un valor por defecto.
if not pcall(require, "conf.monitors") then
    hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
end

require("conf.autostart")
require("conf.environment")
require("conf.input")
require("conf.general")
require("conf.windowrules")

-- Atajos de teclado por categoría
require("conf.keybinds.apps")
require("conf.keybinds.workspaces")
require("conf.keybinds.window")
require("conf.keybinds.system")
require("conf.keybinds.media")
