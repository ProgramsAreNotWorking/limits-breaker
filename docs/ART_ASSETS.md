# Arte y recursos

Los recursos que carga el juego están en `assets/`. Esta página describe el contenido activo y su procedencia; los borradores, capturas de revisión y resultados intermedios no forman parte del paquete necesario para jugar.

## Recursos activos

| Grupo | Archivos | Descripción |
|---|---|---|
| Personajes | `assets/art/characters/` | Nueve retratos PNG de 512 × 512 con transparencia. |
| Entornos | `assets/art/environments/` | Seis fondos PNG para menú, cripta, jefe, fragua, ángel y muerte. |
| Interfaz | `assets/art/ui/` | Marco rasterizado de paneles; el texto y los controles se dibujan en Godot. |
| Equipo | `assets/art/icons/items/` | Once iconos PNG de 128 × 128 con transparencia. |
| Efectos | `assets/art/effects/` | Diez PNG de 256 × 256, incluida la partícula de combate. |
| Tipografías | `assets/fonts/` | Inter, Cinzel y STIX Two Math; sus licencias OFL están junto a los archivos. |
| Audio | `assets/audio/` | Música y efectos WAV locales, registrados en `audio_manifest.json`. |

El juego reutiliza los retratos e iconos existentes con tintes de runtime para representar enemigos y objetos adicionales. No carga sprites animados ni video. Las partículas, los tweens y la animación de interfaz producen el movimiento durante la partida.

## Procedencia

Los personajes y el marco principal de interfaz se generaron con Cloudflare Workers AI FLUX.2 Dev. Los iconos de equipo y los efectos se generaron localmente con ComfyUI y FLUX.2 Klein 4B. Los fondos de entorno se conservaron de las iteraciones anteriores del proyecto. La música se sintetizó localmente; ComfyUI se usó para imágenes, no para audio.

Los recursos activos están preparados como PNG estáticos. Los prompts de producción y la dirección de arte están en `assets/art/prompts/` y [ART_STYLE_CARTOON.md](ART_STYLE_CARTOON.md). El shader de tratamiento ilustrado se limita a fondos, retratos e iconos; no afecta al texto ni a las ecuaciones.
