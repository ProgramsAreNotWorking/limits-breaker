# Arquitectura técnica

## Plataforma y arranque

Godot 4.7.2, GDScript y una escena principal 2D a 1280×720 con escalado `canvas_items`. `project.godot` inicia `src/main.tscn`; no hay backend ni dependencias de red en tiempo de ejecución.

## Capas

- `src/core/math_engine.gd`: problemas, respuestas, pasos, tablas, gráficas y validación matemática, independiente de la presentación.
- `src/core/combat.gd`: perfiles de cuatro ataques, mitigación física/mágica, grupos de hasta cuatro enemigos, progresión por nivel, mundos, equipo, mejoras, botín y bandas aleatorias del reloj de selección.
- `src/core/game.gd`: estado de run, nivel y XP temporales, carga Berserk, guardado, ajustes de audio/accesibilidad y registro persistente de maestría. Las claves antiguas como `select_time` se ignoran al cargar.
- `src/main.gd` y `src/ui/`: router y pantallas de menú, combate, fragua, ángel, muerte, victoria, maestría y ajustes.
- `src/audio/`: síntesis procedural y `Audio` como administrador central.
- `src/core/asset_manifest.gd`: rutas estables para PNG de runtime y audio; los SVG de arte se retiraron del proyecto. Todo el arte es estático: no se cargan sprites animados ni video; la animación se compone con tweens, partículas y controles de Godot.

`Game` y `Audio` son autoloads. El guardado local usa `user://limits_breaker_save.json`; únicamente conserva maestría y ajustes, no el progreso temporal de la run.

## Interfaz de respuestas

`src/ui/combat_screen.gd` concentra la selección de objetivo y técnica, la generación aleatoria de dificultad, el `LineEdit` de respuesta y el envío con `Enter`. `src/ui/enemy_battle_actor.gd` representa cada enemigo seleccionable y dibuja la barra de vida pequeña sobre el retrato de los no jefes. Los ataques de área usan el objetivo seleccionado como ancla y respetan el máximo de cuatro enemigos por encuentro. Solo se usa el teclado físico; no existe teclado matemático en pantalla. El campo acepta dígitos, signo, coma o punto decimal, fracciones y texto de límites; la validación final vive en `MathEngine`. La fragua y el ángel tienen sus propios campos y comparten el mismo estilo de validación local.

El reloj de selección se sortea en `Combat.selection_time_for()` al inicio de cada turno, usando `SELECT_TIME_BY_TIER`; las bandas no se solapan y descienden con el tier del enemigo. `CombatScreen` guarda el límite sorteado en `time_limit` para dibujar la barra y descuenta `time_left` solo durante la fase de selección. Resolver la operación no consume ese reloj. La pantalla de ajustes ya no expone un control de tiempo.

## VFX

`src/ui/combat_vfx.gd` es una capa transparente sobre el panel de fase y por debajo del HUD superior. Usa `GPUParticles2D` con `ParticleProcessMaterial` para ráfagas direccionales, chispas, halos y brasas, además de números de daño flotantes. `src/ui/vfx_textures.gd` reutiliza la estrella PNG de `particle.png` y genera un punto radial suave en runtime; no hay texto ni ecuaciones dentro de las imágenes. `src/ui/backdrop.gd` añade brasas ambientales con el mismo sistema y las tiñe según el entorno. Todo respeta el ajuste de movimiento reducido.

## Recursos

Las pantallas solicitan recursos a `AssetManifest`. `UIKit.add_optional_image` carga placas raster; `UIKit.add_portrait` carga maestros PNG con alfa y `UIKit.add_item_icon` carga los iconos de equipo. `UIKit.panel` puede usar el marco PNG con nueve parches; el HUD de combate usa paneles planos de carbón y acero para conservar contraste y evitar halos al escalar. Los textos y las ecuaciones siguen siendo nodos editables, no están horneados en los fondos. `src/ui/toon_art.gd` aplica el tratamiento ilustrado de `src/ui/cartoon_art.gdshader` solo a fondos, retratos, iconos y arte transparente; la UI y los textos quedan fuera. La procedencia y los límites del arte están en `docs/ART_ASSETS.md`; la dirección cartoon y sus prompts están en `docs/ART_STYLE_CARTOON.md`.

## Pruebas

Las dos suites se ejecutan sin red:

```sh
godot --headless --path . res://tests/test_runner.tscn
godot --headless --path . --script res://tests/test_runner.gd
```

La primera cubre flujo real de pantallas, combate, inventario, guardado, ampliación de mundos y reloj por dificultad; la segunda cubre balance, problemas, daño, botín temático y persistencia. La revisión visual se hace con `tests/layout_preview.tscn`, `tests/layout_measure.tscn` y `tests/vfx_preview.tscn` a 1280×720.

