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
hl.bind(mainMod .. " + SHIFT + E", hl.dsp.exec_cmd("~/.local/bin/estilo"))   -- cambiar de estilo (main / larpeo)

-- Rofi scripts
hl.bind(mainMod .. " + N",         hl.dsp.exec_cmd(rofi .. "network.sh"))
hl.bind(mainMod .. " + SHIFT + B", hl.dsp.exec_cmd(rofi .. "bluetooth.sh"))
hl.bind(mainMod .. " + K",         hl.dsp.exec_cmd(rofi .. "clipboard.sh"))
hl.bind(mainMod .. " + SHIFT + K", hl.dsp.exec_cmd(rofi .. "bitwarden.sh"))
hl.bind(mainMod .. " + X",         hl.dsp.exec_cmd(rofi .. "powermenu.sh"))
hl.bind(mainMod .. " + H",         hl.dsp.exec_cmd(rofi .. "ssh.sh"))
hl.bind(mainMod .. " + G",         hl.dsp.exec_cmd(rofi .. "workspace.sh"))
hl.bind(mainMod .. " + SHIFT + V", hl.dsp.exec_cmd(rofi .. "volume.sh"))
-- hl.bind(mainMod .. " + ...", hl.dsp.exec_cmd(rofi .. "brightness.sh"))
