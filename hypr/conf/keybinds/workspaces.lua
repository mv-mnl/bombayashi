-- -----------------------------------------------------
-- Workspaces Config
-- -----------------------------------------------------
local mainMod = "SUPER"

for i = 1, 10 do
    local key = i % 10 -- el workspace 10 va en la tecla 0

    -- Cambiar de Espacio de Trabajo (SUPER + 1-0)
    hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))

    -- Mover ventana activa a un Espacio de Trabajo (SUPER + SHIFT + 1-0)
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))

    -- Espacios especiales (SUPER + CTRL + 1-0): saltar/mostrar-ocultar apps
    -- que uso de vez en cuando pero no quiero en el ciclo de Super+Tab
    hl.bind(mainMod .. " + CTRL + " .. key, hl.dsp.workspace.toggle_special("s" .. i))

    -- Mover la ventana activa a un espacio especial (SUPER + ALT + 1-0)
    -- Para traerla de vuelta a lo normal, usá SUPER + SHIFT + 1-0
    hl.bind(mainMod .. " + ALT + " .. key, hl.dsp.window.move({ workspace = "special:s" .. i }))
end

-- Navegación rápida con rueda del ratón
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Cambiar de espacio de trabajo con SUPER + TAB / SUPER + SHIFT + TAB
hl.bind(mainMod .. " + TAB",         hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + SHIFT + TAB", hl.dsp.focus({ workspace = "e-1" }))
