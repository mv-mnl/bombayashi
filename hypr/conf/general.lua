-- ------------------------------------------------------------------------------
-- 5. APARIENCIA GENERAL Y BORDES
-- ------------------------------------------------------------------------------
hl.config({
    general = {
        gaps_in  = 5,
        -- pegado a la barra (quickshell), izquierda y derecha
        gaps_out = { top = 0, right = 0, bottom = 10, left = 0 },
        border_size = 2,

        -- Colores de bordes (escala de grises)
        col = {
            active_border   = { colors = { "rgba(ffffffee)", "rgba(808080ee)" }, angle = 45 },
            inactive_border = "rgba(333333aa)",
        },

        layout = "dwindle", -- Alternativa: master

        -- Redimensionar arrastrando el borde/espacio entre ventanas con el mouse
        resize_on_border         = true,
        extend_border_grab_area  = 15,   -- px extra alrededor del borde para agarrarlo
        hover_icon_on_border     = true, -- cursor de redimensionar al pasar por el borde
    },

    -- --------------------------------------------------------------------------
    -- 8. AJUSTES DE LAYOUT (Dwindle)
    -- --------------------------------------------------------------------------
    dwindle = {
        force_split    = 2, -- 0 -> sigue el ratón, 1 -> siempre izquierda/arriba, 2 -> siempre derecha/abajo
        preserve_split = true,
    },

    -- --------------------------------------------------------------------------
    -- 9. MISCELÁNEOS
    -- --------------------------------------------------------------------------
    misc = {
        disable_hyprland_logo    = true,
        disable_splash_rendering = true,
    },
})
