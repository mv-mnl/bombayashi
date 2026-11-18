-- -----------------------------------------------------
-- Media & Screenshots Config
-- -----------------------------------------------------
local mainMod = "SUPER"
local audio = "~/.config/hypr/scripts/audio.sh"

-- Volumen (teclas multimedia)
-- Nota: apuntan a hypr/scripts/audio.sh y no a @DEFAULT_AUDIO_SINK@ directo,
-- porque ese sink por defecto es el virtual de EasyEffects (cosmético: su
-- volumen/mute no afecta lo que en verdad suena).
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd(audio .. " up"),   { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd(audio .. " down"), { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd(audio .. " mute-toggle"))

-- Brillo (teclas multimedia - requiere 'brightnessctl')
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl -c backlight s 5%+ && qs ipc call osd brightness"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -c backlight s 5%- && qs ipc call osd brightness"), { locked = true, repeating = true })

-- Captura de una región -> ~/Imágenes/Capturas y al portapapeles
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd(
    [[mkdir -p "$HOME/Imágenes/Capturas" && FILE="$HOME/Imágenes/Capturas/$(date +'%Y-%m-%d_%H-%M-%S').png" && grim -g "$(slurp)" "$FILE" && wl-copy < "$FILE"]]
))

-- Volumen por niveles: Super+V y luego 1-5 (1=0%, 2=25%, 3=50%, 4=75%, 5=100%).
-- Funciona soltando Super o manteniéndolo. Esc (o cualquier nivel) sale del modo.
hl.bind(mainMod .. " + V", hl.dsp.submap("volumen"))
hl.define_submap("volumen", function()
    local levels = { 0, 25, 50, 75, 100 }
    for key, level in ipairs(levels) do
        local setLevel = function()
            hl.dispatch(hl.dsp.exec_cmd(audio .. " set " .. level))
            hl.dispatch(hl.dsp.submap("reset"))
        end
        hl.bind(tostring(key), setLevel)
        hl.bind(mainMod .. " + " .. key, setLevel)
    end
    hl.bind("escape", hl.dsp.submap("reset"))
end)
