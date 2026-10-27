# Audio

El juego carga música y efectos locales desde `src/audio/audio_manager.gd`. La fuente reproducible está en `src/audio/synth.gd`; el exportador es `tools/generate_audio.gd` y el manifiesto es `assets/audio/audio_manifest.json`. La música se entrega como WAV PCM de 16 bits, mono, a 22.050 Hz. Comfy no se usa para música ni para ningún otro audio.

El catálogo de estilos actuales y propuestos, con tempo, tonalidad, instrumentación, forma, prompts y prioridades, está en [AUDIO_STYLES.md](AUDIO_STYLES.md). Los estilos nuevos son briefs de composición: todavía no tienen WAV ni están registrados en el manifiesto.

## Música

Las seis pistas son loops completos de más de un minuto. Mantienen sus tempos, centros tonales, formas y duraciones originales, pero ahora cada pantalla tiene timbres sintetizados distintos. La producción es procedural local; no se usó un modelo externo ni Comfy. La síntesis añade contramelodías discretas, movimiento de bajo, ecos breves y fills donde ayudan al pulso.

| Tema | BPM | Forma | Identidad sonora | Duración |
|---|---:|---|---|---:|
| Menú | 72 | A–B–A′–reentrada | Arpa sintetizada, pad cálido y eco breve | 106,67 s |
| Combate | 96 | A–B–A′–reentrada | Timbre de metales, cama de cuerdas y fills cada cuatro compases | 80 s |
| Jefe | 108 | A–B–A′–reentrada | Metales sintetizados oscuros, armonía cromática y percusión más intensa | 71,11 s |
| Fragua | 88 | A–B–A′–reentrada | Voz metálica percutida, golpes de yunque y bajo más móvil | 87,27 s |
| Ángel | 64 | A–B–A′–reentrada | Timbre coral sintético, contramelodía y eco amplio | 120 s |
| Game Over | 58 | A–B–A′–coda | Cuerdas sintetizadas oscuras, frase descendente y cierre más escaso | 115,86 s |

### Informe de evaluación — 26-10-2026

- **Artefacto:** seis loops WAV del juego, en etapa de refinamiento.
- **Hallazgo (gravedad moderada):** las melodías compartían el mismo timbre de campana y el bajo alternaba principalmente entre dos grados; la percusión repetía el mismo patrón durante casi toda la pista. Responsable: arreglo y síntesis local.
- **Cambios:** timbres de arpa, metales, voz metálica, coro y cuerdas; contramelodías por secciones; patrones de bajo propios por pista; ecos sutiles en menú, ángel y Game Over; fills de cuatro compases en combate y jefe.
- **Decisiones preservadas:** los seis temas siguen ligados a sus pantallas, conservan BPM, centros tonales, forma y duración. Todas las pistas superan 60 segundos. Los efectos de sonido no se modificaron.
- **Control técnico:** PASS. Las seis pistas se regeneraron y reimportaron en Godot. Formato PCM 16-bit mono a 22.050 Hz; duraciones de 71,11 a 120 s; picos de 15.406 a 28.799; RMS de 2.186 a 2.633; diferencia entre la última y la primera muestra del loop: 0. Sin clipping ni costuras detectadas.
- **Recomendación:** WARN hasta una escucha subjetiva en contexto de juego. El control numérico confirma formato, nivel, duración y loop, pero no sustituye esa escucha.
- **Control no ejecutado:** escucha perceptiva de las seis pistas dentro del juego. Las herramientas disponibles permitieron regenerar, reimportar y medir los WAV, pero no monitorizar la salida de audio del runtime. La corrección recomendada es escuchar las transiciones en Godot y hacer retoques locales si un timbre compite con el combate o la interfaz.

## Efectos

Los efectos locales cubren selección, confirmación, acierto, fallo, ataques físicos y arcanos, daño, curación, muerte de enemigo, botín, equipo, fragua, ángel, jefe, muerte y victoria. Sus archivos y duraciones están en `assets/audio/audio_manifest.json`.

## Ampliación propuesta

El catálogo de [AUDIO_STYLES.md](AUDIO_STYLES.md) define ocho estilos nuevos sin producir. La primera tanda recomendada es `crypt`, `ash`, `bell`, `throne` y `victory`; después `miniboss` y `mastery`; `threshold` queda como transición opcional.

| ID | Uso | Estilo | BPM | Prioridad |
|---|---|---|---:|---|
| `crypt` | Encuentros 1–3 | Dungeon synth / cámara oscura | 68 | Alta |
| `ash` | Encuentros 4 y 6 | Forge folk / folk oscuro | 92 | Alta |
| `bell` | Encuentros 7–9 | Cámara sagrada / coro roto | 72 | Alta |
| `throne` | Encuentro 10 | Ritual orquestal apocalíptico | 112 | Alta |
| `victory` | Pantalla de victoria | Resolución cinematográfica agridulce | 76 | Alta |
| `miniboss` | Encuentro 5 | Persecución / marcha de guerra | 126 | Media |
| `mastery` | Pantalla de maestría | Dark academia / ambient de estudio | 60 | Media |
| `threshold` | Transición entre mundos | Sting ritual de 10 s | libre | Baja |

Ninguno de estos IDs debe añadirse a `AssetManifest.MUSIC_FILES`, `tools/generate_audio.gd` ni a las pruebas de audio hasta que exista su WAV. Mientras tanto, el juego conserva los fallbacks actuales.

## Siguiente paso

Hacer una escucha final de las seis pistas en el juego y ajustar cualquier choque de timbre o transición que aparezca en contexto. Las pistas ya están regeneradas y listas para esa revisión. La ampliación musical empieza por elegir y producir una de las tandas del catálogo de estilos.
