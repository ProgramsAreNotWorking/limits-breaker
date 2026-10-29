extends Node
## Suite determinista de lógica, recursos y un ciclo real de interfaz.

const MathRules = preload("res://src/core/math_engine.gd")
const CombatRules = preload("res://src/core/combat.gd")
const MediaManifest = preload("res://src/core/asset_manifest.gd")
const MainSceneScript = preload("res://src/main.gd")
const CombatScreenScript = preload("res://src/ui/combat_screen.gd")
const BlacksmithScreenScript = preload("res://src/ui/blacksmith_screen.gd")
const AngelScreenScript = preload("res://src/ui/angel_screen.gd")
const DeathScreenScript = preload("res://src/ui/death_screen.gd")
const VictoryScreenScript = preload("res://src/ui/victory_screen.gd")
const ToonArt = preload("res://src/ui/toon_art.gd")

var checks := 0
var failures: Array[String] = []


func _ready() -> void:
	call_deferred("_run")


func _run() -> void:
	await get_tree().process_frame
	Audio.playback_enabled = false
	_test_math_generation()
	_test_combat_balance()
	_test_encounter_rules()
	_test_world_expansion()
	_test_selection_timer()
	_test_audio_and_visual_assets()
	_test_persistence_and_mastery()
	_test_inventory_and_equipment()
	_test_save_recovery()
	await _test_real_game_cycle()
	await _test_keyboard_submission()
	await _test_hard_failure_penalties()
	await _test_victory_milestone()
	await _test_special_encounters()
	await _test_combat_menu_and_abandon()
	if failures.is_empty():
		print("PASS: %d verificaciones." % checks)
	else:
		push_error("FAIL: %d de %d verificaciones." % [failures.size(), checks])
		for failure in failures:
			push_error("  - " + failure)
	Audio.shutdown()
	await get_tree().process_frame
	get_tree().quit(1 if not failures.is_empty() else 0)


func _check(condition: bool, label: String) -> void:
	checks += 1
	if not condition:
		failures.append(label)


func _test_math_generation() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 731942
	for topic in MathRules.TOPICS:
		for difficulty in range(4):
			for sample in range(20):
				var problem: MathRules.Problem = MathRules.generate(String(topic), difficulty, rng)
				var answer := MathRules.format_answer(problem)
				_check(problem.statement != "" and problem.expression != "", "enunciado %s/%d/%d" % [topic, difficulty, sample])
				_check(not problem.steps.is_empty(), "pasos %s/%d/%d" % [topic, difficulty, sample])
				_check(MathRules.grade(problem, answer), "respuesta generada %s/%d/%d: %s" % [topic, difficulty, sample, answer])
				_check(not MathRules.grade(problem, "999999"), "rechaza respuesta incorrecta %s/%d/%d" % [topic, difficulty, sample])
	var trig_rng := RandomNumberGenerator.new()
	trig_rng.seed = 109
	for difficulty in range(4):
		var trig := MathRules.generate("trig", difficulty, trig_rng)
		_check(MathRules.grade(trig, MathRules.format_answer(trig)), "respuesta trigonométrica")
	var angel_rng := RandomNumberGenerator.new()
	angel_rng.seed = 428
	for difficulty in range(4):
		var angel := MathRules.angel_problem(difficulty, angel_rng)
		_check(angel.answer_kind == "roots", "el ángel siempre pide raíces")
		_check(MathRules.grade(angel, MathRules.format_answer(angel)), "raíces del ángel")
	_check(is_equal_approx(MathRules.parse_number("1/2"), 0.5), "lectura de fracciones")
	_check(is_equal_approx(MathRules.parse_number("-3,25"), -3.25), "lectura decimal con coma")
	_check(MathRules.is_dne("no existe"), "respuesta de límite inexistente")


func _test_combat_balance() -> void:
	var skeleton := CombatRules.enemy_by_id("skeleton")
	var brigand := CombatRules.enemy_by_id("brigand")
	var colossus := CombatRules.enemy_by_id("colossus")
	var boss := CombatRules.enemy_by_id("limitless")
	_check(int(skeleton["hp"]) - CombatRules.BASELINE_DAMAGE[1] == 1, "el enemigo débil sobrevive al máximo intermedio con 1 HP")
	_check(int(skeleton["hp"]) <= CombatRules.BASELINE_DAMAGE[2], "el ataque avanzado elimina al enemigo débil")
	_check(int(brigand["hp"]) - CombatRules.BASELINE_DAMAGE[3] > 0, "el enemigo medio sobrevive al superdifícil")
	_check(int(brigand["hp"]) - CombatRules.BASELINE_DAMAGE[3] <= 3, "el superdifícil deja casi derrotado al enemigo medio")
	_check(int(colossus["hp"]) > CombatRules.BASELINE_DAMAGE[3] * 2, "el miniboss soporta varios superdifíciles")
	_check(int(boss["hp"]) > CombatRules.BASELINE_DAMAGE[3] * 2, "el jefe soporta varios superdifíciles")
	_check(CombatRules.self_damage(2) == 2, "retroceso avanzado: 10% con redondeo al entero más cercano")
	_check(CombatRules.self_damage(3) == 5, "retroceso superdifícil: 20% con redondeo al entero más cercano")
	_check(CombatRules.self_damage(0) == 0 and CombatRules.self_damage(1) == 0, "dificultades bajas no aplican retroceso")
	_check(CombatRules.apply_armor(1, 99) == 1, "daño mínimo después de armadura")
	var encounter_rng := RandomNumberGenerator.new()
	encounter_rng.seed = 15
	_check(CombatRules.enemies_for_encounter(10, encounter_rng)["id"] == "limitless", "jefe en encuentro 10")
	_check(CombatRules.enemies_for_encounter(5, encounter_rng)["id"] == "colossus", "miniboss en encuentro 5")
	var equipped := {"weapon": "ashen_edge", "armor": "oak_shield", "relic": "ember_charm"}
	_check(CombatRules.player_attack(1, equipped) == 20, "arma y reliquia modifican el ataque")
	_check(CombatRules.player_defense(equipped) == 2, "armadura modifica defensa")
	_check(CombatRules.max_hp_bonus({"weapon": "", "armor": "iron_cuirass", "relic": "pilgrim_relic"}) == 25, "equipo modifica HP máximo")


func _test_encounter_rules() -> void:
	_check(Game.is_blacksmith_encounter(4) and Game.is_blacksmith_encounter(8), "la fragua aparece cada cuatro encuentros configurados")
	_check(not Game.is_blacksmith_encounter(3) and not Game.is_blacksmith_encounter(5), "la fragua no aparece fuera del intervalo")
	Game.start_run()
	var rng := RandomNumberGenerator.new()
	rng.seed = 67291
	var appearances := 0
	for i in range(10000):
		Game.run["angel_used"] = false
		if Game.should_spawn_angel(3, rng):
			appearances += 1
	_check(appearances >= 450 and appearances <= 750, "probabilidad del ángel cercana al 6% con semilla fija")
	Game.run["angel_used"] = true
	_check(not Game.should_spawn_angel(20, rng), "el ángel aparece como máximo una vez por run")
	Game.run["angel_used"] = false
	_check(not Game.should_spawn_angel(2, rng), "el ángel no aparece antes del encuentro inicial configurado")


func _test_world_expansion() -> void:
	_check(CombatRules.WORLDS.size() == 4, "la expedición tiene tres umbrales y un trono final")
	_check(String(CombatRules.world_for_encounter(1)["id"]) == "crypt", "el primer encuentro abre la Cripta")
	_check(String(CombatRules.world_for_encounter(4)["id"]) == "ash", "el cuarto encuentro entra en Ceniza")
	_check(String(CombatRules.world_for_encounter(7)["id"]) == "bell", "el séptimo encuentro entra en la Campana")
	_check(String(CombatRules.world_for_encounter(10)["id"]) == "throne", "el jefe final abre el Trono")
	_check(CombatRules.ENEMIES.size() == 15, "el repertorio crece a quince enemigos")
	_check(CombatRules.ITEMS.size() == 22, "la base de objetos crece a veintidós entradas")
	var world_assets_ok := true
	var pools_ok := true
	var world_loot_ok := true
	for world in CombatRules.WORLDS:
		var environment_path := MediaManifest.environment(String(world.get("environment", "")))
		if environment_path == "" or not FileAccess.file_exists(environment_path):
			world_assets_ok = false
		var pool: Array = world.get("pool", [])
		var elite_pool: Array = world.get("elite_pool", [])
		if pool.is_empty():
			pools_ok = false
		for enemy_id in pool + elite_pool:
			if CombatRules.enemy_by_id(String(enemy_id)).get("id", "") != enemy_id:
				pools_ok = false
		for item_id in CombatRules.WORLD_LOOT.get(String(world.get("id", "")), []):
			if CombatRules.item(String(item_id)).is_empty():
				world_loot_ok = false
	_check(world_assets_ok, "cada mundo apunta a un fondo PNG existente")
	_check(pools_ok, "los pools de enemigos sólo contienen enemigos válidos")
	_check(world_loot_ok, "el botín temático de los mundos existe en la base de objetos")
	var new_enemies := ["oath_acolyte", "bone_pilgrim", "ash_brigand", "cinder_warden",
		"slag_priest", "hollow_choir", "bell_keeper", "mirror_scholar", "rift_sentinel"]
	var new_enemies_ok := true
	for enemy_id in new_enemies:
		var enemy := CombatRules.enemy_by_id(String(enemy_id))
		if String(enemy.get("id", "")) != enemy_id or String(enemy.get("tint", "")) == "":
			new_enemies_ok = false
	_check(new_enemies_ok, "los nueve enemigos nuevos tienen datos y tinte estático")
	var new_items := ["oathbrand", "cinder_maul", "mirror_needle", "ash_mantle", "mirror_scale",
		"choir_plate", "bell_fragment", "rift_ember", "hollow_eye", "ash_salve", "fading_elixir"]
	var new_items_ok := true
	for item_id in new_items:
		var it := CombatRules.item(String(item_id))
		if it.is_empty() or String(it.get("desc", "")) == "" or CombatRules.item_tint(String(item_id)) == "":
			new_items_ok = false
	_check(new_items_ok, "los once objetos nuevos tienen efecto, descripción y tinte")
	var rng := RandomNumberGenerator.new()
	rng.seed = 8151
	for encounter in [1, 2, 3, 4, 6, 7, 8, 9]:
		var selected_world := CombatRules.world_for_encounter(encounter)
		var allowed: Array = selected_world.get("pool", []) + selected_world.get("elite_pool", [])
		var valid := true
		for i in range(80):
			if not allowed.has(String(CombatRules.enemies_for_encounter(encounter, rng)["id"])):
				valid = false
				break
		_check(valid, "el encuentro %d sólo elige enemigos de su mundo" % encounter)
	var seen_crypt := {}
	var seen_ash := {}
	var seen_bell := {}
	for i in range(300):
		seen_crypt[String(CombatRules.enemies_for_encounter(1, rng)["id"])] = true
		seen_ash[String(CombatRules.enemies_for_encounter(4, rng)["id"])] = true
		seen_bell[String(CombatRules.enemies_for_encounter(7, rng)["id"])] = true
	_check(seen_crypt.has("oath_acolyte") and seen_crypt.has("bone_pilgrim"), "los enemigos nuevos de la Cripta aparecen")
	_check(seen_ash.has("ash_brigand") and seen_ash.has("cinder_warden"), "los enemigos nuevos de Ceniza aparecen")
	_check(seen_bell.has("hollow_choir") and seen_bell.has("rift_sentinel"), "los enemigos nuevos de la Campana aparecen")
	var seen_elite := {}
	for i in range(600):
		seen_elite[String(CombatRules.enemies_for_encounter(9, rng)["id"])] = true
	_check(seen_elite.has("bell_keeper") and seen_elite.has("mirror_scholar"), "los élites del Santuario aparecen en el tercer tramo")
	var world_hits := 0
	for i in range(300):
		var loot := CombatRules.roll_loot(CombatRules.enemy_by_id("bone_pilgrim"), rng, 1.0, "crypt")
		if CombatRules.WORLD_LOOT["crypt"].has(loot):
			world_hits += 1
	_check(world_hits > 80, "el botín temático aparece junto al botín por tier")


func _test_selection_timer() -> void:
	_check(not Game.settings.has("select_time"), "el reloj de selección dejó de ser un ajuste manual")
	var rng := RandomNumberGenerator.new()
	rng.seed = 991
	var order := ["weak", "ordinary", "strong", "elite", "miniboss", "boss"]
	var previous_min := INF
	var bands_ok := true
	var rolls_ok := true
	var varied := true
	for tier in order:
		var band: Array = CombatRules.SELECT_TIME_BY_TIER[tier]
		var low := float(band[0])
		var high := float(band[1])
		if low <= 0.0 or high <= low or high >= previous_min:
			bands_ok = false
		previous_min = low
		var enemy := {"tier": tier}
		var seen_low := INF
		var seen_high := -INF
		for i in range(240):
			var rolled := CombatRules.selection_time_for(enemy, rng)
			seen_low = minf(seen_low, rolled)
			seen_high = maxf(seen_high, rolled)
			if rolled < low or rolled > high:
				rolls_ok = false
		if seen_high - seen_low < 0.5:
			varied = false
	_check(bands_ok, "el tiempo de selección baja con cada tier de enemigo")
	_check(rolls_ok, "las tiradas del reloj respetan la banda del enemigo")
	_check(varied, "el reloj de selección cambia aleatoriamente dentro de la banda")
	_check(CombatRules.selection_time_for({}, rng) >= 18.0, "un enemigo sin tier usa la banda débil")


func _test_audio_and_visual_assets() -> void:
	for id in MediaManifest.MUSIC_FILES:
		var path := String(MediaManifest.MUSIC_FILES[id])
		_check(FileAccess.file_exists(path), "archivo musical " + String(id))
		var track := Audio._music_stream(String(id)) as AudioStreamWAV
		_check(track != null and track.get_length() >= 60.0, "tema WAV de al menos un minuto " + String(id))
		if track != null:
			_check(track.loop_mode == AudioStreamWAV.LOOP_FORWARD, "loop sin fin " + String(id))
			var expected_end := int(round(track.get_length() * float(track.mix_rate)))
			_check(track.loop_end == expected_end, "loop abarca el WAV completo " + String(id))
	for id in MediaManifest.SFX_FILES:
		var path := String(MediaManifest.SFX_FILES[id])
		_check(FileAccess.file_exists(path), "archivo de efecto " + String(id))
		var effect := load(path) as AudioStreamWAV
		_check(effect != null and effect.get_length() > 0.0, "efecto WAV cargable " + String(id))
		if effect != null:
			_check(effect.loop_mode == AudioStreamWAV.LOOP_DISABLED, "efecto no se repite " + String(id))
	var weapon_icon := MediaManifest.item_icon("ashen_edge")
	_check(FileAccess.file_exists(weapon_icon), "imagen preexistente del hacha conservada")
	_check(load(weapon_icon) is Texture2D, "imagen de referencia cargable por Godot")
	_check(MediaManifest.environment("forge") == "res://assets/art/environments/forge.png", "ruta estable para fondo de fragua")
	for environment_id in MediaManifest.ENVIRONMENTS.keys():
		var environment_path := MediaManifest.environment(String(environment_id))
		_check(FileAccess.file_exists(environment_path), "fondo raster " + String(environment_id))
		_check(load(environment_path) is Texture2D, "fondo cargable " + String(environment_id))
	for portrait_id in ["player", "blacksmith", "angel"]:
		_check(MediaManifest.character(String(portrait_id)) == String(portrait_id), "identificador vectorial de personaje " + String(portrait_id))
	for enemy_id in ["skeleton", "brigand", "warden", "cultist", "colossus", "limitless"]:
		_check(MediaManifest.enemy(String(enemy_id)) == String(enemy_id), "identificador vectorial de enemigo " + String(enemy_id))
	for enemy_data in CombatRules.ENEMIES:
		var enemy_id := String(enemy_data.get("id", ""))
		var enemy_art := MediaManifest.enemy(enemy_id)
		_check(enemy_art != "", "identificador visual para enemigo " + enemy_id)
		_check(MediaManifest.character_art(enemy_art) != "", "maestro PNG asignado a enemigo " + enemy_id)
	for character_id in MediaManifest.CHARACTER_ART.keys():
		var portrait_path := MediaManifest.character_art(String(character_id))
		_check(FileAccess.file_exists(portrait_path), "retrato raster " + String(character_id))
		_check(load(portrait_path) is Texture2D, "retrato cargable " + String(character_id))
	for item_id in CombatRules.ITEMS.keys():
		var item_path := MediaManifest.item_art(String(item_id))
		_check(MediaManifest.has_item_art(String(item_id)), "icono registrado de equipo " + String(item_id))
		_check(FileAccess.file_exists(item_path), "icono raster de equipo " + String(item_id))
		_check(load(item_path) is Texture2D, "icono cargable de equipo " + String(item_id))
	for effect_id in MediaManifest.EFFECT_ART.keys():
		var effect_path := MediaManifest.effect_art(String(effect_id))
		_check(FileAccess.file_exists(effect_path), "efecto raster " + String(effect_id))
		_check(load(effect_path) is Texture2D, "efecto cargable " + String(effect_id))
	_check(ResourceLoader.exists("res://src/ui/cartoon_art.gdshader"), "shader de tratamiento ilustrado disponible")
	var toon_material := ToonArt.material()
	_check(toon_material != null and toon_material.shader != null, "material ilustrado configurable")
	_check(ToonArt.ENABLED, "tratamiento ilustrado activo")


func _test_persistence_and_mastery() -> void:
	Game._reset_mastery()
	Game.start_run()
	for i in range(4):
		Game.record_answer("direct", 1, true)
	_check(Game.mastery_level("direct") == 0, "intermedio no salta la base fácil")
	_check(Game.unlocked_difficulty("direct") == 1, "avanzado permanece cerrado sin base")
	for i in range(3):
		Game.record_answer("direct", 0, true)
	_check(Game.mastery_level("direct") == 2, "la práctica demostrada desbloquea escalones hasta intermedio")
	_check(Game.unlocked_difficulty("direct") == 3, "superdifícil se habilita tras dominar intermedio")
	for i in range(4):
		Game.record_answer("direct", 2, true)
	_check(Game.mastery_level("direct") == 3, "maestría avanzada registrada")
	var before := int(Game.topic_stats("direct")["attempts"])
	Game.damage_player(1000)
	var summary: Dictionary = Game.end_run()
	_check(not bool(Game.run["active"]) and Game.hp() == 0, "muerte finaliza la run")
	_check(int(summary["furthest"]) == int(Game.run["encounter"]), "resumen guarda el encuentro más lejano")
	Game.start_run()
	_check(Game.hp() == Game.BASE_MAX_HP and int(Game.run["encounter"]) == 1, "nueva run restaura estado temporal")
	_check(Game.inventory().is_empty() and int(Game.run["upgrade_damage"]) == 0, "nueva run elimina botín y mejoras")
	_check(int(Game.topic_stats("direct")["attempts"]) == before, "aprendizaje persiste entre runs")


func _test_inventory_and_equipment() -> void:
	Game.start_run()
	for id in ["rusted_blade", "healing_draught", "iron_cuirass", "oak_shield"]:
		_check(Game.add_item(String(id)), "añadir " + String(id))
	_check(Game.inventory_full() and Game.inventory().size() == 4, "capacidad exacta de cuatro")
	_check(not Game.add_item("ember_charm"), "quinto objeto se rechaza")
	_check(Game.equip_item("rusted_blade") == "", "equipa arma desde inventario")
	_check(Game.attack_damage(0) == 10, "arma equipada aumenta daño")
	_check(Game.inventory().size() == 3, "equipo se separa del inventario")
	_check(Game.unequip("weapon"), "puede devolver equipo con espacio libre")
	_check(Game.inventory_full() and Game.inventory().size() == 4, "desequipar respeta el límite")
	Game.damage_player(80)
	_check(Game.use_consumable("healing_draught"), "poción consumible se usa")
	_check(Game.hp() == 50 and not Game.inventory().has("healing_draught"), "poción cura y desaparece")
	Game.apply_upgrade("temper")
	_check(Game.attack_damage(0) == 10, "mejora del herrero suma daño")
	Game.apply_upgrade("enchant")
	_check(Game.defense() == 2, "encantamiento suma defensa")
	var max_before := Game.max_hp()
	Game.apply_upgrade("reinforce")
	_check(Game.max_hp() == max_before + 12, "refuerzo aumenta HP máximo")
	_check(Game.hp() == 62, "refuerzo también cura doce HP")


func _test_save_recovery() -> void:
	var path := Game.SAVE_PATH
	var file := FileAccess.open(path, FileAccess.WRITE)
	_check(file != null, "el save temporal puede escribirse")
	if file == null:
		return
	file.store_string("{ JSON inválido")
	file.close()
	Game._reset_mastery()
	Game.load_game()
	_check(Game.mastery_level("direct") == 0, "save JSON corrupto conserva valores por defecto")
	file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(JSON.stringify({
		"mastery": {"direct": {"attempts": 1, "correct": 99, "by_diff": [1], "correct_by_diff": [8, 2], "streak": 80}},
		"settings": {"music": -4, "sfx": "mal", "select_time": 999, "reduced_motion": "sí"},
	}))
	file.close()
	Game._reset_mastery()
	Game.load_game()
	var recovered: Dictionary = Game.topic_stats("direct")
	_check(recovered["by_diff"].size() == 4 and recovered["correct_by_diff"].size() == 4, "arrays de maestría se reparan")
	_check(int(recovered["correct"]) <= int(recovered["attempts"]), "maestría reparada mantiene conteos válidos")
	_check(float(Game.settings["music"]) == 0.0 and not Game.settings.has("select_time"), "ajustes corruptos se limitan y el reloj legado se ignora")
	_check(is_equal_approx(float(Game.settings["sfx"]), 0.85) and not bool(Game.settings["reduced_motion"]), "ajustes inválidos usan defaults")
	Game._reset_mastery()
	Game.save_game()


func _test_real_game_cycle() -> void:
	Game._reset_mastery()
	Game.start_run()
	Game.run["angel_used"] = true # evita que el evento raro vuelva aleatorio este recorrido de integración
	var app: Variant = MainSceneScript.new()
	get_tree().root.add_child(app)
	await get_tree().process_frame
	_check(_click(app, "Nueva run"), "menú ofrece iniciar run")
	await get_tree().process_frame
	_check(_is_script(app.current, CombatScreenScript), "el menú abre el combate")
	var first_fight: Variant = app.current
	if _is_script(first_fight, CombatScreenScript):
		var band: Array = CombatRules.SELECT_TIME_BY_TIER.get(
			String(first_fight.enemy.get("tier", "weak")),
			CombatRules.SELECT_TIME_BY_TIER["weak"]
		)
		_check(first_fight.time_limit >= float(band[0]) and first_fight.time_limit <= float(band[1]),
			"el reloj del combate respeta la banda del enemigo")
		_check(is_equal_approx(first_fight.timer_bar.max_value, first_fight.time_limit),
			"la barra del reloj usa el límite sorteado")
	for encounter in range(3):
		var fight: Variant = app.current
		_check(_is_script(fight, CombatScreenScript), "combate del encuentro %d está activo" % (encounter + 1))
		if not _is_script(fight, CombatScreenScript):
			break
		_check(_win_current_fight(fight), "se puede vencer el encuentro %d" % (encounter + 1))
		await get_tree().process_frame
		var hud_stats := fight.find_child("Stats", true, false) as Label
		var expected_stats := "%d derrotados  ·  %d/%d aciertos" % [
			int(Game.run["stats"].get("enemies", 0)),
			int(Game.run["stats"].get("solved", 0)),
			int(Game.run["stats"].get("problems", 0)),
		]
		_check(hud_stats != null and hud_stats.text == expected_stats, "el contador de progreso se actualiza")
		var hud_encounter := fight.find_child("Encounter", true, false) as Label
		_check(hud_encounter != null and hud_encounter.text == "Encuentro %d" % int(Game.run.get("encounter", 1)), "el contador de encuentro avanza")
		_check(_click(fight, "Continuar"), "la victoria permite continuar")
		await get_tree().process_frame
		if encounter < 2:
			_check(_is_script(app.current, CombatScreenScript), "la run avanza al combate siguiente, no vuelve al menú")
	_check(_is_script(app.current, BlacksmithScreenScript), "aparece la fragua al alcanzar el intervalo")
	if _is_script(app.current, BlacksmithScreenScript):
		var smith: Variant = app.current
		smith.selected_upgrade = "temper"
		smith._answer(MathRules.format_answer(smith.problem))
		_check(Game.attack_damage(0) == 10, "resolver la trigonometría aplica la mejora")
		_check(_click(smith, "Volver al camino"), "la fragua devuelve al combate")
		await get_tree().process_frame
		_check(_is_script(app.current, CombatScreenScript), "la run continúa tras la fragua")
	var last_fight: Variant = app.current
	if _is_script(last_fight, CombatScreenScript):
		var final_topic := String(last_fight.topic)
		Game.run["hp"] = 1
		last_fight._choose(0)
		last_fight._submit("respuesta incorrecta")
		_check(last_fight.enemy_portrait.effect_id == "slash", "el enemigo muestra el ataque al golpear")
		_check(last_fight.player_portrait.effect_id == "impact", "el golpe enemigo se muestra en el jugador")
		_check(Game.hp() == 0, "un fallo puede causar muerte en combate")
		last_fight._after_feedback()
		await get_tree().process_frame
		_check(_is_script(app.current, DeathScreenScript), "la muerte abre el resumen de run")
		_check(not bool(Game.run["active"]), "la pantalla de muerte cierra el estado de run")
		var learned := int(Game.topic_stats(final_topic)["attempts"])
		_check(_click(app, "Nueva run"), "la muerte permite comenzar de nuevo")
		await get_tree().process_frame
		_check(_is_script(app.current, CombatScreenScript), "nueva run entra al primer combate")
		_check(Game.hp() == Game.BASE_MAX_HP and Game.inventory().is_empty(), "la nueva run reinicia salud y botín")
		_check(int(Game.topic_stats(final_topic)["attempts"]) == learned, "la nueva run conserva aprendizaje")
	app.queue_free()
	await get_tree().process_frame


func _test_keyboard_submission() -> void:
	Game._reset_mastery()
	Game.start_run()
	var app: Variant = MainSceneScript.new()
	get_tree().root.add_child(app)
	await get_tree().process_frame
	_click(app, "Nueva run")
	await get_tree().process_frame
	var fight: Variant = app.current
	if not _is_script(fight, CombatScreenScript):
		_check(false, "combate activo para probar el teclado físico")
		app.queue_free()
		await get_tree().process_frame
		return
	fight._choose(0)
	await get_tree().process_frame
	_check(fight.input.has_focus(), "el campo de respuesta recibe el foco")
	var answer := MathRules.format_answer(fight.chosen)
	_type_text(answer)
	await get_tree().process_frame
	_check(fight.input.text == answer, "el teclado físico escribe la respuesta")
	_press_key(KEY_ENTER)
	await get_tree().process_frame
	_check(fight.phase == "feedback", "Enter envía la respuesta")
	_check(int(fight.enemy_hp) < int(fight.enemy_max_hp), "la respuesta por teclado hace daño")
	var counter_damage := Game.enemy_damage(fight.enemy)
	_check(Game.hp() == Game.max_hp() - counter_damage, "un acierto por teclado solo recibe el contraataque enemigo")
	app.queue_free()
	await get_tree().process_frame


func _test_hard_failure_penalties() -> void:
	Game._reset_mastery()
	Game.start_run()
	var app: Variant = MainSceneScript.new()
	get_tree().root.add_child(app)
	await get_tree().process_frame
	_check(_click(app, "Nueva run"), "la penalización dura comienza desde una run real")
	await get_tree().process_frame
	var fight: Variant = app.current
	if not _is_script(fight, CombatScreenScript):
		_check(false, "combate activo para probar las penalizaciones duras")
		app.queue_free()
		await get_tree().process_frame
		return
	for difficulty in [2, 3]:
		Game.run["hp"] = Game.max_hp()
		var before := Game.hp()
		var enemy_dmg := Game.enemy_damage(fight.enemy)
		var self_dmg := Game.failing_self_damage(difficulty)
		fight.phase = "solve"
		fight.chosen_diff = difficulty
		fight.chosen = fight.problems[difficulty]
		fight._resolve(false)
		_check(self_dmg > 0, "la dificultad %d aplica retroceso" % difficulty)
		_check(Game.hp() == before - enemy_dmg - self_dmg,
			"fallar en %s aplica retroceso y golpe enemigo" % MathRules.DIFF_NAMES[difficulty])
		_check(fight.last_message.contains("retroceso arcano") and fight.last_message.contains("golpea por"),
			"el feedback de %s muestra ambos daños" % MathRules.DIFF_NAMES[difficulty])
		_check(fight.enemy_portrait.effect_id == "slash",
			"el enemigo ataca al fallar en %s" % MathRules.DIFF_NAMES[difficulty])
		_check(fight.player_portrait.effect_id == "impact",
			"el jugador recibe el impacto en %s" % MathRules.DIFF_NAMES[difficulty])
	app.queue_free()
	await get_tree().process_frame


func _test_victory_milestone() -> void:
	Game.start_run()
	var app: Variant = MainSceneScript.new()
	get_tree().root.add_child(app)
	await get_tree().process_frame
	_check(_click(app, "Nueva run"), "el hito comienza desde una run real")
	await get_tree().process_frame
	var fight: Variant = app.current
	if not _is_script(fight, CombatScreenScript):
		_check(false, "combate activo para probar el hito")
		app.queue_free()
		await get_tree().process_frame
		return
	Game.run["encounter"] = 10
	fight.enemy = CombatRules.enemy_by_id("limitless")
	fight.enemy_max_hp = int(fight.enemy["hp"])
	fight.enemy_hp = 1
	fight._choose(0)
	fight._submit(MathRules.format_answer(fight.chosen))
	fight._after_feedback()
	_check(fight.milestone_victory, "el jefe final activa el hito de victoria")
	await get_tree().process_frame
	_check(_click(fight, "Continuar"), "la victoria del jefe permite cerrar el combate")
	await get_tree().process_frame
	_check(_is_script(app.current, VictoryScreenScript), "derrotar al jefe abre la pantalla final")
	_check(not bool(Game.run["active"]), "el hito cierra la run temporal")
	_check(String(Game.run["stats"].get("result", "")) == "victory", "la run guarda el resultado de victoria")
	_check(int(Game.run["stats"].get("furthest", 0)) == 10, "la victoria registra el encuentro del jefe")
	_check(_click(app, "Nueva expedición"), "la pantalla de victoria permite reiniciar")
	await get_tree().process_frame
	_check(_is_script(app.current, CombatScreenScript), "la nueva expedición vuelve al combate")
	_check(int(Game.run["encounter"]) == 1, "la nueva expedición reinicia el contador")
	app.queue_free()
	await get_tree().process_frame


func _test_special_encounters() -> void:
	Game.start_run()
	var damage_before := Game.attack_damage(0)
	var smith: Variant = BlacksmithScreenScript.new()
	get_tree().root.add_child(smith)
	await get_tree().process_frame
	smith.selected_upgrade = "temper"
	smith._answer("respuesta incorrecta")
	_check(Game.attack_damage(0) == damage_before, "respuesta errónea del herrero no aplica mejora")
	smith.queue_free()
	await get_tree().process_frame
	Game.run["hp"] = 10
	var angel_wrong: Variant = AngelScreenScript.new()
	get_tree().root.add_child(angel_wrong)
	await get_tree().process_frame
	angel_wrong._answer("no son raíces")
	_check(Game.hp() == 11, "respuesta errónea del ángel cura exactamente un HP")
	angel_wrong.queue_free()
	await get_tree().process_frame
	Game.run["hp"] = 10
	var angel_right: Variant = AngelScreenScript.new()
	get_tree().root.add_child(angel_right)
	await get_tree().process_frame
	var expected_heal := mini(Game.max_hp(), 10 + Game.angel_heal_for(angel_right.problem.difficulty))
	angel_right._answer(MathRules.format_answer(angel_right.problem))
	_check(Game.hp() == expected_heal, "respuesta correcta del ángel cura según su dificultad y HP máximo")
	angel_right.queue_free()
	await get_tree().process_frame


func _test_combat_menu_and_abandon() -> void:
	Game._reset_mastery()
	Game.start_run()
	var app: Variant = MainSceneScript.new()
	get_tree().root.add_child(app)
	await get_tree().process_frame
	_check(_click(app, "Nueva run"), "el menú de combate parte de una run real")
	await get_tree().process_frame
	var fight: Variant = app.current
	if not _is_script(fight, CombatScreenScript):
		_check(false, "combate activo para probar el menú del juego")
		app.queue_free()
		await get_tree().process_frame
		return
	_check(_find_button(fight, "Menú") != null, "la barra superior ofrece acceso al menú del juego")
	fight._show_system_menu()
	await get_tree().process_frame
	_check(fight.overlay != null, "el menú del juego se abre sobre el combate")
	_check(_find_button(fight, "Reanudar combate") != null, "el menú permite reanudar")
	_check(_find_button(fight, "Terminar run") != null, "el menú permite terminar la run")
	var frozen := float(fight.time_left)
	fight._process(5.0)
	_check(is_equal_approx(fight.time_left, frozen), "el temporizador se pausa mientras el menú está abierto")
	fight._show_end_run_confirm()
	await get_tree().process_frame
	_check(_find_button(fight, "Cancelar") != null, "la confirmación permite cancelar")
	_check(_find_button(fight, "Terminar run") != null, "la confirmación permite terminar la run")
	fight._end_run_now()
	await get_tree().process_frame
	_check(not bool(Game.run["active"]), "terminar la run cierra la expedición")
	_check(String(Game.run["stats"].get("result", "")) == "abandon", "la run abandonada registra su resultado")
	_check(not _is_script(app.current, CombatScreenScript), "terminar la run vuelve al menú principal")
	_check(_find_button(app.current, "Nueva run") != null, "el menú principal queda operativo tras abandonar")
	app.queue_free()
	await get_tree().process_frame


func _win_current_fight(fight: Variant) -> bool:
	var turns := 0
	while turns < 12 and int(fight.enemy_hp) > 0:
		if fight.phase != "select":
			return false
		fight._choose(0)
		if fight.phase != "solve":
			return false
		fight._submit(MathRules.format_answer(fight.chosen))
		fight._after_feedback()
		turns += 1
	return fight.phase == "victory"


func _type_text(text: String) -> void:
	for ch in text:
		var down := InputEventKey.new()
		down.pressed = true
		down.unicode = ch.unicode_at(0)
		get_viewport().push_input(down)
		var up := InputEventKey.new()
		up.pressed = false
		up.unicode = ch.unicode_at(0)
		get_viewport().push_input(up)


func _press_key(keycode: Key) -> void:
	var down := InputEventKey.new()
	down.pressed = true
	down.keycode = keycode
	down.physical_keycode = keycode
	get_viewport().push_input(down)
	var up := InputEventKey.new()
	up.pressed = false
	up.keycode = keycode
	up.physical_keycode = keycode
	get_viewport().push_input(up)


func _click(root: Node, label: String) -> bool:
	var button := _find_button(root, label)
	if button == null:
		_check(false, "botón disponible: " + label)
		return false
	button.pressed.emit()
	return true


func _find_button(node: Node, label: String) -> Button:
	if node is Button and (node as Button).text == label:
		return node as Button
	for child in node.get_children():
		var found := _find_button(child, label)
		if found != null:
			return found
	return null


func _is_script(object: Variant, expected: Script) -> bool:
	return object != null and object.get_script() == expected
