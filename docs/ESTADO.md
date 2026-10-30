# Estado del proyecto y pendientes

Actualizado: 2026-10-30.

## Resumen

**Limits Breaker** es un roguelike RPG de fantasía oscura para Godot 4.7 en el que el combate se resuelve con problemas de límites. La run recorre cuatro mundos y diez encuentros, con muerte permanente, maestría persistente, fragua, ángel, objetos y un jefe final.

El contenido actual incluye:

- Cuatro mundos, dieciocho enemigos y veintiséis objetos.
- Seis técnicas de combate: cuatro ataques, una defensa y una curación.
- Grupos de hasta cuatro enemigos, selección de objetivo, intenciones visibles, guardia, debilidades, resistencias y estados.
- Música y efectos locales, interfaz completa, guardado local y ajustes gráficos y de audio.

## Estado de los efectos de técnica

Implementado y cubierto por la suite:

| Técnica | Estado aplicado | Regla |
|---|---|---|
| Tajo perforante | Sangrado | 2 de daño por turno durante 3 turnos; sólo enemigos vivos. |
| Barrido | Mutilación | 33 % de probabilidad por objetivo; el enemigo pierde el turno inmediato siguiente. |
| Lanza arcana | Debilidad | −25 % de daño enemigo durante 2 turnos; empieza a contar al turno siguiente. |
| Nova astral | Flujo de magia | 3 de daño por turno durante 3 turnos; no afecta a no vivos ni a variantes mágicas. |

Los estados no se acumulan: se refrescan al volver a aplicarlos. El Flujo y el Sangrado no dañan en la ronda en que se aplican; su primer tick ocurre al inicio de la fase enemiga del turno siguiente. La Mutilación se consume en el turno enemigo inmediato. Al morir un enemigo se limpian todos sus estados.

La clasificación por tipo de cuerpo y las inmunidades están documentadas en [ENEMIGOS.md](ENEMIGOS.md#tipo-de-cuerpo-e-inmunidades).

## Verificación

- Suite principal: **PASS: 2153 verificaciones** (2026-10-30).
- Scripts principales validados sin errores: `src/core/combat.gd`, `src/ui/combat_screen.gd`, `src/ui/enemy_battle_actor.gd` y `tests/run_tests.gd`.
- La suite se ejecuta con la escena `tests/test_runner.tscn` desde el MCP de Godot.
- Revisión visual a 1280×720 de selección, tarjetas y línea de estados con 1, 2 y 4 enemigos, regenerada en `output/previews/`; la UI escala a 960×540 con `canvas_items` y la línea de estados queda por encima del panel.

## Pendientes

- Completar una partida manual con teclado físico, revisando transiciones de muerte y victoria, fragua, ángel y guardado.
- Aprobar la intensidad del tratamiento cartoon y decidir si se generan nuevos PNG maestros para héroe, esqueleto y menú. La dirección está en [ART_STYLE_CARTOON.md](ART_STYLE_CARTOON.md).
- Elegir una tanda de [AUDIO_STYLES.md](AUDIO_STYLES.md) y producir sus WAV; después hacer la escucha subjetiva en contexto.
- Configurar presets de exportación sólo si se solicita una build; no hay un preset pendiente en el código.
- Limpieza opcional: el código conserva `enemy_fragile_*` como legado, pero ninguna técnica aplica Frágil actualmente. Retirarlo cuando no haga falta compatibilidad.

## Notas técnicas

- El proyecto no llama a LLM, API ni red en runtime.
- Los recursos gráficos son PNG estáticos; el movimiento se compone con tweens, partículas y controles de Godot.
- Las reglas de combate viven en `src/core/combat.gd`; la resolución y los estados, en `src/ui/combat_screen.gd`.
