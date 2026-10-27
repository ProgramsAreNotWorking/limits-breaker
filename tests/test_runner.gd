extends SceneTree
## Suite de verificación. Ejecutar:
##   godot --headless --path . --script res://tests/test_runner.gd

const MediaManifest = preload("res://src/core/asset_manifest.gd")

var failures := 0
var checks := 0
var g: Node


func _initialize() -> void:
	print("=== LIMITS BREAKER · TESTS ===")
	g = load("res://src/core/game.gd").new()
	root.add_child(g)

	test_balance()
	test_damage_rules()
	test_math_generation()
	test_angel_problems()
	test_determinism()
	test_mastery()
	test_inventory()
	test_equipment()
	test_healing_cap()
	test_run_reset()
	test_loot()
	test_world_expansion()
	test_selection_time()
	test_enemy_roster()

	print("--------------------------------")
	print("Checks: %d · Fallos: %d" % [checks, failures])
	if failures == 0:
		print("RESULTADO: OK")
	else:
		printerr("RESULTADO: FALLÓ")
	quit(1 if failures > 0 else 0)


func check(cond: bool, msg: String) -> void:
	checks += 1
	if not cond:
		failures += 1
		printerr("  FALLO: " + msg)


func test_balance() -> void:
	print("- balance de enemigos")
	var weak: Dictionary = Combat.enemy_by_id("skeleton")
	var medium: Dictionary = Combat.enemy_by_id("brigand")
	var mini: Dictionary = Combat.enemy_by_id("colossus")
	var boss: Dictionary = Combat.enemy_by_id("limitless")
	check(int(weak["hp"]) - Combat.BASELINE_DAMAGE[1] == 1,
		"el más débil sobrevive al Intermedio más fuerte con exactamente 1 HP")
	check(int(weak["hp"]) - Combat.BASELINE_DAMAGE[2] <= 0,
		"Avanzado puede eliminar a un enemigo débil")
	check(int(weak["hp"]) - Combat.BASELINE_DAMAGE[3] <= 0,
		"Superdifícil elimina a un enemigo débil")
	var medium_left := int(medium["hp"]) - Combat.BASELINE_DAMAGE[3]
	check(medium_left > 0 and medium_left <= 5,
		"Superdifícil deja a un enemigo medio casi derrotado pero vivo")
	check(int(mini["hp"]) - 3 * Combat.BASELINE_DAMAGE[3] > 0,
		"el miniboss sobrevive varios Superdifíciles")
	check(int(boss["hp"]) - 5 * Combat.BASELINE_DAMAGE[3] > 0,
		"el jefe sobrevive varios Superdifíciles")
	check(Combat.BASELINE_DAMAGE[0] < Combat.BASELINE_DAMAGE[1]
		and Combat.BASELINE_DAMAGE[1] < Combat.BASELINE_DAMAGE[2]
		and Combat.BASELINE_DAMAGE[2] < Combat.BASELINE_DAMAGE[3],
		"la escalera de daño es estrictamente creciente")


func test_damage_rules() -> void:
	print("- reglas de daño y castigo")
	check(Combat.self_damage(0) == 0, "Fácil no aplica daño propio")
	check(Combat.self_damage(1) == 0, "Intermedio no aplica daño propio")
	check(Combat.self_damage(2) == 2, "Avanzado aplica 10% redondeado (2)")
	check(Combat.self_damage(3) == 5, "Superdifícil aplica 20% redondeado (5)")
	check(Combat.apply_armor(10, 3) == 7, "la armadura reduce el daño")
	check(Combat.apply_armor(1, 9) == 1, "el daño nunca baja de 1")
	var no_gear := {"weapon": "", "armor": "", "relic": ""}
	check(Combat.player_attack(1, no_gear) == 14, "ataque Intermedio base = 14")
	check(Combat.player_attack(3, no_gear) == 27, "ataque Superdifícil base = 27")


func test_math_generation() -> void:
	print("- generación y corrección de problemas")
	var rng := RandomNumberGenerator.new()
	rng.seed = 20261027
	for topic in MathEngine.TOPICS:
		var ok_topic := true
		for diff in range(4):
			for i in range(120):
				var p: MathEngine.Problem = MathEngine.generate(topic, diff, rng)
				if p.statement == "" or p.expression == "" or p.steps.size() == 0:
					ok_topic = false
					printerr("    problema incompleto: %s/%d" % [topic, diff])
					break
				if p.answer_kind == "dne":
					if not MathEngine.grade(p, "no existe"):
						ok_topic = false
						break
				elif p.answer_kind == "choice":
					if p.choices.size() < 2 or not MathEngine.grade_choice(p, p.correct_choice):
						ok_topic = false
						break
				else:
					var ans := MathEngine.format_answer(p)
					if not MathEngine.grade(p, ans):
						ok_topic = false
						printerr("    respuesta no aceptada: %s/%d ans=%s" % [topic, diff, ans])
						break
					if MathEngine.grade(p, "987654"):
						ok_topic = false
						break
		check(ok_topic, "generación y grading consistentes en %s" % topic)
	check(MathEngine.parse_number("-1/2") == -0.5, "parseo de fracciones")
	check(MathEngine.parse_number("0,25") == 0.25, "parseo con coma decimal")
	check(MathEngine.is_dne("No existe"), "detección de DNE")


func test_angel_problems() -> void:
	print("- problemas del ángel")
	var rng := RandomNumberGenerator.new()
	rng.seed = 77
	var ok := true
	for i in range(200):
		var p: MathEngine.Problem = MathEngine.angel_problem(rng.randi_range(0, 3), rng)
		if p.choices.size() != 4:
			ok = false
			break
		var seen := {}
		for c in p.choices:
			if seen.has(c):
				ok = false
				break
			seen[c] = true
		if p.correct_choice < 0 or p.correct_choice >= 4:
			ok = false
			break
		if not MathEngine.grade_choice(p, p.correct_choice):
			ok = false
			break
	check(ok, "el ángel genera 4 opciones únicas con respuesta válida")
	var heal: int = g.angel_heal_for(0)
	check(heal == 20 and g.angel_heal_for(3) == 70, "curación por dificultad del ángel")


func test_determinism() -> void:
	print("- determinismo")
	var a := RandomNumberGenerator.new()
	a.seed = 4242
	var b := RandomNumberGenerator.new()
	b.seed = 4242
	var pa: MathEngine.Problem = MathEngine.generate("factorization", 2, a)
	var pb: MathEngine.Problem = MathEngine.generate("factorization", 2, b)
	check(pa.expression == pb.expression and pa.answer_value == pb.answer_value,
		"misma semilla produce el mismo problema")
	var c := RandomNumberGenerator.new()
	c.seed = 4243
	var pc: MathEngine.Problem = MathEngine.generate("factorization", 2, c)
	check(pc.expression != pa.expression or pc.answer_value != pa.answer_value,
		"semilla distinta produce variación")


func test_mastery() -> void:
	print("- progresión de maestría")
	g._reset_mastery()
	check(g.mastery_level("direct") == 0, "maestría inicial en 0")
	check(g.unlocked_difficulty("direct") >= 1, "Fácil e Intermedio disponibles al inicio")
	for i in range(3):
		g.record_answer("direct", 0, true)
	check(g.mastery_level("direct") >= 1, "3 aciertos fáciles suben el nivel")
	check(g.unlocked_difficulty("direct") >= 2, "Avanzado se desbloquea con competencia")
	for i in range(4):
		g.record_answer("direct", 1, true)
	check(g.unlocked_difficulty("direct") >= 3, "Superdifícil se desbloquea después")
	g._reset_mastery()
	g.record_answer("table", 0, false)
	check(g.accuracy("table") == 0.0, "un fallo deja precisión en 0")
	check(g.mastery_level("table") == 0, "fallar no desbloquea dificultad")


func test_inventory() -> void:
	print("- inventario de 4 objetos")
	g.start_run()
	check(g.add_item("healing_draught"), "agrega el primer objeto")
	check(g.add_item("rusted_blade"), "agrega el segundo")
	check(g.add_item("iron_cuirass"), "agrega el tercero")
	check(g.add_item("ember_charm"), "agrega el cuarto")
	check(g.inventory_full(), "el inventario queda lleno en 4")
	check(not g.add_item("void_sigil"), "el quinto objeto es rechazado")
	g.discard_item("ember_charm")
	check(not g.inventory_full(), "tirar un objeto libera espacio")
	check(g.add_item("void_sigil"), "se puede agregar tras liberar espacio")
	check(g.inventory().size() == 4, "nunca se superan los 4 objetos")


func test_equipment() -> void:
	print("- equipo y estadísticas")
	g.start_run()
	var base_hp: int = g.max_hp()
	g.add_item("iron_cuirass")
	g.equip_item("iron_cuirass")
	check(g.max_hp() == base_hp + 15, "la coraza suma 15 HP máximo")
	check(String(g.run["equipped"]["armor"]) == "iron_cuirass", "la coraza queda equipada")
	g.add_item("rusted_blade")
	var base_dmg: int = g.attack_damage(1)
	g.equip_item("rusted_blade")
	check(g.attack_damage(1) == base_dmg + 2, "la espada suma 2 de daño")
	g.add_item("oak_shield")
	var base_def: int = g.defense()
	g.equip_item("oak_shield")
	check(g.defense() == base_def + 2, "el escudo suma 2 de defensa")


func test_healing_cap() -> void:
	print("- curación con tope")
	g.start_run()
	g.run["hp"] = g.max_hp() - 5
	var healed: int = g.add_hp(70)
	check(healed == 5, "la curación se recorta al HP máximo")
	check(g.hp() == g.max_hp(), "el HP nunca supera el máximo")
	check(g.add_hp(-10) == 0, "no se puede curar en negativo")


func test_run_reset() -> void:
	print("- muerte y persistencia")
	g._reset_mastery()
	g.start_run()
	for i in range(5):
		g.record_answer("onesided", 0, true)
	var before := int(g.mastery["onesided"]["attempts"])
	g.run["hp"] = 0
	var summary: Dictionary = g.end_run()
	check(int(g.mastery["onesided"]["attempts"]) == before, "la muerte conserva la maestría")
	check(int(summary.get("problems", 0)) >= 5, "el resumen conserva los problemas de la run")
	g.start_run()
	check(int(g.run["hp"]) == g.max_hp(), "una nueva run restaura el HP")


func test_loot() -> void:
	print("- botín")
	var rng := RandomNumberGenerator.new()
	rng.seed = 5
	var found := 0
	var enemy: Dictionary = Combat.enemy_by_id("brigand")
	for i in range(500):
		if Combat.roll_loot(enemy, rng) != "":
			found += 1
	check(found > 50 and found < 250, "la probabilidad de botín ronda el 35%")
	for tier in Combat.LOOT_BY_TIER.keys():
		var pool: Array = Combat.LOOT_BY_TIER[tier]
		var valid := true
		for id in pool:
			if Combat.item(String(id)).is_empty():
				valid = false
		check(valid, "todo el loot de %s existe en la base de objetos" % tier)


func test_world_expansion() -> void:
	print("- mundos, enemigos y objetos")
	check(Combat.WORLDS.size() == 4, "la expedición tiene tres umbrales y un trono final")
	check(String(Combat.world_for_encounter(1)["id"]) == "crypt", "el primer encuentro abre la Cripta")
	check(String(Combat.world_for_encounter(4)["id"]) == "ash", "el cuarto encuentro entra en Ceniza")
	check(String(Combat.world_for_encounter(7)["id"]) == "bell", "el séptimo encuentro entra en la Campana")
	check(String(Combat.world_for_encounter(10)["id"]) == "throne", "el jefe final abre el Trono")
	check(Combat.ENEMIES.size() == 15, "el repertorio crece a quince enemigos")
	check(Combat.ITEMS.size() == 22, "la base de objetos crece a veintidós entradas")
	var world_assets_ok := true
	var pools_ok := true
	var world_loot_ok := true
	for world in Combat.WORLDS:
		var environment_path := MediaManifest.environment(String(world.get("environment", "")))
		if environment_path == "" or not FileAccess.file_exists(environment_path):
			world_assets_ok = false
		var pool: Array = world.get("pool", [])
		var elite_pool: Array = world.get("elite_pool", [])
		if pool.is_empty():
			pools_ok = false
		for enemy_id in pool + elite_pool:
			if Combat.enemy_by_id(String(enemy_id)).get("id", "") != enemy_id:
				pools_ok = false
		for item_id in Combat.WORLD_LOOT.get(String(world.get("id", "")), []):
			if Combat.item(String(item_id)).is_empty():
				world_loot_ok = false
	check(world_assets_ok, "cada mundo apunta a un fondo PNG existente")
	check(pools_ok, "los pools de enemigos sólo contienen enemigos válidos")
	check(world_loot_ok, "el botín temático de los mundos existe en la base de objetos")
	var new_enemies := ["oath_acolyte", "bone_pilgrim", "ash_brigand", "cinder_warden",
		"slag_priest", "hollow_choir", "bell_keeper", "mirror_scholar", "rift_sentinel"]
	var new_enemies_ok := true
	for enemy_id in new_enemies:
		var enemy := Combat.enemy_by_id(String(enemy_id))
		if String(enemy.get("id", "")) != enemy_id or String(enemy.get("tint", "")) == "":
			new_enemies_ok = false
	check(new_enemies_ok, "los nueve enemigos nuevos tienen datos y tinte estático")
	var new_items := ["oathbrand", "cinder_maul", "mirror_needle", "ash_mantle", "mirror_scale",
		"choir_plate", "bell_fragment", "rift_ember", "hollow_eye", "ash_salve", "fading_elixir"]
	var new_items_ok := true
	for item_id in new_items:
		var it := Combat.item(String(item_id))
		if it.is_empty() or String(it.get("desc", "")) == "" or Combat.item_tint(String(item_id)) == "":
			new_items_ok = false
	check(new_items_ok, "los once objetos nuevos tienen efecto, descripción y tinte")
	var rng := RandomNumberGenerator.new()
	rng.seed = 8151
	for encounter in [1, 2, 3, 4, 6, 7, 8, 9]:
		var selected_world := Combat.world_for_encounter(encounter)
		var allowed: Array = selected_world.get("pool", []) + selected_world.get("elite_pool", [])
		var valid := true
		for i in range(80):
			if not allowed.has(String(Combat.enemies_for_encounter(encounter, rng)["id"])):
				valid = false
				break
		check(valid, "el encuentro %d sólo elige enemigos de su mundo" % encounter)
	var seen_crypt := {}
	var seen_ash := {}
	var seen_bell := {}
	for i in range(300):
		seen_crypt[String(Combat.enemies_for_encounter(1, rng)["id"])] = true
		seen_ash[String(Combat.enemies_for_encounter(4, rng)["id"])] = true
		seen_bell[String(Combat.enemies_for_encounter(7, rng)["id"])] = true
	check(seen_crypt.has("oath_acolyte") and seen_crypt.has("bone_pilgrim"), "los enemigos nuevos de la Cripta aparecen")
	check(seen_ash.has("ash_brigand") and seen_ash.has("cinder_warden"), "los enemigos nuevos de Ceniza aparecen")
	check(seen_bell.has("hollow_choir") and seen_bell.has("rift_sentinel"), "los enemigos nuevos de la Campana aparecen")
	var seen_elite := {}
	for i in range(600):
		seen_elite[String(Combat.enemies_for_encounter(9, rng)["id"])] = true
	check(seen_elite.has("bell_keeper") and seen_elite.has("mirror_scholar"), "los élites del Santuario aparecen en el tercer tramo")
	var world_hits := 0
	for i in range(300):
		var loot := Combat.roll_loot(Combat.enemy_by_id("bone_pilgrim"), rng, 1.0, "crypt")
		if Combat.WORLD_LOOT["crypt"].has(loot):
			world_hits += 1
	check(world_hits > 80, "el botín temático aparece junto al botín por tier")


func test_selection_time() -> void:
	print("- reloj de selección por dificultad")
	check(not g.settings.has("select_time"), "los ajustes ya no exponen un reloj manual")
	var rng := RandomNumberGenerator.new()
	rng.seed = 991
	var order := ["weak", "ordinary", "strong", "elite", "miniboss", "boss"]
	var previous_min := INF
	var bands_ok := true
	var rolls_ok := true
	var varied := true
	for tier in order:
		var band: Array = Combat.SELECT_TIME_BY_TIER[tier]
		var low := float(band[0])
		var high := float(band[1])
		if low <= 0.0 or high <= low or high >= previous_min:
			bands_ok = false
		previous_min = low
		var enemy := {"tier": tier}
		var seen_low := INF
		var seen_high := -INF
		for i in range(240):
			var rolled := Combat.selection_time_for(enemy, rng)
			seen_low = minf(seen_low, rolled)
			seen_high = maxf(seen_high, rolled)
			if rolled < low or rolled > high:
				rolls_ok = false
		if seen_high - seen_low < 0.5:
			varied = false
	check(bands_ok, "cada tier ofrece una banda aleatoria más corta que la anterior")
	check(rolls_ok, "todas las tiradas caen dentro de la banda del enemigo")
	check(varied, "el reloj varía dentro de cada banda")
	check(Combat.selection_time_for({}, rng) >= 18.0, "un enemigo sin tier usa la banda débil")


func test_enemy_roster() -> void:
	print("- roster de enemigos")
	var tiers := {}
	for e in Combat.ENEMIES:
		tiers[e["tier"]] = true
		check(int(e["hp"]) > 0 and int(e["attack"]) > 0, "enemigo %s con stats válidos" % e["id"])
	for needed in ["weak", "ordinary", "strong", "elite", "miniboss", "boss"]:
		check(tiers.has(needed), "existe la categoría %s" % needed)
	var rng := RandomNumberGenerator.new()
	rng.seed = 9
	check(Combat.enemies_for_encounter(10, rng)["id"] == "limitless", "el encuentro 10 es jefe")
	check(Combat.enemies_for_encounter(5, rng)["id"] == "colossus", "el encuentro 5 es miniboss")
