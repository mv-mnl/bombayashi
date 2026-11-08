-- -----------------------------------------------------
-- Window Management Config
-- -----------------------------------------------------
local mainMod = "SUPER"

hl.bind(mainMod .. " + C", hl.dsp.window.close())
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())          -- dwindle
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))    -- dwindle
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen())

for _, dir in ipairs({ "left", "right", "up", "down" }) do
    -- Foco de ventanas (SUPER + flechas)
    hl.bind(mainMod .. " + " .. dir, hl.dsp.focus({ direction = dir }))
    -- Mover ventanas de posición (SUPER + SHIFT + flechas)
    hl.bind(mainMod .. " + SHIFT + " .. dir, hl.dsp.window.move({ direction = dir }))
end

-- Mover y redimensionar ventanas con el ratón
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- cambiar de orientación
hl.bind(mainMod .. " + Tab", hl.dsp.window.cycle_next())
hl.bind(mainMod .. " + O",   hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + I",   hl.dsp.window.swap({ next = true }))
