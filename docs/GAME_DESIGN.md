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

Cada encuentro puede reunir hasta cuatro enemigos. El jugador selecciona uno como objetivo y luego elige una de seis técnicas: cuatro atacan y dos sostienen. Los ataques de área alcanzan primero al objetivo elegido y después a los enemigos vivos en orden de formación; el Barrido llega a dos y Nova astral a todos los vivos. Un enemigo derrotado permanece en escena durante el turno de su muerte y los dos turnos siguientes; desaparece al comenzar el tercer turno posterior, después de dos turnos completos. Al retirarse de la formación deja de ocupar una ranura y no cuenta para objetivos, intenciones ni el recuento de vivos. El Sello de guarda no elige objetivo y no hace daño: al acertar otorga un escudo que absorbe el daño enemigo de ese turno (12/18/26/34 según la dificultad, más 2 por punto de defensa). El escudo que sobrevive a los ataques enemigos dura hasta dos turnos adicionales y expira al inicio del tercero; si se consume por completo, no queda guardia. Aliento vital tampoco elige objetivo enemigo: cura una cantidad pequeña de HP y no daña. Cada enemigo vivo resuelve su intención en el turno, incluso si el jugador acertó: los que atacan lo hacen aunque el jugador acierte, y los que se defienden aplican guardia. Si un ataque derrota al último enemigo, no queda nadie para contraatacar. El daño de cada enemigo baja según el número de atacantes vivos para que un grupo no multiplique sin límite el daño recibido.

| Técnica | Tipo | Objetivos | Potencia | Penetración | Ajuste de dificultad | Efecto adicional |
|---|---|---:|---:|---:|---:|---|
| Tajo perforante | Físico | 1 | 1,00× | 2 de armadura | +1 | Sangrado 2 durante 3 turnos (sólo vivos) |
| Barrido | Físico | hasta 2 | 0,78× | 0 | 0 | 33 % de Mutilación por objetivo: pierde el siguiente turno |
| Lanza arcana | Mágico | 1 | 1,00× | 1 de resistencia mágica | +1 | Debilidad −25 % durante 2 turnos |
| Nova astral | Mágico | hasta 4 | 0,54× | 0 | −1 | Flujo de magia 3 durante 3 turnos |
| Sello de guarda | Defensa | 0 (propio) | — | — | 0 | 12 / 18 / 26 / 34 + 2 × defensa |
| Aliento vital | Curación | 0 (propio) | — | — | 0 | 7 / 10 / 13 / 16 HP |

El Tajo y la Lanza comparten la misma potencia y el mismo ajuste de dificultad: la diferencia sale del tipo de daño, de la penetración (2 de armadura frente a 1 de resistencia mágica), de las debilidades del enemigo y del arma equipada. El Tajo recibe el daño completo del arma; la Lanza recibe siempre la mitad del daño del arma y, en Avanzado y Superdifícil, también su hechizo. Por eso el Tajo gana contra un enemigo débil a lo físico y neutral a la magia, mientras la Lanza gana contra uno débil a lo mágico.

La Lanza arcana aplica **Debilidad**: reduce un 25 % el daño enemigo durante 2 turnos y empieza a contar en el turno siguiente. Nova astral aplica **Flujo de magia**: 3 de daño por turno durante 3 turnos. Tajo perforante aplica **Sangrado**: 2 de daño por turno durante 3 turnos sólo a enemigos vivos. Barrido tiene un 33 % de probabilidad por enemigo alcanzado de aplicar **Mutilación**, que consume el turno enemigo inmediato. Ningún estado se acumula: se refresca al volver a aplicarlo. Los no muertos, los constructos y las variantes mágicas son inmunes al Flujo; los no vivos no sangran. La clasificación completa está en [ENEMIGOS.md](ENEMIGOS.md#tipo-de-cuerpo-e-inmunidades).

Cada enemigo puede tener armadura, resistencia mágica, debilidades o una combinación de ellas. La carta de cada técnica enseña su daño estimado contra el objetivo seleccionado y señala si explota su debilidad o si el enemigo lo resiste. El Sello de guarda y Aliento vital no explotan debilidades ni resistencias: muestran su escudo o curación y no permiten elegir un objetivo enemigo.

La dificultad de la pregunta se sortea al confirmar el ataque. La banda base depende del nivel de la run: niveles 1–2 usan Fácil–Intermedio; 3–4, Fácil–Avanzado; 5–7, Intermedio–Superdifícil; y 8–10, Avanzado–Superdifícil. Cada técnica desplaza la banda según su perfil y la maestría del tema limita el máximo disponible. Resolver la pregunta no tiene cronómetro.

Al acertar con una técnica ofensiva, el jugador daña a sus objetivos y todos los enemigos que sobreviven contraatacan en el mismo turno. Al acertar con el Sello de guarda no hay daño: el jugador obtiene escudo para ese turno. Al acertar con Aliento vital no hay daño: el jugador recupera HP, pero los enemigos siguen actuando. Al fallar, los enemigos atacan; en Avanzado y Superdifícil, el retroceso propio se suma a esos golpes. El daño mínimo después de armadura es 1. La guardia enemiga se descuenta antes de aplicar el daño a la vida del enemigo. La Debilidad reduce el daño enemigo; el Flujo y el Sangrado restan HP directamente al inicio de la fase enemiga y no pasan por la guardia; la Mutilación evita el turno enemigo inmediato.

## Habilidades enemigas y estados

Todos los enemigos tienen un ataque básico y una defensa. Los fuertes y los élites añaden una tercera habilidad; algunos débiles y ordinarios también. El Coloso de Hueso (miniboss) y Limitless (jefe) tienen cuatro. La intención del enemigo se muestra en su figura y en su tooltip antes de elegir la técnica, con un prefijo que indica su tipo: **ATAQUE**, **DEFENSA**, **CURA**, **POTENCIA**, **MALDICIÓN** o **INVOCACIÓN**. Las variantes híbridas se anuncian como **ATAQUE · MARCA**, **ATAQUE · DRENAJE**, **ATAQUE · PERFORA** o **ATAQUE · MÚLTIPLE**; un enemigo recién invocado muestra **APARECE**.

El primer turno de cada encuentro siempre usa el ataque básico. Después, la IA elige con pesos: ataque 1,5; defensa 1,0; habilidad especial 0,9; invocación 0,75. Repetir la misma habilidad reduce su peso a 0,2 y no se puede defender dos veces seguidas. La defensa enemiga aplica su guardia al inicio del turno; el enemigo no ataca ese turno y la guardia persiste hasta consumirse con el siguiente golpe. Una guardia nueva no supera el máximo ya acumulado.

| Efecto | Regla |
|---|---|
| Guardia | Absorbe el daño del siguiente golpe recibido. No se acumula por encima del valor máximo activo. |
| Curación | Restaura HP al aliado vivo más herido (puede ser el propio lanzador). |
| Furia | Suma daño a los ataques del enemigo durante N turnos. |
| Maldición | Reduce un porcentaje del daño del jugador durante N turnos. |
| Marca | Aumenta el daño que recibe el jugador durante N turnos. |
| Debilidad | Reduce el daño enemigo un porcentaje durante N turnos. Lanza arcana: −25 % durante 2 turnos. |
| Flujo de magia | Resta HP al enemigo al inicio de la fase enemiga durante N turnos. Nova astral: 3 durante 3 turnos. No afecta a no vivos ni a variantes mágicas. |
| Sangrado | Resta HP al enemigo vivo al inicio de la fase enemiga durante N turnos. Tajo perforante: 2 durante 3 turnos. Los no vivos no sangran. |
| Mutilación | El enemigo pierde su turno inmediato siguiente. Barrido: 33 % de probabilidad por objetivo. |
| Drenaje | Cura al enemigo un porcentaje del daño que consigue infligir. |
| Múltiple | Golpea varias veces; cada golpe se calcula por separado. |
| Perforación | Ignora la defensa del jugador. |
| Invocación | Añade un enemigo al grupo si hay espacio; el invocado actúa desde el turno siguiente. |

El escudo del Sello de guarda se consume con los golpes enemigos. El remanente dura hasta dos turnos adicionales y expira al inicio del tercero; si se agota, desaparece. Una maldición o marca nueva empieza a contar en el turno siguiente: no afecta ni se descuenta en la ronda en que se aplica. La Debilidad sigue la misma regla. El Flujo y el Sangrado tampoco dañan en la ronda en que se aplican: su primer tick ocurre al inicio de la fase enemiga del turno siguiente. La Mutilación, en cambio, se consume en el turno enemigo inmediato. Al morir un enemigo se limpian todos sus estados. El daño base de las habilidades enemigas se calcula antes de la defensa del jugador, del +2 que suma el enemigo cuando el jugador está a 50% de HP o menos, de la furia, de la marca y del escalado por número de atacantes. Las tablas de [ENEMIGOS.md](ENEMIGOS.md) muestran ese daño base.

Berserk se carga durante siete turnos de combate y conserva la carga al pasar de encuentro. Al activarlo, un acierto multiplica por 1,5 el daño, el escudo o la curación; un fallo conserva el 0,4× y las penalizaciones normales del fallo. El turno en que se usa cuenta para la siguiente carga.

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

El repertorio tiene dieciocho enemigos repartidos en cuatro mundos: Cripta de los Juramentos (encuentros 1–3), Galerías de Ceniza (4–6), Santuario de la Campana Rota (7–9) y Trono de Limitless (10). Las apariciones normales salen del pool de cada mundo. El primer encuentro es individual; después los grupos crecen hasta cuatro enemigos (los jefes y el miniboss siguen individuales). El Coloso de Hueso ocupa el encuentro 5 y Limitless el 10. Desde el tercer encuentro de cada mundo (3, 6 y 9) puede aparecer un élite con 35% de probabilidad: el Cultista Carmesí en la Cripta, el Sacerdote de Escoria en Ceniza, y la Guardiana de la Campana o el Erudito del Espejo en el Santuario. Los enemigos se muestran como figuras seleccionables sobre el escenario; los no jefes llevan una barra de vida pequeña sobre el retrato y el jefe conserva una barra grande en el HUD.

Cada baja da XP según el rango del enemigo. La XP sube el nivel de la run hasta 10 y amplía gradualmente las bandas aleatorias de dificultad de los ataques. Este nivel y la carga Berserk son temporales y se reinician al comenzar otra run.

La fragua aparece cada cuatro encuentros a partir del cuarto y ofrece una mejora de arma, armadura o reliquia a cambio de resolver un reto. Desde el encuentro 3 puede aparecer un ángel con probabilidad del 6%, como máximo una vez por run; acertar cura según la dificultad y fallar cura 1 HP. Ambos eventos solo se abren entre combates, después de completar el encuentro; nunca durante una pelea activa.

Hay veintiséis objetos entre armas, armaduras, reliquias y consumibles. El botín combina la tabla del tier enemigo con una tabla temática del mundo. Los veintidós objetos anteriores reutilizan once iconos PNG; los cuatro añadidos tienen iconos propios. El inventario lleva hasta cuatro objetos; arma, armadura y reliquia tienen ranuras equipables. Las estadísticas, los pools y las tablas de botín están en `src/core/combat.gd`; el catálogo con sprites, rarezas y efectos está en [OBJETOS.md](OBJETOS.md).

## Maestría y persistencia

Se guardan intentos, aciertos, rachas y resultados por dificultad para cada tema. La selección favorece temas con menor precisión o pocos intentos. La maestría desbloquea dificultades avanzadas y se conserva tras morir. La run y el guardado se mantienen separados.

## Documentación relacionada

- [Personajes](PERSONAJES.md)
- [Enemigos](ENEMIGOS.md)
- [Objetos](OBJETOS.md)
- [Arquitectura técnica](TECHNICAL_ARCHITECTURE.md)

