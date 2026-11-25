-- -----------------------------------------------------
-- System Config
-- -----------------------------------------------------
local mainMod = "SUPER"

hl.bind(mainMod .. " + SHIFT + M", hl.dsp.exit())
hl.bind(mainMod .. " + SHIFT + R", hl.dsp.exec_cmd("hyprctl reload"))
hl.bind(mainMod .. " + SHIFT + Q", hl.dsp.exec_cmd("shutdown now"))
hl.bind(mainMod .. " + SPACE",     hl.dsp.exec_cmd("~/.config/hypr/scripts/cambioTeclado.sh"))
hl.bind(mainMod .. " + L",         hl.dsp.exec_cmd("hyprlock"))

-- Tapa: al cerrarla solo se apaga la pantalla, todo sigue corriendo.
-- (Requiere HandleLidSwitch=ignore en /etc/systemd/logind.conf.d/ para que
-- systemd no suspenda.) Al abrirla vuelve la pantalla.
hl.bind("switch:on:Lid Switch",  hl.dsp.exec_cmd([[hyprctl dispatch 'hl.dsp.dpms({ action = "disable" })']]), { locked = true })
hl.bind("switch:off:Lid Switch", hl.dsp.exec_cmd([[hyprctl dispatch 'hl.dsp.dpms({ action = "enable" })']]),  { locked = true })

-- Apagado "de verdad" sin perder nada: hiberna (guarda todo al disco y
-- corta la energía, consumo 0). Al prender vuelve todo como estaba.
hl.bind(mainMod .. " + SHIFT + H", hl.dsp.exec_cmd("systemctl hibernate"))
