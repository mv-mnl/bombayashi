# Configuración de Hyprland (Bully-ye)

Este directorio contiene la configuración de [Hyprland](https://hyprland.org/), construida de forma modular para que sea fácil de mantener, leer y modificar.

## 📂 Organización

Para evitar un archivo `hyprland.conf` de miles de líneas difícil de navegar, la configuración utiliza un sistema modular:

- **`hyprland.conf`**: El archivo principal que la sesión de Hyprland lee al arrancar. Consiste exclusivamente en llamadas para cargar (hacer `source`) el resto de la configuración.
- **`conf/`**: Una subcarpeta que aloja todos los ajustes categorizados donde se define la funcionalidad real (puedes ver más información en su propio `README.md`).

## 🛠️ Cómo hacer modificaciones

Si deseas cambiar algo en el entorno:
1. No edites directamente `hyprland.conf`, a menos que quieras agregar una nueva categoría (ejemplo: un nuevo archivo `.conf`).
2. Ve a la carpeta `conf/` y abre el archivo correspondiente a lo que quieres alterar (animaciones en `animations.conf`, atajos en `keybinds.conf`, etc).
3. Hyprland aplicará la mayoría de estos cambios inmediatamente al momento de guardar (Hot-reload).
