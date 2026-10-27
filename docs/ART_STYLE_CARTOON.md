# Biblia de estilo: fantasía oscura ilustrada

Actualizado: 2026-10-27. Este documento es la definición visual de **Limits Breaker** para producir nuevos assets PNG más adelante. No autoriza a reemplazar los assets activos y no introduce imágenes nuevas en el juego.

- **Nombre interno del estilo:** `dark_storybook_cartoon`.
- **Estado de la definición:** cerrada para producción futura.
- **Instrucción del usuario:** definir el estilo para luego generar nuevos assets visuales.
- **Assets nuevos:** no generados.
- **Assets activos:** sin reemplazos.
- **Piloto runtime:** existe un tratamiento opcional en `src/ui/toon_art.gd`; no es parte obligatoria del estilo final.
- **Regla fija:** todo el arte del juego son PNG estáticos. No se añaden sprites animados, video ni SVG de arte. Los textos, ecuaciones y controles siguen siendo nodos editables de Godot.

## 1. Identidad

### La idea en una frase

**Un libro de cuentos oscuro con personajes de silueta exagerada y expresión clara, pintado con gouache digital, no una estética anime ni chibi.**

El juego debe seguir sintiéndose grave, húmedo y antiguo. Lo que cambia es la forma de dibujar: menos textura fotográfica, más decisión gráfica; menos anatomía realista, más carácter; menos detalle microscópico, más lectura instantánea.

### Lo que el estilo no es

- No es anime, manga ni seriefilo.
- No es chibi, super-deformed ni caricatura cómica.
- No es vector plano, cel shading duro ni ilustración infantil.
- No es realismo fotográfico, render 3D ni piel con poros.
- No es un filtro aplicado a una imagen terminada. La estilización debe estar dibujada en el asset.
- No es una excusa para iluminar toda la escena. El fondo sigue siendo oscuro y contenido.

### Lo que debe seguir intacto

- La fantasía oscura medieval: criptas, hierro, piedra húmeda, ceniza, velas, borgoña y violeta arcano.
- La paleta carbón, acero, borgoña, violeta y ámbar.
- La legibilidad de la interfaz y de las ecuaciones.
- El tono serio: los personajes están cansados, no son mascotas.
- El funcionamiento offline y el pipeline de PNG estáticos.
- Las etiquetas ya probadas de la interfaz: `Nueva run`, `Continuar`, `Volver al camino`, `Nueva expedición`, `Menú`, `Volver`, `Atacar`, `No existe`.

## 2. Style lock

Este bloque es la referencia principal. Se puede copiar al inicio de cualquier prompt de personaje, enemigo, entorno, icono o efecto.

```text
DARK STORYBOOK CARTOON — LIMITS BREAKER STYLE LOCK
Premium hand-painted dark-fantasy RPG art for a static 2D game. Bold, readable silhouettes; slightly stylized 5.5–6.5 head proportions; larger hands, boots and weapons; expressive but serious faces; chunky simplified shapes; two to three value steps per material; subtle dark ink contour around the silhouette and major planes; hand-painted gouache texture with visible brush character; controlled saturation; charcoal stone, aged steel, weathered leather, muted burgundy cloth, restrained arcane violet and warm amber practical light; cinematic side lighting; soft atmospheric depth; matte materials; grounded weight; dark storybook mood. The image must read clearly at game size. Not anime, not manga, not chibi, not super-deformed, not flat vector, not glossy 3D, not photorealistic, not comic-book childish, not bright cartoon, not neon.
```

### Negative lock

```text
NEGATIVE: anime, manga, chibi, super-deformed, cute mascot, comic-child style, flat vector, hard cel shading, thick uniform outline, neon, rainbow, pastel palette, bright white wash, glossy plastic, photorealistic skin, pores, 3D render, blurry, low contrast, muddy, excessive detail, noisy texture, floating props, extra limbs, fused fingers, deformed hands, duplicate weapons, text, letters, numbers, equations, mathematical notation, readable runes, pseudo-writing, symbols that look like writing, interface, buttons, frame, border, logo, watermark, signature, UI elements, scenery inside a character cutout, cast shadow outside the silhouette.
```

## 3. Gramática visual

### 3.1 Silueta antes que detalle

Cada personaje debe reconocerse por su contorno. Si al reducir la imagen a 150 px se pierde la identidad, el dibujo no está listo.

- El héroe se reconoce por la espada corta, el cuaderno de campo y la capa compacta.
- El esqueleto por la cadera estrecha, la postura inclinada y la calavera grande.
- El brigante por el abrigo de cuero, el escudo pequeño y la bufanda borgoña.
- El guardián por la armadura ancha, el hacha a dos manos y la visera vacía.
- El cultista por la media máscara angular y la silueta de capas.
- El coloso por los hombros, el brazo enorme y el núcleo violeta.
- Limitless por la corona rota, la masa vertical y el manto desgarrado.
- El herrero por el delantal, los antebrazos y el martillo.
- El ángel por el halo fino, las manos abiertas y la verticalidad de las ropas.

La silueta debe funcionar en negro puro. Si el contorno negro no se lee, el color no va a salvarlo.

### 3.2 Proporción estilizada, no cómica

- Figura de **5,5 a 6,5 cabezas**.
- Cabeza: entre **1,05 y 1,10 veces** la proporción actual; nunca el doble.
- Manos: **1,10 a 1,20 veces** más grandes.
- Botas y guantes: **1,10 a 1,20 veces** más anchos.
- Armas: **1,15 a 1,25 veces** más grandes y con silueta más simple.
- Hombros y torso: **1,05 a 1,15 veces** más anchos en personajes marciales.
- Enemigos débiles: complexión estrecha y algo encorvada.
- Enemigos fuertes: masa y peso visibles, pies plantados.
- Coloso y jefe: escala mayor, pero siempre con la figura completa dentro del canvas.
- El cuerpo no se deforma para hacer gracia. La exageración es de lectura, no de comedia.

### 3.3 Rostro legible

- Ojos de tamaño estilizado, no más de **1/4 del ancho de la cara**.
- Un solo brillo pequeño por ojo; sin destellos de anime.
- Cejas gruesas y expresivas; una sombra horizontal bajo la ceja.
- Nariz como cuña o plano simple, sin aletas detalladas.
- Boca de una o dos líneas; sin labios brillantes.
- Piel mate en tres valores: sombra, medio y luz.
- Arrugas y cicatrices: una o dos, no un mapa.
- Expresión base: **cansancio alerta**. Alguien que ya ha visto lo suficiente.
- El herrero puede tener una calidez contenida; el ángel, una serenidad inquietante; Limitless no necesita un rostro humano completo.

### 3.4 Jerarquía de línea

- La línea no es un contorno uniforme de cómic.
- **Contorno de silueta:** 3–4 px en el maestro de 1024 px; 1,5–2,5 px tras reducir a 512 px.
- **Separación de planos mayores:** 1,5–2 px en 1024; 0,75–1 px en 512.
- **Pliegues menores y detalles:** sin línea; se resuelven con valor.
- Color de tinta: `#0a0c12` o `#10131a`, con opacidad del 75–90 %. Nunca negro puro.
- El contorno exterior puede ser más grueso que el interior.
- El contorno no debe cerrar cada pliegue ni cada escama.

### 3.5 Sombreado de gouache, no cel shading

- Dos o tres valores por material: sombra, medio y luz.
- Las transiciones pueden tener textura de pincel, pero no degradados fotográficos.
- La luz principal viene de un lateral, preferiblemente ámbar cálido.
- La luz de relleno es fría: violeta arcano o azul pizarra.
- El brillo metálico es ancho y direccional, no una línea blanca.
- Las sombras profundas conservan detalle; no son pozos negros.
- El resultado debe parecer pintado, no filtrado.

### 3.6 Color y luz

- El **70–80 %** de la imagen son neutros oscuros.
- Los acentos (borgoña, violeta, oro) ocupan **10–20 %**.
- Los brillos más claros ocupan **2–5 %**.
- La saturación de los acentos puede subir un **10–15 %** respecto al arte actual.
- El fondo no compite con la UI: las zonas de texto y tarjetas se mantienen oscuras y de bajo contraste.
- La luz arcana es contenida: un núcleo, un halo corto, no una explosión.
- El fuego es ámbar, no naranja saturado.
- La piedra es carbón con sombras frías y bordes cálidos.
- El hueso es marfil cálido, no blanco puro.

### 3.7 Materiales

| Material | Valores | Tratamiento cartoon |
|---|---|---|
| Piedra | 3 | Bloques grandes, aristas talladas, musgo en dos o tres masas. |
| Acero | 3 | Base oscura, brillo ancho, óxido en manchas de forma clara. |
| Cuero | 3 | Dos o tres pliegues grandes, bordes gastados, sin poros. |
| Tela | 3 | Tres pliegues mayores, peso visible, borgoña contenido. |
| Hueso | 3 | Marfil cálido, grietas de una o dos líneas, sin blancura. |
| Piel | 3 | Mate, planos simples, sin poros ni brillo plástico. |
| Oro | 2–3 | Solo como acento; brillo corto y cálido. |
| Violeta arcano | 2–3 | Núcleo claro, halo corto, sin aura ancha. |
| Madera | 3 | Vetas anchas y simples, bordes oscuros. |
| Vidrio | 3 | Un brillo direccional, reflejo simple, sin transparencia compleja. |

### 3.8 Composición

**Personajes y enemigos**

- Lienzo 1024 × 1024, PNG con alfa.
- Una sola figura centrada, cuerpo completo, cabeza y pies dentro del canvas.
- Margen libre del 8–12 % por lado.
- Vista de tres cuartos.
- Pies plantados, centro de masa estable, silueta triangular.
- Pose neutra de combate o de reposo; no una pose heroica que no se pueda reutilizar.
- Sin suelo, sin escena, sin sombra de contacto fuera de la silueta.
- Sin texto, letras, números, ecuaciones, runas legibles, logos ni marcos.

**Fondos**

- PNG opaco 16:9; objetivo 1600 × 900, mínimo 1024 × 576.
- Arquitectura en masas grandes y legibles.
- Profundidad atmosférica: primer plano oscuro, plano medio legible, fondo desaturado.
- Zonas limpias reservadas para la UI.
- Sin personas, criaturas, texto, runas, marcos, botones ni logotipos.

**Iconos**

- PNG 128 × 128 con alfa.
- Un solo objeto centrado, con 20–25 % de margen.
- Silueta reconocible a 48 px y todavía legible a 32 px.
- Sin fondo cuadrado, sin marco, sin texto, sin números.

**Efectos**

- PNG 256 × 256 con alfa.
- Una sola forma o ráfaga legible.
- Sin fondo, sin texto, sin marcos.
- El efecto debe leerse como forma estática; la animación la pone Godot.

**UI**

- Marco de libro antiguo, no consola moderna.
- Bordes de 2 px, esquinas de 5–6 px, marcas de esquina más gruesas.
- Madera, latón gastado, tinta y cuero.
- Controles grandes, texto editable y ecuaciones legibles.
- La UI no debe imitar el contorno de los personajes; su función es enmarcar, no competir.

### 3.9 Pose y movimiento implícito

Aunque el PNG sea estático, la pose debe sugerir dirección:

- El héroe inclina ligeramente el torso hacia el arma.
- El esqueleto carga el peso hacia un lado.
- El brigante protege el torso con el escudo.
- El guardián planta los pies y deja caer el hacha.
- El cultista mantiene las manos cerca del foco arcano.
- El coloso arrastra el brazo enorme.
- Limitless se eleva desde una base de polvo y manto.
- El herrero apoya el martillo con familiaridad.
- El ángel abre las manos con las palmas hacia arriba.

No se permiten poses que dependan de un efecto de animación para entenderse.

## 4. Paleta

| Rol | Hex | Uso |
|---|---|---|
| Tinta | `#07080a` | Contornos, sombras más profundas, fondo de pantalla. |
| Carbón | `#0b0d10` | Fondo general, piedra en sombra. |
| Panel | `#12151b` | Paneles de UI, planos oscuros. |
| Pizarra | `#2a303a` | Piedra media, armadura en sombra. |
| Acero | `#687283` | Metal medio, textura de hoja. |
| Acero claro | `#a3adbb` | Brillos metálicos, bordes de luz. |
| Borgoña | `#8f3043` | Telas, cuero teñido, acentos de facción. |
| Borgoña claro | `#c34d64` | Acento de tela, no grandes áreas. |
| Violeta | `#6657a4` | Arcano en sombra, cristales, viseras. |
| Violeta claro | `#8c78d6` | Núcleo arcano, detalles pequeños. |
| Oro | `#8d713c` | Latón gastado, adornos, herrajes. |
| Oro claro | `#d8ad60` | Último brillo cálido, halo, llama. |
| Hueso | `#c9bda3` | Cráneos, marfil, piedra clara. |
| Ceniza | `#8a857c` | Polvo, ceniza, tela gastada. |

Reglas de uso:

- No usar blanco puro salvo en el núcleo más pequeño de una llama o un brillo.
- No usar negro puro en el contorno.
- El violeta no debe dominar una escena; es un acento de misterio.
- El oro no debe cubrir armaduras completas; es un detalle.
- El borgoña identifica peligro, facción o tela; no es el color base de todo.
- La piel no lleva naranja saturado; usar tonos mates y desaturados.

## 5. Especificaciones por familia

### 5.1 Personajes y enemigos

- Maestro: 1024 × 1024, PNG con alfa.
- Runtime actual: 512 × 512.
- Una sola figura, cuerpo completo, tres cuartos.
- Contorno de silueta de 3–4 px en el maestro.
- Tres valores por material.
- Manos y armas ligeramente exageradas.
- Rostro legible a 128 px.
- Silueta legible a 150 px.
- Sin fondo, sin suelo, sin texto.
- Mantener el nombre de archivo y la ruta actuales al reemplazar.

### 5.2 Fondos

- 1600 × 900 objetivo; 1024 × 576 mínimo.
- PNG opaco.
- Sin personajes ni criaturas.
- Zonas de UI oscuras y tranquilas.
- Arquitectura en masas grandes.
- Profundidad por capas, no por ruido.
- Sin texto, runas, marcos ni botones.
- Mantener los nombres `menu`, `dungeon`, `boss-arena`, `forge`, `angel`, `death`.

### 5.3 Iconos de equipo

- Maestro de 128 × 128 con alfa.
- Hoja de generación de 4 × 3 celdas si se produce en lote.
- Un objeto por celda, sin líneas divisorias.
- Silueta exagerada, tres valores, un brillo direccional.
- Sin fondo, texto, números ni marcos.
- Los 22 objetos actuales reutilizan 11 maestros con tintes de runtime; no hace falta generar 22 iconos únicos en la primera pasada.

### 5.4 Efectos

- 256 × 256 con alfa.
- Forma única y legible.
- Sin fondo, texto ni marcos.
- La estrella de partículas reutiliza `particle.png`; el halo radial se genera en runtime.
- Los efectos deben combinar con el contorno y la paleta, pero no deben tapar la UI.

### 5.5 UI

- Marco PNG de 512 × 512 preparado para nueve parches.
- Bordes de 2 px y esquinas de 5–6 px en los paneles planos.
- Marcas de esquina más gruesas y ornamentales.
- Sin texto horneado en las imágenes.
- Los títulos, etiquetas, botones y ecuaciones siguen siendo nodos editables.

## 6. Roster de personajes

La tabla define el gancho de silueta y los materiales. Cualquier prompt de personaje debe combinar el style lock con esta información.

| ID | Rol | Gancho de silueta | Materiales y acentos | Expresión | Palabras clave para el prompt |
|---|---|---|---|---|---|
| `player` | Héroe | Espada corta + cuaderno de campo + capa compacta | Carbón, acero, borgoña, violeta mínimo | Cansancio alerta | scholar-warrior, short sword, field notebook, worn cloak, compact stance |
| `skeleton` | Enemigo débil | Cadera estrecha, calavera grande, espada astillada | Hueso, hierro desigual, fajín borgoña | Vacía, amenazante | fragile skeleton, mismatched iron, chipped blade, hunched silhouette |
| `brigand` | Enemigo ordinario | Abrigo de cuero, escudo pequeño, bufanda | Cuero, acero opaco, borgoña | Confiado y cansado | road brigand, leather coat, small buckler, burgundy scarf |
| `warden` | Enemigo fuerte | Armadura ancha, hacha a dos manos, visera vacía | Placa de acero, correas borgoña, violeta en la visera | Sin rostro, implacable | empty plate armor, heavy axe, broad shoulders, violet visor |
| `cultist` | Enemigo élite | Media máscara angular, capas, foco de cristal | Carbón, borgoña, violeta | Sereno, intimidante | angular half-mask, layered robes, crystal focus, no readable symbols |
| `colossus` | Miniboss | Hombros gigantes, brazo de piedra y hueso, núcleo violeta | Hueso, hierro de reja, violeta | Grave, sin gore | towering bone colossus, layered bones, gate iron, violet core |
| `limitless` | Jefe final | Corona rota, masa vertical, manto desgarrado | Carbón, polvo de piedra, violeta, oro | Extraño, imponente | broken iron crown, torn black mantle, chest fissure, partly human |
| `blacksmith` | NPC | Delantal, antebrazos, martillo | Cuero, hierro, ámbar de fragua | Cálido y concentrado | broad blacksmith, leather apron, hammer, rolled sleeves, forge light |
| `angel` | NPC raro | Halo fino, manos abiertas, ropas verticales | Piedra pálida, marfil, oro, violeta pálido | Sereno e inquietante | rare angelic visitor, pale stone robes, fine halo, open hands, modest silhouette |

## 7. Mapa de entornos

| ID | Composición | Luz | Zonas limpias | Evitar |
|---|---|---|---|---|
| `menu` | Nave de cripta, plinto a la izquierda, arco circular al centro-derecha | Ámbar lateral + violeta contenido en el arco | Centro y tercio derecho oscuros para el panel | Personajes, texto, arco demasiado brillante |
| `dungeon` | Corredor de cripta, columnas rotas a los lados, fondo con arcos | Ámbar tenue + destellos violeta | Banda central baja en contraste | Multitud de detalles, foco central |
| `boss_arena` | Arena vasta, dais circular roto, arcos negros, puerta sellada | Violeta al fondo, ámbar en el suelo | Tercio medio tranquilo | Figuras, gore, runas legibles |
| `forge` | Fragua compacta, yunque y martillo en silueta, cuchillas suspendidas | Fuego ámbar bajo, sombras carbón | Centro despejado para pregunta y cartas | Chispas excesivas, texto, gente |
| `angel` | Santuario de curación, altar al fondo, arcos pesados, velas | Oro cálido + bruma violeta pálida | Banda central oscura y calmada | Alas, halos, figuras, símbolos religiosos |
| `death` | Corredor simétrico, arcos en fuga, braseros apagados, ascua borgoña lejana | Borgoña y violeta muy contenidos | Banda central para el resumen | Cuerpos, huesos, gore, oscuridad total |

## 8. Iconos y efectos

### Iconos maestros actuales

`rusted_blade`, `ashen_edge`, `arcane_staff`, `iron_cuirass`, `warden_plate`, `oak_shield`, `ember_charm`, `void_sigil`, `pilgrim_relic`, `healing_draught`, `greater_draught`.

Reglas:

- La silueta debe leerse a 48 px.
- El objeto debe estar centrado y completo.
- El brillo debe venir de una sola dirección.
- El contorno debe ser fino; el icono no es un personaje.
- El fondo debe ser transparente, sin tarjeta ni marco.
- Los objetos nuevos de la ampliación pueden seguir reutilizando estos maestros con tintes de runtime.

### Efectos actuales

`slash`, `arcane`, `critical`, `impact`, `heal`, `defeat`, `correct`, `incorrect`, `forge_spark`, `particle`.

Reglas:

- Una forma principal por efecto.
- Sin texto ni números.
- Sin desenfoque fotográfico.
- El efecto debe funcionar sobre fondo oscuro y sobre paneles de UI.
- La animación se compone en Godot con partículas y tweens.

## 9. Prompts de producción

Los prompts están en inglés para facilitar su uso con generadores de imagen. No incluyen nombres de artistas ni propiedades intelectuales. Todos excluyen texto, letras, números, ecuaciones, notación matemática, runas legibles, logos y marcas de agua.

### 9.1 Cómo usar el style lock

Cada prompt de producción debe comenzar con el **Style lock** de la sección 2 y terminar con el **Negative lock**. Después se añade el sujeto, la composición y los detalles específicos.

Fórmula:

```text
[STYLE LOCK]
[SUBJECT AND ROLE]
[SILHOUETTE AND PROPORTION]
[MATERIALS AND PALETTE]
[LIGHT AND MOOD]
[COMPOSITION AND CANVAS]
[NEGATIVE LOCK]
```

### 9.2 Héroe — maestro de personaje

```text
Create one production-ready character master still for the 2D dark-fantasy game Limits Breaker, in the dark storybook cartoon style defined above. Canvas 1024 x 1024 px, transparent background, PNG with clean alpha. Exactly one full-body scholar-warrior, centered, head and both feet fully inside the canvas, neutral combat stance, three-quarter view. Short steel sword in one hand and a closed field notebook at the belt. Worn charcoal cloak, muted steel armor, burgundy cloth, tiny violet arcane accents, restrained warm-gold details. Slightly larger hands, chunky boots and simplified armor planes; face readable at 128 px with an alert, tired expression. Hand-painted gouache texture, two to three value steps per material, subtle dark ink contour around the silhouette, cinematic amber rim light. No scenery, no ground plane, no cast shadow outside the silhouette, no frame, no text, no letters, no numbers, no symbols, no readable runes, no watermark, no extra props.
```

### 9.3 Esqueleto — enemigo débil

```text
Create one production-ready enemy master still for the 2D dark-fantasy game Limits Breaker, dark storybook cartoon style. Canvas 1024 x 1024 px, square, transparent PNG. Exactly one full-body fragile dungeon skeleton, centered, head and feet fully visible, three-quarter view, readable at 150 px tall. Mismatched iron scraps, torn burgundy sash, chipped short blade; narrow hunched silhouette, threatening but not gory. Slightly oversized skull and hands, simplified ribcage and armor shapes, two to three value steps, subtle dark ink contour, gouache texture. Charcoal shadows, muted steel, burgundy and tiny warm-gold accents. No scenery, no floor, no frame, no text, no letters, no numbers, no equations, no readable runes, no watermark, no extra figures.
```

### 9.4 Limitless — jefe final

```text
Create one production-ready final boss master still for the 2D dark-fantasy game Limits Breaker, dark storybook cartoon style. Canvas 1024 x 1024 px, transparent PNG. Exactly one full-body memorable boss, centered, whole silhouette inside frame, three-quarter view. The Limitless: a tall ancient medieval-fantasy threat whose outline is partly human and partly a torn black mantle of stone dust, with a broken iron crown and a contained arcane-violet fissure through the chest. Powerful and strange, not a generic demon, no gore, no readable symbols. Bold vertical silhouette, larger hands and a heavy mantle; three value steps per material; subtle dark ink contour; gouache texture. Charcoal, muted steel, restrained burgundy, contained violet and faded gold. No scene, floor, frame, text, letters, numbers, equations, readable runes, watermark or extra characters.
```

### 9.5 Menú — placa de fondo

```text
Create a 16:9 landscape static background plate for the dark-fantasy mathematical roguelike Limits Breaker, dark storybook cartoon direction, 1600 x 900 px, opaque PNG. A vast ancient crypt nave seen from a low, reverent angle. On the far left, a narrow raised stone plinth and a tall empty wall niche, softly rim-lit with warm amber, reserved for a standing hero cutout. Center-right, a colossal circular stone gate with worn abstract carved geometry that reads only as erosion and age, and a deep restrained violet arcane glow inside it. The entire right third must be darker, simpler and lower contrast for a vertical menu panel. Foreground of worn flagstones, broken column bases and a few thin gold dust motes. Larger, chunkier stone masses, simplified carved planes, hand-painted gouache texture, soft atmospheric perspective, cinematic contrast, charcoal, muted steel, restrained burgundy, faded gold and contained violet. No people, no hero, no monsters, no text, no letters, no numbers, no equations, no pseudo-writing, no readable runes, no interface, no border, no logo, no watermark, no bright central light, no neon, no anime, no flat vector.
```

### 9.6 Hoja de iconos

```text
Create a production-ready 4-column by 3-row inventory icon sheet for the dark-fantasy game Limits Breaker, dark storybook cartoon direction. Canvas 1024 x 768 px, transparent background, PNG with clean alpha. Twelve equal 256 x 256 cells with no gutters and no dividing lines; exactly one isolated centered object per cell with generous padding. Row 1: rusted short sword, ashen enchanted sword with violet edge light, dark oak arcane staff with violet crystal, worn iron cuirass. Row 2: heavier warden plate with burgundy binding, old oak shield with steel rim, amber ember charm, dark-violet void sigil. Row 3: carved pilgrim relic, green healing draught, larger amber healing draught, empty cell with no object. Bold readable silhouettes at 48 px, chunky simplified shapes, three value steps, subtle dark ink contour, hand-painted gouache texture, matte metal, leather, wood and glass, charcoal shadows, muted steel, restrained burgundy, contained violet and warm amber. No background tiles, frames, text, letters, numbers, equations, readable runes, logos, watermarks, extra objects or scenery.
```

### 9.7 Ejemplo de entorno de combate

```text
Create a 16:9 landscape background plate for the 2D game Limits Breaker, dark storybook cartoon direction, 1600 x 900 px, opaque PNG. An ancient medieval crypt corridor used behind a turn-based RPG combat interface. A clear, quiet central band with low-contrast stone floor and distant arches, broken columns framing the far left and right, a few restrained violet arcane glints and warm gold dust. Charcoal, muted steel and burgundy palette. Larger chiseled stone masses, simplified carved planes, hand-painted gouache texture, layered depth, soft atmospheric perspective, readable beneath dark translucent UI panels. No people, monsters, weapons, text, letters, numbers, equations, readable runes, logos, interface, bright focal point, or gore.
```

### 9.8 Ejemplo de efectos

```text
Create one production-ready combat effect sprite for the 2D dark-fantasy game Limits Breaker, dark storybook cartoon direction. Canvas 256 x 256 px, transparent PNG. A single diagonal slash of pale steel light with a thin violet arcane edge, a dark ink contour and a small warm-gold spark at the impact point. Bold readable shape, two to three value steps, hand-painted gouache texture, no background, no text, no letters, no numbers, no equations, no readable runes, no frame, no watermark. The effect must read clearly on a dark stone background and on a dark UI panel.
```

### 9.9 Referencias y consistencia

- Usar los PNG actuales como referencia de identidad cuando el generador permita imagen de referencia o edición.
- Si se usa edición de imagen, pedir explícitamente **restyle, preserve costume and silhouette** para no perder el diseño.
- No encadenar generaciones sin control: cada asset debe compararse con la hoja de calibración.
- Mantener el mismo style lock y negative lock en toda la producción.
- Las variaciones de tinte de runtime no necesitan PNG nuevos en la primera pasada.
- No generar texto dentro de la imagen para "explicar" el asset. El nombre va en el archivo, no en el dibujo.

## 10. Flujo de producción

1. **Calibración:** generar tres candidatos de héroe, esqueleto y menú. Aprobar uno de cada uno antes de producir el resto.
2. **Referencia:** usar los PNG actuales como referencia de identidad y composición cuando el generador lo permita.
3. **Generación:** aplicar style lock + subject + negative lock. Respetar 1024 × 1024 para personajes y 1600 × 900 para fondos.
4. **Recorte:** eliminar fondo, conservar alpha limpio, revisar bordes y dedos.
5. **Reducción:** bajar a 512 × 512 con Lanczos y revisar la silueta a 150 px y la cara a 128 px.
6. **Integración:** reemplazar el PNG manteniendo el nombre y la ruta; probar en menú, combate, fragua, ángel, muerte y victoria.
7. **QA visual:** capturas a 1280 × 720; comprobar que el texto sigue legible y que el fondo no compite con la UI.
8. **QA técnica:** ejecutar las dos suites, `layout_measure.tscn` y `layout_preview.tscn`.
9. **Archivo:** conservar los PNG anteriores en `output/archive/previous-placeholder-art/` o en la carpeta de revisión correspondiente.
10. **Documentación:** actualizar `docs/ART_ASSETS.md`, el manifiesto de generación y este documento si cambia una regla.

### Handoff técnico

- Cuando los PNG nuevos estén aprobados e integrados, **desactivar el shader del piloto** (`ToonArt.ENABLED = false`) para no aplicar dos veces la estilización.
- El shader actual es una referencia de transición, no un sustituto de los assets nuevos.
- No cambiar los nombres de archivo ni las rutas de `AssetManifest` durante un reemplazo.
- No añadir IDs nuevos al manifiesto hasta que el archivo exista.
- No tocar el balance, las etiquetas de UI ni el comportamiento de guardado por un cambio de arte.

## 11. Criterios de aceptación

- La imagen se reconoce como Limits Breaker, no como otro juego.
- El personaje se lee a 150 px y la cara a 128 px.
- El icono se lee a 48 px y sigue siendo reconocible a 32 px.
- La silueta es más fuerte que la textura.
- El resultado es más cartoon que el arte actual, pero no infantil, anime ni chibi.
- La paleta sigue siendo oscura; los acentos no dominan.
- El contorno es oscuro y controlado, no una línea gruesa uniforme.
- Los materiales tienen dos o tres valores, no un degradado fotográfico.
- Las manos, armas y botas se sienten ligeramente exageradas, no deformes.
- No hay texto, letras, números, ecuaciones, notación matemática ni runas legibles.
- No hay fondos dentro de un cutout de personaje.
- Los fondos mantienen zonas limpias para la UI.
- El alpha está limpio, sin halos, bordes verdes ni restos de fondo.
- El juego sigue funcionando sin conexión y sin assets animados.
- Las dos suites pasan y las capturas de 1280 × 720 no muestran recortes ni solapamientos.

## 12. Plan de sustitución

1. **Piloto:** héroe, esqueleto y menú.
2. **Personajes:** los nueve maestros PNG, manteniendo nombres y rutas.
3. **Enemigos especiales:** coloso, Limitless, ángel y herrero, con la misma escala y alpha.
4. **Fondos:** menú, cripta, fragua, santuario, arena del jefe y muerte.
5. **Iconos y efectos:** hoja de iconos y ajuste de efectos para que combinen con el nuevo contorno.
6. **UI:** si hace falta, una hoja de ornamentos y marco; no hornees texto en ella.
7. **QA final:** suites, medidas, capturas y revisión de legibilidad.

No se debe reemplazar un PNG activo hasta tener el candidato aprobado, el recorte limpio, el alpha verificado y una captura en contexto.

## 13. Estado de decisión

| Decisión | Estado |
|---|---|
| Nombre y dirección `dark_storybook_cartoon` | Definido |
| Style lock y negative lock | Definidos |
| Gramática visual, paleta y proporciones | Definidas |
| Especificaciones por familia | Definidas |
| Prompts de producción | Definidos para héroe, esqueleto, jefe, menú, iconos, entorno y efectos |
| Roster de personajes y mapa de entornos | Definidos |
| Criterios de aceptación | Definidos |
| Shader runtime sutil | Implementado como piloto opcional |
| UI con bordes de 2 px y esquinas redondeadas | Implementada como piloto |
| Nuevos PNG maestros | No generados |
| Reemplazo de assets activos | No iniciado |

**Siguiente paso:** cuando haya una ruta de generación disponible, producir el piloto de héroe, esqueleto y menú con este style lock, revisarlo a 1280 × 720 y solo entonces decidir la sustitución del resto.
