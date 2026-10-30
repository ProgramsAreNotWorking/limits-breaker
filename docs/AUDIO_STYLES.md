# Catálogo de estilos musicales

Este documento define los estilos candidatos para ampliar la banda sonora de **Limits Breaker**. Es un catálogo de composición y arreglo, no una lista de pistas ya producidas. Las seis pistas actuales siguen siendo la base y no se reemplazan hasta que exista un WAV terminado y una decisión explícita.

- **Estado del trabajo:** borrador de composición (`draft`).
- **Estado de las decisiones:** abierto (`open`). Ningún estilo está aprobado ni bloqueado.
- **Audio producido:** ninguno. Este documento no genera archivos ni modifica el manifiesto.
- **Referencia de implementación:** [AUDIO.md](AUDIO.md).

## Decisión de alcance

La ampliación se plantea en dos capas:

1. **Identidad de mundo:** `crypt`, `ash`, `bell` y `throne` dan a cada tramo de la expedición una textura propia.
2. **Identidad de pantalla o evento:** `miniboss`, `victory`, `mastery` y `threshold` cubren los momentos que hoy reutilizan `combat`, `boss` o `menu`.

La ruta propuesta no cambia el combate ni el guardado. Si una pista nueva no existe, el juego debe seguir usando el fallback actual:

| Momento | ID propuesto | Fallback actual |
|---|---|---|
| Encuentros 1–3, Cripta | `crypt` | `combat` |
| Encuentro 4 y 6, Galerías de Ceniza | `ash` | `combat` |
| Encuentro 5, miniboss | `miniboss` | `boss` |
| Encuentros 7–9, Santuario | `bell` | `combat` |
| Encuentro 10, Trono | `throne` | `boss` |
| Pantalla de victoria | `victory` | `menu` o `combat` según el flujo actual |
| Pantalla de maestría / archivo | `mastery` | `menu` |
| Transición entre mundos | `threshold` | silencio o transición actual |

`threshold` es un sting corto, no un loop de combate. No debe entrar en `AssetManifest.MUSIC_FILES` ni en las comprobaciones de duración mínima de 60 segundos; su sitio natural es un efecto de transición o un recurso de una sola reproducción.

## Paleta compartida

- **Género general:** fantasía oscura instrumental, con instrumentos acústicos y texturas sintéticas discretas. Nada de letras, voces inteligibles ni canciones pop.
- **Instrumentos base:** cuerdas graves, arpa, campanas tubulares, metales, coro sin palabras, percusión de marco, madera, hueso, yunque y drones sintéticos.
- **Firma armónica:** tensión de semitono o tritono sin resolver del todo. La música puede ser tonal, pero no debe sonar a fanfarria genérica.
- **Espacio para el juego:** evitar una pared de ruido entre 1 y 4 kHz; ahí viven las respuestas, los impactos y los avisos de la interfaz.
- **Voces:** solo coro sin palabras y siempre por debajo de la melodía principal. Nunca letras, susurros inteligibles ni samples vocales reconvertidos en texto.
- **Mezcla:** misma sonoridad percibida que las seis pistas actuales. No subir el volumen para compensar; dejar headroom y evitar clipping.
- **Formato de entrega:** master estéreo a 44,1 kHz y export final WAV PCM 16 bits, mono, 22.050 Hz, como el resto del juego.
- **Loops:** cortar en un límite de compás, sin fade-out, con cola que desemboque en el primer sample. Verificar que la diferencia entre el último y el primer sample sea 0 o prácticamente 0.
- **Duración:** 60 segundos o más para cualquier pista que entre en `MUSIC_FILES`. Las duraciones de las fichas son objetivos de composición, no una obligación rígida.

## Prioridad de producción

| Prioridad | IDs | Motivo |
|---|---|---|
| Alta | `crypt`, `ash`, `bell`, `throne` | Sin estas cuatro, los mundos siguen compartiendo la misma identidad sonora. |
| Alta | `victory` | La pantalla de victoria es el cierre emocional de la run y hoy reutiliza música de menú o combate. |
| Media | `miniboss` | El encuentro 5 merece una amenaza distinta del jefe final. |
| Media | `mastery` | La pantalla de archivo gana mucho con un tema tranquilo y no competitivo. |
| Baja | `threshold` | Es un detalle de transición; puede resolverse con un efecto si no hay presupuesto musical. |

Una primera tanda razonable es **`crypt`, `ash`, `bell`, `throne` y `victory`**. La segunda puede ser **`miniboss` y `mastery`**. `threshold` puede esperar.

## Fichas

### `crypt` — Juramento de hueso

- **Uso:** encuentros 1–3, Cripta de los Juramentos.
- **Estilo:** dungeon synth / cámara oscura, lento y ritual.
- **Tempo y métrica:** 68 BPM, 4/4.
- **Centro tonal:** Re frigio (Re–Mi♭–Fa–Sol–La–Si♭–Do). El segundo grado bemol es la firma de la cripta.
- **Forma:** intro de 4 compases + A 8 + B 8 + A′ 8 + coda 4 = 32 compases.
- **Duración objetivo:** 112,9 s.
- **Instrumentación:** drone de violonchelo y contrabajo, percusión de hueso y madera, armónicos de arpa, viola ligeramente desafinada, coro grave sin palabras, reverberación de piedra.
- **Motivo:** suspiro descendente `1–♭2–1–5` (Re–Mi♭–Re–La), respondido por `♭3–♭2–1` (Fa–Mi♭–Re). Debe sonar antiguo, no heroico.
- **Ritmo:** pulso lento; golpes de hueso en el primer y tercer tiempo, con síncopas secas y espacios largos. Sin backbeat moderno.
- **Mezcla:** drone profundo pero mono-compatible; hueso y arpa bien separados; coro bajo y lejano. La cripta debe sentirse grande, no embarrada.
- **Prompt de producción:** `instrumental dark fantasy dungeon synth, 68 BPM, 4/4, D Phrygian, low cello and contrabass drone, bone and wood percussion, harp harmonics, slightly detuned viola, distant wordless choir, stone reverb, slow ritual, no modern drums, no lyrics, seamless 113-second loop`.
- **Prioridad:** alta.

### `ash` — La fragua sin dueño

- **Uso:** encuentros 4 y 6, Galerías de Ceniza. El encuentro 5 usa `miniboss`.
- **Estilo:** forge folk / folk oscuro industrial, con pulso de trabajo.
- **Tempo y métrica:** 92 BPM, 4/4.
- **Centro tonal:** Do menor con giro a Do dórico en la sección B. La sexta mayor del dórico aporta sudor y resistencia, no heroicidad.
- **Forma:** intro de 4 compases + A 8 + B 8 + A′ 8 + breakdown 4 + reentrada 4 = 36 compases. Si se recorta, mantener la reentrada.
- **Duración objetivo:** 93,9 s con 36 compases; 73,0 s si se usa la versión de 28 compases.
- **Instrumentación:** salterio martillado, golpes de yunque, metal percutido, metales graves, tambor de marco, pisadas, crepitar de brasas, bajo en ostinato.
- **Motivo:** canto de trabajo `1–1–♭3–4–5` (Do–Do–Mi♭–Fa–Sol), con respuesta de metales `♭6–5` (La♭–Sol). Debe poder imaginarse cantado a gritos por gente que no habla.
- **Ritmo:** martillo en negras, yunque en contratiempos, pisada en el primer tiempo. La sección B puede abrir el hi-hat de marco, pero sin sonar a rock.
- **Mezcla:** medios cálidos, yunque brillante pero no hiriente, brasas anchas y bajas. Cuidado con el bombo y el yunque en los mismos instantes que un impacto de combate.
- **Prompt de producción:** `instrumental dark forge folk, 92 BPM, 4/4, C minor with Dorian lift, hammered dulcimer, anvil hits, low brass, frame drums, stomps, ember crackle, work-chant motif, gritty medieval fantasy, no electric guitar, no lyrics, seamless 94-second loop`.
- **Prioridad:** alta.

### `bell` — Campana rota

- **Uso:** encuentros 7–9, Santuario de la Campana Rota.
- **Estilo:** sacred chamber / coro roto, cámara sagrada con disonancia.
- **Tempo y métrica:** 72 BPM, 3/4. El compás de vals ritual diferencia este mundo del resto.
- **Centro tonal:** La menor con quinta bemol (La–Si–Do–Re–Mi♭–Fa–Sol). El tritono La–Mi♭ es la campana quebrada.
- **Forma:** campanada de 4 compases + A 8 + B 8 + A′ 8 + desintegración 4 = 32 compases.
- **Duración objetivo:** 80,0 s.
- **Instrumentación:** campanas tubulares ligeramente desafinadas, cuarteto de cuerdas en sul tasto, órgano grave, coro sin palabras, platos invertidos, timbal suave en los descensos.
- **Motivo:** tres notas de campana `1–♭3–♭5` (La–Do–Mi♭), seguidas de `♭6–5–4` (Fa–Mi–Re). La resolución queda suspendida.
- **Ritmo:** campanada en el primer tiempo de cada dos compases; cuerdas en negras con silencios; el timbal solo aparece en B y en la coda. No convertir el 3/4 en un vals alegre.
- **Mezcla:** reverberación sagrada larga, pero con el coro y las campanas controlados para no tapar el reloj de selección. Las campanas no deben golpear en cada tiempo.
- **Prompt de producción:** `instrumental sacred dark chamber, 72 BPM, 3/4, A minor with flat fifth, slightly detuned tubular bells, string quartet sul tasto, low organ, distant wordless choir, reversed cymbal swells, soft timpani downbeats, ritual and broken, no lyrics, seamless 80-second loop`.
- **Prioridad:** alta.

### `throne` — Limitless

- **Uso:** encuentro 10, Trono de Limitless, jefe final.
- **Estilo:** ritual orquestal apocalíptico / orquestal oscuro con percusión de guerra.
- **Tempo y métrica:** 112 BPM, 4/4.
- **Centro tonal:** Do♯ menor con segundo grado bemol (Do♯–Re–Mi–Fa♯–Sol♯–La–Si). La tensión Do♯–Re es la presencia del Trono.
- **Forma:** intro de 4 compases + A 8 + B 8 + A′ 8 + C 8 + coda 4 = 40 compases.
- **Duración objetivo:** 85,7 s.
- **Instrumentación:** ostinato de contrabajo y violonchelo, coro grave sin palabras, racimos de metales, tambores de guerra, gong, cuerdas disonantes, drone sintético bajo y distorsionado con moderación.
- **Motivo:** motivo de la corona `1–♭3–♭2` (Do♯–Mi–Re) en notas largas; el bajo hace `1–1–♭2–♭7` (Do♯–Do♯–Re–Si). El coro responde en la sección B con `4–♭3–♭2` (Fa♯–Mi–Re).
- **Ritmo:** tambores de guerra en negras y corcheas, con acentos desplazados; los metales golpean al final de las frases, no en cada compás. La coda puede quedarse sin batería para que el silencio pese.
- **Mezcla:** enorme pero controlado. Bajo en mono, tambores con transitorio claro, coro por detrás de los metales. Evitar una capa constante de platillos que enmascare los efectos.
- **Prompt de producción:** `instrumental apocalyptic dark fantasy final boss, 112 BPM, 4/4, C# minor with flat second, contrabass ostinato, low wordless choir, brass clusters, war drums, gong, dissonant strings, restrained distorted low drone, cinematic, no electric guitar, no lyrics, seamless 86-second loop`.
- **Prioridad:** alta.

### `miniboss` — Celador del umbral

- **Uso:** encuentro 5, miniboss fijo de las Galerías de Ceniza.
- **Estilo:** persecución de fantasía oscura / marcha de guerra.
- **Tempo y métrica:** 126 BPM, 4/4.
- **Centro tonal:** Fa menor (Fa–Sol–La♭–Si♭–Do–Re♭–Mi♭), con apoyo ocasional en el segundo grado bemol.
- **Forma:** intro de 4 compases + A 8 + B 8 + A′ 8 + break 4 + coda 4 = 36 compases.
- **Duración objetivo:** 68,6 s.
- **Instrumentación:** ostinato de cuerdas graves, taiko, caja, golpes de metales, percusión metálica, acentos de coro sin palabras, pulso de bajo.
- **Motivo:** ostinato ascendente `1–♭3–4–5` (Fa–La♭–Si♭–Do) en corcheas; los metales responden con `♭6–5` (Re♭–Do). Debe sentirse como alguien que cierra el paso, no como un jefe final en miniatura.
- **Ritmo:** taiko y caja con acentos en el segundo y cuarto tiempo; break de cuatro compases con solo cuerdas y respiración antes de la reentrada.
- **Mezcla:** menos reverberación que `throne`, más pegada. El miniboss debe ser más seco y urgente para distinguirse del jefe final.
- **Prompt de producción:** `instrumental dark fantasy miniboss pursuit, 126 BPM, 4/4, F minor, low string ostinato, taiko, snare, brass stabs, metallic percussion, wordless choir accents, relentless, dry and urgent, no lyrics, seamless 69-second loop`.
- **Prioridad:** media.

### `victory` — Límite roto

- **Uso:** pantalla de victoria tras el jefe final y cierre de la run.
- **Estilo:** resolución cinematográfica de fantasía oscura / triunfo agridulce.
- **Tempo y métrica:** 76 BPM, 4/4.
- **Centro tonal:** Re lidio (Re–Mi–Fa♯–Sol♯–La–Si–Do♯), con un Si♭ prestado en la coda para que la victoria no sea ingenua.
- **Forma:** A 8 + B 8 + A′ 8 + coda 8 = 32 compases.
- **Duración objetivo:** 101,1 s.
- **Instrumentación:** cuerdas cálidas, trompa, coro sin palabras, arpa, timbal suave, drone grave. Un gong lejano en la coda, sin campanas del santuario.
- **Motivo:** ascenso `1–2–3–5–6` (Re–Mi–Fa♯–La–Si) que cae a `♯4–3` (Sol♯–Fa♯); el último acorde es Re add9, no una cadencia triunfal cerrada.
- **Ritmo:** negras y blancas, sin percusión en A; el timbal entra solo en B y en la coda. La victoria debe respirar, no desbordarse.
- **Mezcla:** cálida y ancha, con la trompa al frente y el coro detrás. No usar bombos de tráiler ni golpes de impacto que rompan el tono íntimo del cierre.
- **Prompt de producción:** `instrumental cinematic dark fantasy victory, 76 BPM, 4/4, D Lydian with borrowed flat sixth in the coda, warm strings, French horn, wordless choir, harp, soft timpani, low drone, distant gong, bittersweet resolve, restrained, no lyrics, seamless 101-second loop`.
- **Prioridad:** alta.

### `mastery` — Archivo de intentos

- **Uso:** pantalla de maestría, archivo de temas y progreso persistente.
- **Estilo:** dark academia / ambient de estudio, íntimo y no competitivo.
- **Tempo y métrica:** 60 BPM, 4/4.
- **Centro tonal:** La dórico (La–Si–Do–Re–Mi–Fa♯–Sol). La sexta mayor evita que el archivo suene a duelo.
- **Forma:** A 8 + B 8 + A′ 8 + coda 8 = 32 compases.
- **Duración objetivo:** 128,0 s.
- **Instrumentación:** piano de fieltro, cuerdas suaves, armónicos de arpa, drone grave, textura de sala muy sutil. Sin batería.
- **Motivo:** arpegio lento `1–5–6–♭3` (La–Mi–Fa♯–Do); melodía `♭3–2–1–6` (Do–Si–La–Fa♯) con mucho espacio entre frases.
- **Ritmo:** pulso casi implícito; el piano marca el compás sin rigidez. La sección B puede quedarse solo con arpa y drone.
- **Mezcla:** piano cercano, cuerdas amplias pero bajas, sin picos repentinos. Es música para leer y comparar, no para llenar el silencio.
- **Prompt de producción:** `instrumental dark academia study ambient, 60 BPM, 4/4, A Dorian, felt piano, soft strings, harp harmonics, low drone, subtle room tone, no drums, calm and melancholic, no lyrics, seamless 128-second loop`.
- **Prioridad:** media.

### `threshold` — Umbral

- **Uso:** transición entre mundos, después de los encuentros 3, 6 y 9; opcionalmente entrada al Trono.
- **Estilo:** sting ritual de fantasía oscura, no es una canción con forma completa.
- **Tempo y métrica:** libre, alrededor de 80 BPM, 4/4.
- **Centro tonal:** Re menor con clúster de segunda bemol; resuelve a quinta abierta Re–La.
- **Forma:** crescendo de 6 s + impacto y cola de 4 s; 10 s totales.
- **Instrumentación:** clúster de cuerdas graves, gong invertido, impacto bajo, swell de coro sin palabras, textura de brasas.
- **Motivo:** no hay melodía. El clúster `Re–Mi♭–La` asciende y se abre a `Re–La`; el último evento es un golpe seco con cola larga.
- **Mezcla:** sin fade-out; la cola debe empalmar con la siguiente pista. Dejar headroom para que el impacto no sature. No es un loop.
- **Prompt de producción:** `short dark fantasy transition sting, 10 seconds, rising low string cluster, reversed gong, low impact, wordless choir swell, resolves to open fifth, no melody, no lyrics, cinematic tail, no fade-out`.
- **Prioridad:** baja. Puede implementarse como SFX si no se produce como pista.

## Criterios para elegir candidatos

Antes de aprobar una pista, escucharla en estas tres situaciones:

1. **Primeros 8 segundos:** ¿se reconoce el mundo o el evento sin mirar la pantalla?
2. **Tres minutos de loop:** ¿la repetición cansa, o el loop se vuelve invisible y deja jugar?
3. **Mezcla con SFX:** ¿la respuesta correcta, el fallo, el ataque y el reloj siguen claros?

También conviene comparar cada candidato con la pista actual que reemplaza. Si la nueva no aporta una diferencia clara en instrumentación, tempo o forma, no merece entrar al manifiesto.

## Ruta de producción

### Opción A: síntesis procedural local

Es la ruta que usa el juego hoy. Requiere añadir un plan a `Synth._music_plan()` y una entrada a `tools/generate_audio.gd`, generar el WAV, importarlo en Godot y solo entonces registrar el ID en `AssetManifest.MUSIC_FILES`. Las pistas nuevas deben superar las mismas comprobaciones de duración, loop y formato que las seis actuales.

### Opción B: generación instrumental externa

Útil si se quiere una interpretación más orgánica. Generar de dos a cuatro candidatos por estilo con los prompts de este documento, siempre instrumentales y sin letras. Elegir uno, editar el loop en un editor de audio y exportar el WAV con las especificaciones de arriba. No añadir el ID al manifiesto hasta tener el archivo final.

### Opción C: compositor humano

Entregar esta ficha como brief. Pedir un master estéreo y una versión mono compatible, además de los stems de batería, bajo, armonía y melodía si se quiere evaluar más adelante una capa de intensidad dinámica.

## Lo que falta antes de tocar código

- Elegir qué estilos se van a producir primero.
- Producir y aprobar los WAV.
- Verificar loop, duración, formato y mezcla en contexto.
- Añadir los IDs a `AssetManifest.MUSIC_FILES` y a `tools/generate_audio.gd` solo cuando los archivos existan.
- Enrutar `crypt`, `ash`, `bell`, `miniboss`, `throne`, `victory`, `mastery` y `threshold` desde las pantallas correspondientes.
- Actualizar las pruebas de audio y la documentación con las duraciones reales.

Hasta entonces, el juego sigue funcionando con las seis pistas actuales y sus fallbacks.
