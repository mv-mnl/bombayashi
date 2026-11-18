-- -----------------------------------------------------
-- System Config
-- -----------------------------------------------------
local mainMod = "SUPER"

hl.bind(mainMod .. " + SHIFT + M", hl.dsp.exit())
hl.bind(mainMod .. " + CTRL + R",  hl.dsp.exec_cmd("hyprctl reload"))   -- SUPER+SHIFT+R es el menú de rofi
hl.bind(mainMod .. " + SHIFT + Q", hl.dsp.exec_cmd("shutdown now"))
hl.bind(mainMod .. " + SPACE",     hl.dsp.exec_cmd("~/.config/hypr/scripts/cambioTeclado.sh"))
hl.bind(mainMod .. " + L",         hl.dsp.exec_cmd("hyprlock"))
