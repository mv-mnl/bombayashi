-- ------------------------------------------------------------------------------
-- 10. REGLAS DE VENTANAS (Window Rules)
-- ------------------------------------------------------------------------------
hl.window_rule({
    name  = "easyeffects-special",
    match = { class = "^(com.github.wwmm.easyeffects)$" },

    workspace = "special:audio silent",
})

-- Blur detrás de la barra / isla de quickshell (ignore_alpha evita
-- difuminar la parte transparente de la ventana)
hl.layer_rule({
    name  = "quickshell-bar-blur",
    match = { namespace = "^(quickshell-bar)$" },
    blur         = true,
    ignore_alpha = 0.5,
})

-- Pantalla de ajustes y menú de apagado: desenfocan todo lo de atrás
hl.layer_rule({
    name  = "quickshell-settings-blur",
    match = { namespace = "^(quickshell-(settings|power|wallpaper))$" },
    blur  = true,
})

-- Rofi: blur detrás de la ventana semitransparente + entrada tipo "popin"
hl.layer_rule({
    name  = "rofi-style",
    match = { namespace = "^(rofi)$" },
    blur         = true,
    ignore_alpha = 0.3,
    animation    = "popin 85%",
})

-- btop (hypr/scripts/btop.sh): flotante y centrado, con los colores del tema
hl.window_rule({
    name  = "btop-float",
    match = { class = "^(btop-float)$" },
    float  = true,
    size   = "1280 800",
    center = true,
})

-- Ignorar cuando una app pide abrirse maximizada (kitty lo hace): así se
-- acomoda en el layout junto a las demás ventanas en vez de tapar todo.
-- SUPER + F (pantalla completa) sigue funcionando igual.
hl.window_rule({
    name  = "suppress-maximize",
    match = { class = ".*" },
    suppress_event = "maximize",
})
