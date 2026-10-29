# Diseño del juego

## Bucle de una run

El jugador entra en la cripta, escoge un ataque antes de que expire el reloj de selección, resuelve la operación sin cronómetro, ataca o recibe daño y avanza encuentro a encuentro. La derrota termina la run; el registro de aprendizaje y los ajustes sobreviven. Derrotar al jefe del encuentro 10 completa el hito de victoria.

## Combate matemático

El daño de la tabla es la base antes del multiplicador de cada técnica, el equipo y la mitigación del enemigo.

| Dificultad | Daño base | Si falla |
|---|---:|---|
| Fácil | 8 | El enemigo ataca |
| Intermedio | 14 | El enemigo ataca |
| Avanzado | 22 | El enemigo ataca y el jugador recibe además 2 HP (10% del daño base) |
| Superdifícil | 27 | El enemigo ataca y el jugador recibe además 5 HP (20% del daño base) |

Cada encuentro puede reunir hasta cuatro enemigos. El jugador selecciona uno como objetivo y luego elige una de cuatro técnicas. Los ataques de área alcanzan primero al objetivo elegido y después a los enemigos vivos en orden de formación. El Barrido llega a dos; la Nova Astral puede alcanzar a los cuatro. Cada enemigo vivo ataca en el turno, incluso si el jugador acertó; si un ataque derrota al último enemigo, no queda nadie para contraatacar. El daño de cada enemigo baja según el número de atacantes vivos para que un grupo no multiplique sin límite el daño recibido.

| Ataque | Tipo | Objetivos | Potencia | Penetración | Ajuste de dificultad |
|---|---|---:|---:|---:|---:|
| Tajo perforante | Físico | 1 | 1,00× | 2 de armadura | +1 |
| Barrido | Físico | hasta 2 | 0,78× | 0 | 0 |
| Lanza arcana | Mágico | 1 | 1,10× | 1 de resistencia mágica | +2 |
| Nova astral | Mágico | hasta 4 | 0,54× | 0 | −1 |

Cada enemigo puede tener armadura, resistencia mágica, debilidades o una combinación de ellas. La carta de cada ataque enseña su daño estimado contra el objetivo seleccionado y señala si explota su debilidad o si el enemigo lo resiste.

La dificultad de la pregunta se sortea al confirmar el ataque. La banda base depende del nivel de la run: niveles 1–2 usan Fácil–Intermedio; 3–4, Fácil–Avanzado; 5–7, Intermedio–Superdifícil; y 8–10, Avanzado–Superdifícil. Cada técnica desplaza la banda según su perfil y la maestría del tema limita el máximo disponible. Resolver la pregunta no tiene cronómetro.

Al acertar, el jugador daña a sus objetivos y todos los enemigos que sobreviven contraatacan en el mismo turno. Al fallar, los enemigos atacan; en Avanzado y Superdifícil, el retroceso propio se suma a esos golpes. El daño mínimo después de armadura es 1.

Berserk se carga durante siete turnos de combate y conserva la carga al pasar de encuentro. Al activarlo, un acierto multiplica el daño por 1,5; un fallo aún golpea con 0,4× de daño y conserva las penalizaciones normales del fallo. El turno en que se usa cuenta para la siguiente carga.

El reloj de selección no se configura desde los ajustes. Al comenzar cada turno se sortea un valor dentro de la banda del enemigo; a mayor dificultad, menos tiempo para elegir y más presión. Una vez elegido el ataque, resolver no tiene cronómetro.

| Tier del enemigo | Tiempo para elegir |
|---|---:|
| Débil | 18–22 s |
| Ordinario | 15–17,5 s |
| Fuerte | 12–14,5 s |
| Élite | 10–11,5 s |
| Miniboss | 8–9,5 s |
| Jefe | 6–7,5 s |

Los ejercicios cubren sustitución directa, límites laterales, lectura de gráficas, tablas y factorización. Las respuestas admiten números, fracciones, raíces, elecciones y límites inexistentes; el sistema muestra pistas y pasos de solución. Trigonometría se usa en el reto de la fragua.

## Enemigos y progresión

El repertorio tiene quince enemigos repartidos en cuatro mundos: Cripta de los Juramentos (encuentros 1–3), Galerías de Ceniza (4–6), Santuario de la Campana Rota (7–9) y Trono del Innombrable (10). Las apariciones normales salen del pool de cada mundo. El primer encuentro es individual; después los grupos crecen hasta cuatro enemigos (los jefes y el miniboss siguen individuales). Desde el tercer encuentro de un mundo puede aparecer un élite con 35% de probabilidad. Los enemigos se muestran como figuras seleccionables sobre el escenario; los no jefes llevan una barra de vida pequeña sobre el retrato y el jefe conserva una barra grande en el HUD.

Cada baja da XP según el rango del enemigo. La XP sube el nivel de la run hasta 10 y amplía gradualmente las bandas aleatorias de dificultad de los ataques. Este nivel y la carga Berserk son temporales y se reinician al comenzar otra run.

La fragua aparece cada cuatro encuentros a partir del cuarto y ofrece una mejora de arma, armadura o reliquia a cambio de resolver un reto. Desde el encuentro 3 puede aparecer un ángel con probabilidad del 6%, como máximo una vez por run; acertar cura según la dificultad y fallar cura 1 HP. Ambos eventos solo se abren entre combates, después de completar el encuentro; nunca durante una pelea activa.

Hay veintidós objetos entre armas, armaduras, reliquias y consumibles. El botín combina la tabla del tier enemigo con una tabla temática del mundo. Los objetos nuevos reutilizan los once iconos PNG existentes y se distinguen por tinte de runtime. El inventario lleva hasta cuatro objetos; arma, armadura y reliquia tienen ranuras equipables. Las estadísticas, los pools y las tablas de botín están en `src/core/combat.gd`.

## Maestría y persistencia

Se guardan intentos, aciertos, rachas y resultados por dificultad para cada tema. La selección favorece temas con menor precisión o pocos intentos. La maestría desbloquea dificultades avanzadas y se conserva tras morir. La run y el guardado se mantienen separados.

