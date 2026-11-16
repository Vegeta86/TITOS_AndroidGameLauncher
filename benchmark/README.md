# Metodología del benchmark

Mediciones reales hechas por `adb` el 16/11/2026.

- **Dispositivo:** GT78-VN, MediaTek MT8789 (8 núcleos), 4 GB de RAM, Android 12. Conectado por USB y cargando (49 % de batería, ~32 °C).
- **Versiones:** TITOS 1.0.0 (release firmada, con R8), Launcher3 del sistema, AYANEO Home de fábrica.
- **Procedimiento** (`bench.sh`, mismo para todos): parar la app, arrancarla como Home, esperar 25 s, tomar 3 muestras de RAM y CPU durante 30 s en reposo, y luego 40 pulsaciones del D-Pad (20 derecha, 20 izquierda) midiendo fotogramas.
- **2 pasadas** por launcher; la tabla de la web usa la media de las muestras estabilizadas.
- **RAM:** PSS de `dumpsys meminfo <paquete>` (suma todos los procesos del paquete).
- **CPU:** `utime + stime` de `/proc/<pid>/stat` entre dos instantes, como % de un solo núcleo (100 ticks/s).
- **GPU:** Android no da un % de uso de GPU sin root. `dumpsys gfxinfo` da tiempos de fotograma, que están en `raw/`.
- **Arranque:** `TotalTime` de `am start -W` en frío (tras `force-stop`).
- **APK:** tamaño de `base.apk`.

## Límites

- TITOS se midió con el carrusel de consolas, **sin juegos ni carátulas cargados**; con una biblioteca grande la RAM aumenta.
- Launcher3 es un launcher básico (sin carrusel, carátulas ni temas), por eso usa menos RAM que TITOS.
- La navegación con D-Pad no es el uso natural de un launcher táctil, así que los tiempos de fotograma comparan a TITOS con los demás con cautela.
- Un solo dispositivo y pocas repeticiones: son datos orientativos, no un estudio estadístico.

Para reproducirlo: `adb push bench.sh /data/local/tmp/` y `adb shell sh /data/local/tmp/bench.sh <paquete> <actividad> 25`.
