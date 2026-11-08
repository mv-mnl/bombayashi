-- -----------------------------------------------------
-- System Config
-- -----------------------------------------------------
local mainMod = "SUPER"

hl.bind(mainMod .. " + SHIFT + M", hl.dsp.exit())
hl.bind(mainMod .. " + SHIFT + R", hl.dsp.exec_cmd("hyprctl reload"))
hl.bind(mainMod .. " + SHIFT + Q", hl.dsp.exec_cmd("shutdown now"))
hl.bind(mainMod .. " + SPACE",     hl.dsp.exec_cmd("~/.config/hypr/scripts/cambioTeclado.sh"))
hl.bind(mainMod .. " + L",         hl.dsp.exec_cmd("hyprlock"))
