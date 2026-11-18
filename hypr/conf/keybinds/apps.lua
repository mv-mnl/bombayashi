-- -----------------------------------------------------
-- Apps Config
-- -----------------------------------------------------
local mainMod = "SUPER"
local rofi = "~/.config/rofi/scripts/"

hl.bind(mainMod .. " + Return",    hl.dsp.exec_cmd("kitty"))
hl.bind(mainMod .. " + R",         hl.dsp.exec_cmd("rofi -show drun"))
hl.bind(mainMod .. " + SHIFT + R", hl.dsp.exec_cmd(rofi .. "menu.sh"))
hl.bind(mainMod .. " + B",         hl.dsp.exec_cmd("firefox"))
hl.bind(mainMod .. " + E",         hl.dsp.workspace.toggle_special("audio"))

-- Paneles de la isla (quickshell) y menús de rofi
hl.bind(mainMod .. " + SHIFT + N", hl.dsp.exec_cmd("qs ipc call panel toggle wifi"))
hl.bind(mainMod .. " + SHIFT + B", hl.dsp.exec_cmd("qs ipc call panel toggle bluetooth"))
hl.bind(mainMod .. " + K",         hl.dsp.exec_cmd("qs ipc call panel toggle clipboard"))
hl.bind(mainMod .. " + SHIFT + K", hl.dsp.exec_cmd(rofi .. "bitwarden.sh"))
hl.bind(mainMod .. " + X",         hl.dsp.exec_cmd("qs ipc call panel toggle power"))
hl.bind(mainMod .. " + H",         hl.dsp.exec_cmd(rofi .. "ssh.sh"))
hl.bind(mainMod .. " + G",         hl.dsp.exec_cmd(rofi .. "workspace.sh"))
hl.bind(mainMod .. " + SHIFT + V", hl.dsp.exec_cmd("qs ipc call panel toggle audio"))
-- hl.bind(mainMod .. " + ...", hl.dsp.exec_cmd(rofi .. "brightness.sh"))

-- Isla dinámica (quickshell): abrir/cerrar el panel expandido
hl.bind(mainMod .. " + A",         hl.dsp.exec_cmd("qs ipc call island toggle"))
hl.bind(mainMod .. " + S",         hl.dsp.exec_cmd("qs ipc call settings toggle"))   -- pantalla de ajustes
hl.bind(mainMod .. " + F1",        hl.dsp.exec_cmd("qs ipc call settings open 4"))   -- ayuda completa
hl.bind(mainMod .. " + W",         hl.dsp.exec_cmd("qs ipc call settings picker"))   -- carrusel de fondos
hl.bind(mainMod .. " + N",         hl.dsp.exec_cmd("qs ipc call panel toggle notifications")) -- centro de notificaciones
hl.bind(mainMod .. " + CTRL + N",  hl.dsp.exec_cmd("qs ipc call notifs dnd"))                 -- No molestar
