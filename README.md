# Configuración de Hyprland

Este directorio contiene la configuración de [Hyprland](https://hyprland.org/), construida de forma modular para que sea fácil de mantener, leer y modificar.

## 📂 Organización

Para evitar un archivo `hyprland.lua` de miles de líneas difícil de navegar, la configuración utiliza un sistema modular.

> Desde Hyprland 0.57 la configuración se escribe en **Lua**: el formato `.conf` (hyprlang) ya no se lee.

- **`hyprland.lua`**: El archivo principal que la sesión de Hyprland lee al arrancar. Consiste exclusivamente en llamadas `require(...)` que cargan el resto de la configuración.
- **`conf/`**: Una subcarpeta que aloja todos los ajustes categorizados (`*.lua`) donde se define la funcionalidad real. Los atajos están en `conf/keybinds/`.

## 🛠️ Cómo hacer modificaciones

Si deseas cambiar algo en el entorno:
1. No edites directamente `hyprland.lua`, a menos que quieras agregar una nueva categoría (ejemplo: un nuevo archivo `.lua` y su `require`).
2. Ve a la carpeta `conf/` y abre el archivo correspondiente a lo que quieres alterar (apariencia en `general.lua`, atajos en `keybinds/*.lua`, etc).
   Para validar antes de recargar: `Hyprland --verify-config -c ~/.config/hypr/hyprland.lua`.
3. Hyprland aplicará la mayoría de estos cambios inmediatamente al momento de guardar (Hot-reload).
