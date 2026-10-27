# Limits Breaker

> **Desarrollo: 100 % vibe codeado.** Este proyecto se creó por completo mediante instrucciones en lenguaje natural e iteraciones dirigidas con asistencia de IA. El código GDScript, las escenas y la interfaz, el diseño del juego, el contenido, la documentación y la integración de recursos forman parte de ese proceso. Se presenta explícitamente como un proyecto vibe-coded, no como software escrito íntegramente a mano.

Roguelike RPG de fantasía oscura en el que resolver límites es el sistema de combate. Está hecho con Godot 4.7, funciona sin conexión y no necesita servicios en línea durante la partida.

## Qué incluye

- Combate por turnos con cuatro ataques físicos y mágicos, selección de objetivo y grupos de hasta cuatro enemigos.
- Ejercicios de límites directos y laterales, gráficas, tablas y factorización. La dificultad varía según la progresión de la run y la maestría; resolver no tiene cronómetro.
- Cuatro mundos, quince enemigos, veintidós objetos, equipo, inventario, fragua, eventos especiales, muerte permanente y un jefe final.
- Maestría matemática persistente, selección adaptativa de temas, guardado local y ajustes de audio y accesibilidad.
- Música y efectos locales, partículas y efectos de combate. El movimiento se compone con tweens y animación de interfaz; los recursos gráficos son imágenes estáticas PNG.
- Pantalla de resultado de combate compacta y opciones gráficas para elegir resolución de ventana y modo ventana o pantalla completa.

## Requisitos y ejecución

Se requiere Godot 4.7 o superior. Abre `project.godot` desde el editor o ejecuta el juego desde esta carpeta:

```sh
godot --path .
```

## Controles

- Usa el ratón o el teclado para navegar por los menús y elegir ataques.
- Escribe las respuestas con un teclado físico; no hay teclado en pantalla. Se aceptan dígitos, signo, coma o punto decimal, fracciones y texto de límites. Pulsa `Enter` para responder.
- El reloj limita el tiempo para elegir el ataque, no para resolver el ejercicio. El tiempo se determina por el nivel del enemigo.

## Opciones gráficas

En **Opciones** puedes elegir el tamaño de la ventana y cambiar entre modo ventana y pantalla completa. En pantalla completa se usa la resolución del monitor; el tamaño elegido se aplica al volver al modo ventana. Los ajustes se guardan localmente.

## Documentación

- [Diseño y reglas del juego](docs/GAME_DESIGN.md)
- [Arquitectura técnica](docs/TECHNICAL_ARCHITECTURE.md)
- [Inventario y procedencia de recursos](docs/ART_ASSETS.md)
- [Dirección visual](docs/ART_STYLE_CARTOON.md)
- [Audio](docs/AUDIO.md) y [estilos musicales](docs/AUDIO_STYLES.md)

La carpeta `assets/` contiene los recursos usados por el juego. Las licencias de las fuentes tipográficas y del complemento Godot MCP incluido están junto a esos componentes.
