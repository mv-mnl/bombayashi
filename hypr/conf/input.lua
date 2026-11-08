-- ------------------------------------------------------------------------------
-- 4. ENTRADA (Teclado y Ratón)
-- ------------------------------------------------------------------------------
hl.config({
    input = {
        kb_layout = "us,es", -- Cambia a 'latam' si usas teclado latinoamericano

        follow_mouse = 1,

        touchpad = {
            natural_scroll = true, -- Scroll como en los teléfonos
            tap_to_click   = true,
        },

        sensitivity = 0, -- -1.0 a 1.0, 0 es por defecto
    },
})

hl.device({
    name    = "elan2513:00-04f3:4038",
    enabled = false,
})
