# Arte y recursos

Los recursos que carga el juego están en `assets/`. Esta página describe el contenido activo y su procedencia; los borradores, capturas de revisión y resultados intermedios no forman parte del paquete necesario para jugar.

## Recursos activos

| Grupo | Archivos | Descripción |
|---|---|---|
| Personajes | `assets/art/characters/` | Veintiún retratos PNG de 512 × 512 con transparencia; doce incorporaciones de enemigos ajustadas al acabado pictórico original. |
| Entornos | `assets/art/environments/` | Seis fondos PNG para menú, cripta, jefe, fragua, ángel y muerte. |
| Interfaz | `assets/art/ui/` | Marco rasterizado de paneles; el texto y los controles se dibujan en Godot. |
| Equipo | `assets/art/icons/items/` | Quince iconos PNG de 128 × 128 con transparencia: once maestros originales y cuatro iconos propios nuevos. |
| Efectos | `assets/art/effects/` | Diez PNG de 256 × 256, incluida la partícula de combate. |
| Tipografías | `assets/fonts/` | Inter, Cinzel y STIX Two Math; sus licencias OFL están junto a los archivos. |
| Audio | `assets/audio/` | Música y efectos WAV locales, registrados en `audio_manifest.json`. |

Cada uno de los dieciocho enemigos tiene un retrato propio. Los veintidós objetos anteriores reutilizan once maestros de icono con tintes de runtime; los cuatro objetos añadidos tienen iconos propios. No se cargan sprites animados ni video; las partículas, los tweens y la interfaz producen el movimiento durante la partida.

## Procedencia

Los retratos originales y el marco principal de interfaz se generaron con Cloudflare Workers AI FLUX.2 Dev. Las doce variantes de enemigos y los cuatro iconos nuevos se generaron con Cloudflare Workers AI FLUX.2 Klein 4B y se prepararon localmente como PNG transparentes, sin fondo de clave ni sombra de estudio. Los iconos de equipo y los efectos originales proceden de generaciones locales con ComfyUI y FLUX.2 Klein 4B. Los fondos se conservaron de iteraciones anteriores. La música se sintetizó localmente.

Los recursos activos están preparados como PNG estáticos. Los prompts de producción y la dirección pictórica están en `assets/art/prompts/` y [ART_DIRECTION.md](ART_DIRECTION.md). Los PNG se muestran con su pintura original: no se les aplica posterización ni contornos automáticos.
