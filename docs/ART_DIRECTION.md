# Dirección de arte: fantasía oscura pictórica

Actualizado: 2026-10-29. Esta guía sigue la apariencia de los retratos, los fondos y los iconos originales de **Limits Breaker**. Es la referencia para revisar y producir recursos nuevos.

## Identidad visual

El juego usa ilustración digital pictórica de fantasía oscura: figuras con anatomía y volumen naturales, materiales reconocibles, textura trabajada y luz cinematográfica. La piedra se siente pesada; el metal, usado; la tela, opaca y gastada. El acabado mantiene detalle y variación de pincel sin volverse fotográfico.

Los retratos de `assets/art/characters/`, los fondos de `assets/art/environments/` y los iconos originales de `assets/art/icons/items/` fijan el acabado. La interfaz comparte su paleta y su tono medieval, y conserva una lectura limpia para las preguntas y las ecuaciones.

## Style lock

Usar este bloque al principio de cada prompt nuevo y añadir después el sujeto, el encuadre y sus materiales específicos.

```text
PAINTERLY DARK FANTASY — LIMITS BREAKER STYLE LOCK
Premium hand-painted 2D dark-fantasy RPG illustration. Natural human and creature anatomy, dimensional forms, richly rendered matte materials, layered painterly shadows and highlights, tactile cloth, worn leather, aged steel, bone and stone. Soft painted transitions with controlled edges; no heavy ink contour or flat cel shading. Cinematic, motivated warm amber light against cool charcoal fill, deep but readable shadows, restrained saturation. Charcoal, slate, muted burgundy, aged steel, restrained arcane violet and warm gold. Grounded, weathered and solemn, with a distinct silhouette readable at game size. Match the original Limits Breaker portraits and environments in volume, texture, lighting and finish.
```

```text
NEGATIVE: anime, chibi, caricature, comedic proportions, flat vector, hard cel shading, heavy comic outline, glossy plastic, photorealistic skin, pores, neon, rainbow palette, bright white wash, excessive bloom, muddy shadows, blurry detail, noisy texture, extra limbs, fused fingers, duplicate objects, text, letters, numbers, equations, mathematical notation, pseudo-writing, readable runes, interface, buttons, frames, logos, watermark, signature, scenery inside a transparent character cutout, cast shadow detached from the subject.
```

## Paleta y luz

| Rol | Hex | Uso |
|---|---|---|
| Tinta | `#07080a` | Sombras profundas, límites y fondo. |
| Carbón | `#0b0d10` | Piedra en sombra y fondos. |
| Panel | `#12151b` | Paneles de interfaz. |
| Pizarra | `#2a303a` | Piedra y metal en sombra. |
| Acero | `#687283` | Metal medio y superficies frías. |
| Acero claro | `#a3adbb` | Brillos metálicos contenidos. |
| Borgoña | `#8f3043` | Tela, cuero teñido y acentos. |
| Violeta | `#6657a4` | Magia contenida y cristales. |
| Violeta claro | `#8c78d6` | Núcleos arcanos pequeños. |
| Oro | `#8d713c` | Latón gastado y herrajes. |
| Oro claro | `#d8ad60` | Luz cálida y detalles puntuales. |
| Hueso | `#c9bda3` | Hueso, marfil y piedra clara. |
| Ceniza | `#8a857c` | Polvo, ceniza y tela gastada. |

La luz debe tener una fuente reconocible. El ámbar puede perfilar el lado iluminado; el relleno frío mantiene detalle en las sombras. La magia usa violeta en áreas pequeñas. El brillo nunca sustituye la forma ni compite con el HUD.

## Recursos

### Personajes y criaturas

- Preparar un maestro cuadrado de 1024 × 1024 y un PNG activo de 512 × 512 con alfa.
- Conservar anatomía natural, volumen, pliegues y marcas materiales; usar una pose sobria y una silueta clara.
- Mantener rostro, armas y equipo dentro del lienzo. No añadir suelo, escena, texto ni sombra separada.
- Diferenciar amenazas por su cuerpo, postura, armadura y equipo, además del color.

### Entornos

- Usar PNG opaco 16:9, idealmente 1600 × 900.
- Pintar piedra, metal, madera, cuero y tela con profundidad y textura material.
- Mantener bandas de bajo contraste para HUD, preguntas y paneles.
- Dejar personajes, enemigos, textos y controles fuera del fondo.

### Objetos e iconos

- Usar PNG 128 × 128 con alfa y un solo objeto centrado.
- Mantener la escala, el borde fino y el acabado dimensional de los iconos originales.
- Dar prioridad a la silueta y al material; los colores de rareza se aplican en la interfaz.
- Dejar margen alrededor; no incluir tarjeta, marco, texto ni fondo.

### Interfaz y efectos

- Mantener la paleta oscura, los marcos rectos de piedra y metal gastado y las marcas discretas de latón.
- Cinzel identifica títulos; Inter mantiene la lectura de controles y datos; STIX Two Math se reserva para expresiones matemáticas.
- Conservar las ecuaciones y etiquetas como texto editable de Godot.
- Usar partículas y efectos breves, con luz localizada y sin tapar información.

## Consistencia

Antes de integrar un recurso, compararlo a tamaño de juego con un retrato original, el entorno que lo acompaña y un icono existente. El volumen, la textura, la iluminación y la densidad de detalle deben pertenecer al mismo conjunto. En los recortes de personaje, revisar también los huecos entre miembros y el borde de los pies: eliminar el color de clave y las sombras de estudio sin erosionar tela, armadura ni extremidades. Los PNG conservan su pintura original; no se les aplican posterización ni contornos automáticos.

Los prompts de escenas y zonas seguras están en [art-prompts-ui.md](art-prompts-ui.md). La guía general de producción está en [prompt2.md](prompt2.md).
