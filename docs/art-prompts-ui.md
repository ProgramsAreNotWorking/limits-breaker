# Prompts de arte para la UI

Actualizado: 2026-10-27. Estos prompts están preparados para generar **imágenes estáticas** más adelante. No se generó nada en esta pasada y el juego sigue funcionando con los PNG actuales.

Para la nueva dirección de fantasía oscura ilustrada, la referencia principal es [ART_STYLE_CARTOON.md](ART_STYLE_CARTOON.md). Los prompts de esta página siguen siendo útiles para composición, zonas seguras y encuadre; el bloque de estilo debe adaptarse a la dirección cartoon cuando se generen imágenes nuevas.

## Reglas de la familia visual

- Formato: PNG opaco, 16:9, 1600 × 900 como objetivo. Si el proveedor limita la resolución, generar a 1024 × 576 y reescalar con cuidado.
- Estilo: 2D painterly premium de fantasía oscura; piedra, metal y tela con textura material; profundidad atmosférica; contraste fílmico.
- Paleta: carbón, pizarra, acero, borgoña contenido, violeta arcano y ámbar cálido. Nada de neón ni blancos lavados.
- Los fondos no llevan personajes: los retratos y enemigos son recortes PNG separados.
- **Cero texto dentro de la imagen.** Nada de títulos, letras, números, ecuaciones, notación matemática, runas legibles, signos que parezcan escritura, marcos de UI, botones, logos ni marcas de agua.
- Dejar zonas limpias y de bajo contraste para la interfaz: banda superior para el HUD, centro para tarjetas o preguntas y laterales para paneles.
- No usar cel shading, contornos gruesos, superficies vectoriales, anime ni realismo fotográfico de personaje.

### Bloque de estilo reutilizable

```text
Premium painterly 2D dark-fantasy RPG background, cinematic environmental art, hand-painted stone, aged steel, worn leather and heavy fabric, layered depth, soft atmospheric perspective, filmic contrast, controlled volumetric light, restrained palette of charcoal, slate, steel, burgundy, muted arcane violet and warm amber. Rich material texture, quiet negative space for a game interface, consistent with the existing crypt, forge, sanctuary and boss-arena plates. No flat cel shading, no thick outlines, no vector-like shapes, no anime look, no photorealistic characters.
```

### Negativo universal

```text
text, letters, numbers, equations, mathematical notation, formulas, numerals, handwriting, pseudo-writing, readable runes, glyphs, sigils, logos, watermark, signature, interface, HUD, buttons, frames, borders, cards, labels, people, characters, creatures, bodies, faces, monsters, gore, blood, neon, oversaturated colors, bright white wash, blown highlights, flat cel shading, thick outlines, anime, vector art, busy focal center, centered subject, low resolution, JPEG artifacts
```

Ajustar el negativo por escena: la fragua sí puede tener un yunque y herramientas, y el santuario puede tener velas y un altar, pero ninguno debe incluir texto ni figuras.

## 1. Menú principal — fondo clave

**Destino previsto:** `assets/art/environments/menu.png`  
**Zona segura:** tercio derecho oscuro y tranquilo para el panel de menú; tercio izquierdo con una silueta de pedestal para el recorte del héroe; banda central sin foco duro.

```text
Create a 16:9 landscape static background plate for the premium dark-fantasy mathematical roguelike Limits Breaker, 1600 x 900 px, opaque PNG.

A vast ancient crypt nave seen from a low, reverent angle. On the far left, a narrow raised stone plinth and a tall empty wall niche, softly rim-lit with warm amber, reserved for a standing hero cutout. In the center-right, a colossal circular stone gate with worn, abstract carved geometry that reads only as erosion and age, and a deep restrained violet arcane glow inside it. The entire right third must be darker, simpler and lower contrast: a smooth charcoal stone wall with faint dust and a soft pool of shadow, reserved for a tall vertical menu panel. Foreground of worn flagstones, broken column bases and a few thin gold dust motes in the air. Charcoal, muted steel, restrained burgundy, faded gold and a contained violet accent. Filmic contrast, soft atmospheric perspective, premium painterly 2D dark-fantasy environment art with realistic stone and metal texture. No people, no hero, no monsters, no text, no letters, no numbers, no equations, no pseudo-writing, no readable runes, no interface, no border, no logo, no watermark, no bright central light, no neon.
```

**Por qué:** replica la composición de tres columnas que ya usa la pantalla y deja respirar al título y a los botones.

## 2. Combate normal — arena del pasillo

**Destino previsto:** `assets/art/environments/dungeon.png`  
**Zona segura:** 15 % superior para el HUD; 45–50 % central para la tarjeta del problema; laterales con columnas rotas para enmarcar sin tapar.

```text
Create a 16:9 landscape static background plate for a turn-based dark-fantasy RPG combat screen, 1600 x 900 px, opaque PNG.

An ancient medieval crypt corridor receding into layered arches. A clear, quiet horizontal band across the central 45 percent with low-contrast worn flagstones, reserved for a translucent problem card. The upper 15 percent stays calm and dark for a combat HUD. Broken columns frame the far left and right edges; faint restrained violet arcane glints and a few warm gold dust motes add depth without becoming focal points. Charcoal stone, muted steel, restrained burgundy, faded gold and a touch of violet. Premium painterly 2D dark-fantasy environment art, realistic stone texture, soft atmospheric perspective, filmic contrast. No people, no monsters, no enemies, no weapons in the foreground, no text, no letters, no numbers, no equations, no mathematical notation, no pseudo-writing, no readable runes, no interface, no border, no logo, no watermark, no bright focal center, no neon.
```

## 3. Combate de jefe — arena del límite

**Destino previsto:** `assets/art/environments/boss-arena.png`  
**Zona segura:** centro amplio y oscuro para el título del jefe y las tarjetas; borde superior calmado para el HUD.

```text
Create a 16:9 landscape static background plate for the final boss encounter of a premium dark-fantasy mathematical roguelike, 1600 x 900 px, opaque PNG.

A vast circular crypt amphitheater with a broken stone dais in the middle distance, towering black-stone arches, a distant sealed gate and restrained burgundy banners hanging in shadow. The middle third must remain visually quiet, dark and low contrast for a boss title and combat interface. A contained arcane-violet glow leaks from the sealed gate; warm amber light catches the edges of the dais and a thin haze of dust hangs in the air. Charcoal, slate, steel, burgundy, muted violet and aged gold. Cinematic painterly 2D dark-fantasy environment art, realistic stone and fabric texture, strong depth, soft atmospheric perspective, no bright central focal point. No boss, no creatures, no people, no text, no letters, no numbers, no equations, no mathematical notation, no pseudo-writing, no readable runes, no interface, no border, no logo, no watermark, no gore, no neon.
```

## 4. Victoria — el límite roto

**Destino previsto:** `assets/art/environments/victory.png` (opcional; hoy la pantalla reutiliza `boss-arena.png`)  
**Zona segura:** centro tranquilo para “El límite se ha roto”, las estadísticas y el resumen.  
**Condición de integración:** si se genera, añadir la entrada `victory` a `AssetManifest.ENVIRONMENTS` y usarla en `main.gd` al mostrar la pantalla de victoria.

```text
Create a 16:9 landscape static background plate for the victory screen of a premium dark-fantasy mathematical roguelike, 1600 x 900 px, opaque PNG.

The same vast crypt boss arena after the final seal has broken, but transformed by a solemn, restrained dawn. A single warm gold shaft falls through a cracked ceiling onto the empty broken dais; thin ash and dust drift in the light. The surrounding black-stone arches remain deep in shadow, with faded burgundy banners and a last trace of violet arcane mist dissolving at the far gate. The central horizontal band stays quiet, dark and low contrast for a large victory title, stat tiles and a summary panel. Charcoal, steel, burgundy, aged gold and a whisper of violet. Premium painterly 2D dark-fantasy environment art, realistic stone and fabric texture, filmic contrast, soft atmospheric perspective, hopeful but somber. No people, no bodies, no blood, no creatures, no boss, no text, no letters, no numbers, no equations, no mathematical notation, no pseudo-writing, no readable runes, no interface, no border, no logo, no watermark, no fireworks, no neon.
```

## 5. Fragua — la fragua del herrero

**Destino previsto:** `assets/art/environments/forge.png`  
**Zona segura:** centro y derecha libres para la tarjeta de mejora y la pregunta; el retrato del herrero es un recorte separado sobre la izquierda.

```text
Create a 16:9 landscape static background plate for a quiet upgrade encounter in a premium dark-fantasy RPG, 1600 x 900 px, opaque PNG.

A compact medieval dungeon forge carved into soot-black stone. A heavy anvil and a hammer rest in silhouette at the left of center; a low hearth at the right casts restrained orange-gold firelight across worn flagstones, suspended blades and iron tools. The central band stays uncluttered and low contrast for upgrade cards and a math question; the warmth is contained at the edges rather than in the middle. A few suspended sparks and a thin veil of smoke, but no fireworks. Charcoal, muted steel, burgundy leather, aged gold and amber. Premium painterly 2D dark-fantasy environment art, realistic stone, iron and leather texture, layered depth, filmic lighting. No blacksmith, no people, no characters, no text, no letters, no numbers, no equations, no mathematical notation, no pseudo-writing, no readable runes on the metal, no interface, no border, no logo, no watermark, no excessive sparks, no neon.
```

## 6. Santuario — el ángel

**Destino previsto:** `assets/art/environments/angel.png`  
**Zona segura:** centro oscuro para la pregunta; la izquierda del tercio superior puede recibir el retrato recortado del ángel.

```text
Create a 16:9 landscape static background plate for a rare healing encounter in a premium dark-fantasy RPG, 1600 x 900 px, opaque PNG.

A secluded healing sanctuary inside the same ancient crypt: a small carved stone altar at the far end of a broad, mostly empty chamber, worn flagstones, heavy medieval arches, a few iron candle sconces with restrained flames, faint pale-violet haze and a soft pool of warm gold light descending from above. The central horizontal band stays dark, calm and low contrast for an encounter card and a math question. The left third is slightly quieter and softly lit, reserved for a separate angel cutout. Charcoal, slate, muted steel, aged gold and a restrained violet glow. Premium painterly 2D dark-fantasy environment art, realistic stone and fabric texture, layered depth, soft atmospheric perspective, solemn and restorative. No angel, no wings, no halo, no person, no creature, no text, no letters, no numbers, no equations, no mathematical notation, no pseudo-writing, no readable runes, no interface, no border, no logo, no watermark, no bright white wash, no neon.
```

## 7. Muerte — el pasillo que olvida

**Destino previsto:** `assets/art/environments/death.png`  
**Zona segura:** centro horizontal tranquilo para “Has caído”, las estadísticas y el resumen.

```text
Create a 16:9 landscape static background plate for the permanent-death screen of a premium dark-fantasy mathematical roguelike, 1600 x 900 px, opaque PNG.

An empty medieval crypt corridor after a failed run: weathered charcoal stone blocks, tall receding arches, cracked flagstones, extinguished iron braziers and a small distant burgundy ember with a trace of smoke. Frame the passage symmetrically with strong depth. The central horizontal band remains dark, calm and low contrast for a large death title, stat tiles and a run-summary panel. Charcoal, muted steel, burgundy and a faint cool violet ambience; a weak warm ember provides the only color accent. Premium painterly 2D dark-fantasy environment art, realistic stone texture, filmic contrast, soft atmospheric perspective, somber but readable and never pitch black. No body, no bones, no blood, no gore, no people, no creatures, no text, no letters, no numbers, no equations, no mathematical notation, no pseudo-writing, no readable runes, no interface, no border, no logo, no watermark, no neon.
```

## 8. Archivo de maestría — fondo opcional compartido

**Destino previsto:** `assets/art/environments/archive.png` (opcional para Maestría y Ajustes)  
**Zona segura:** banda central para las cinco filas de maestría o el formulario de ajustes; estanterías laterales en penumbra.

```text
Create a 16:9 landscape static background plate for the permanent mastery archive of a premium dark-fantasy RPG, 1600 x 900 px, opaque PNG.

A long underground scriptorium and reliquary beneath the crypt: shelves of closed leather-bound books with completely blank spines, rolled parchments tied with cord, sealed stone niches and a few iron candle sconces. Strong receding perspective; the central horizontal band is dark, quiet and low contrast for a mastery table or settings form. Side shelves and arches frame the composition in deep shadow, with restrained warm amber candlelight and a faint violet arcane haze. Charcoal, slate, aged leather, muted steel, burgundy and amber. Premium painterly 2D dark-fantasy environment art, realistic wood, leather and stone texture, soft atmospheric perspective. No legible writing, no letters, no numbers, no equations, no mathematical notation, no pseudo-writing, no readable runes, no open books with text, no people, no creatures, no interface, no border, no logo, no watermark, no bright center, no neon.
```

## 9. Ornamentos de UI reutilizables — hoja PNG opcional

**Destino previsto:** `assets/art/ui/ornaments-gold-sheet.png`  
**Uso previsto:** esquinas de panel, separadores y remates. No reemplaza los marcos dibujados en código; se integraría solo si una pasada futura decide usarlo.  
**Fondo:** transparente real, sin sombra de contacto ni cuadrícula visible.

```text
Create a clean reusable ornament sheet for the dark-fantasy UI of Limits Breaker. Canvas 1024 x 512 px, transparent background, exactly 4 columns by 2 rows with no gutters and no dividing lines.

Eight isolated antique-gold UI ornaments, centered in equal 256 x 256 px cells with generous transparent padding and no element crossing a cell boundary. Row 1: an upper-left corner filigree, an upper-right corner filigree, a lower-left corner filigree, a lower-right corner filigree. Row 2: a slim horizontal divider with a small diamond center, a slim vertical divider with a small diamond center, a single diamond finial, and a small symmetrical laurel flourish. Consistent hand-painted aged-gold metal, restrained highlights, subdued charcoal shadows and worn edges; readable when scaled for a 1280 x 720 game panel. No text, letters, numbers, equations, mathematical notation, pseudo-writing, runes, logos, watermarks, frames, backgrounds, UI mockups, or extra ornaments.
```

## Checklist antes de integrar una imagen

1. Revisar al 100 % que no haya letras, números, ecuaciones ni runas legibles, incluso en los libros, la piedra o los reflejos.
2. Comprobar que la zona segura elegida siga oscura y sin focos duros detrás del HUD, las tarjetas y los botones.
3. Verificar que no aparezcan personas, enemigos o partes de cuerpos en los fondos de entorno.
4. Rechazar cualquier imagen con marcos de interfaz, botones, logos o marcas de agua horneados.
5. Recortar a 1280 × 720 para revisar el encuadre real; conservar el original 1600 × 900.
6. Guardar candidatos en `output/comfy/ui-art-review/` y no sobrescribir los PNG activos hasta aprobar la imagen.
7. Si se reemplaza un fondo, mantener el archivo anterior como respaldo y ejecutar las dos suites de pruebas.

## Integración prevista

| Pantalla | Archivo activo | Prompt |
|---|---|---|
| Menú | `assets/art/environments/menu.png` | 1 |
| Combate normal | `assets/art/environments/dungeon.png` | 2 |
| Jefe | `assets/art/environments/boss-arena.png` | 3 |
| Victoria | `assets/art/environments/boss-arena.png` | 4 (requiere nueva entrada `victory`) |
| Fragua | `assets/art/environments/forge.png` | 5 |
| Ángel | `assets/art/environments/angel.png` | 6 |
| Muerte | `assets/art/environments/death.png` | 7 |
| Maestría / Ajustes | `assets/art/environments/menu.png` | 8 (opcional) |
| Ornamentos | marco dibujado en código | 9 (opcional) |

Ninguna generación es necesaria para que el juego funcione: todas las pantallas ya tienen arte activo y las pruebas no dependen de estos prompts.
