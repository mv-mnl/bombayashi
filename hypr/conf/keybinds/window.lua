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

-- Redimensionar con el teclado (SUPER + CTRL + flechas, se puede mantener):
-- la flecha mueve el borde entre ventanas hacia ese lado
local step = 40
local resizeBy = { left = { -step, 0 }, right = { step, 0 }, up = { 0, -step }, down = { 0, step } }
for dir, d in pairs(resizeBy) do
    hl.bind(mainMod .. " + CTRL + " .. dir,
        hl.dsp.window.resize({ x = d[1], y = d[2], relative = true }),
        { repeating = true })
end

-- Ventana flotante (SUPER + SHIFT + F): alterna flotante / mosaico. Al hacerla
-- flotante la deja al 60% del monitor y centrada. Ya flotando:
--   SUPER + ALT + flechas   -> moverla (se puede mantener)
--   SUPER + CTRL + flechas  -> redimensionarla
--   SUPER + clic izq / der  -> moverla / redimensionarla con el mouse
function toggleFloating()
    local w = hl.get_active_window()
    if not w then return end
    local wasFloating = w.floating
    hl.dispatch(hl.dsp.window.float())
    if not wasFloating then
        local m = hl.get_active_monitor()
        local scale = (m and m.scale and m.scale > 0) and m.scale or 1
        local mw = (m and m.width) and math.floor(m.width / scale) or 2133
        local mh = (m and m.height) and math.floor(m.height / scale) or 1200
        hl.dispatch(hl.dsp.window.resize({ x = math.floor(mw * 0.6), y = math.floor(mh * 0.6) }))
        hl.dispatch(hl.dsp.window.center())
    end
end
hl.bind(mainMod .. " + SHIFT + F", toggleFloating)

local moveBy = { left = { -step, 0 }, right = { step, 0 }, up = { 0, -step }, down = { 0, step } }
for dir, d in pairs(moveBy) do
    hl.bind(mainMod .. " + ALT + " .. dir,
        hl.dsp.window.move({ x = d[1], y = d[2], relative = true }),
        { repeating = true })
end

-- Mover y redimensionar ventanas con el ratón
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Ciclar ventanas del workspace con ALT + Tab
-- (SUPER + Tab ya cambia de workspace, ver workspaces.lua)
hl.bind("ALT + Tab",         hl.dsp.window.cycle_next())

-- cambiar de orientación
hl.bind(mainMod .. " + O",   hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + I",   hl.dsp.window.swap({ next = true }))
