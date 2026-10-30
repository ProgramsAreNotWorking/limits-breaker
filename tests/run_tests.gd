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
	await _test_enemy_kits_and_ward()
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


func _clear_fight_statuses(fight: Variant) -> void:
	for i in range(fight.enemies.size()):
		fight.enemy_fragile_bonus[i] = 0
		fight.enemy_fragile_turns[i] = 0
		fight.enemy_weak_pct[i] = 0
		fight.enemy_weak_turns[i] = 0
		fight.enemy_weak_applied_turn[i] = -1
		fight.enemy_flux_damage[i] = 0
		fight.enemy_flux_turns[i] = 0
		fight.enemy_flux_applied_turn[i] = -1
		fight.enemy_bleed_damage[i] = 0
		fight.enemy_bleed_turns[i] = 0
		fight.enemy_bleed_applied_turn[i] = -1
		fight.enemy_stun_turns[i] = 0
		fight.enemy_guards[i] = 0
		fight.enemy_bonus_damage[i] = 0
		fight.enemy_bonus_turns[i] = 0
		fight.enemy_intents[i] = {"name": "Prueba defensiva", "kind": "defend", "value": 0, "text": "Sin ataque."}
	fight.player_weaken_pct = 0
	fight.player_weaken_turns = 0
	fight.player_vulnerable_bonus = 0
	fight.player_vulnerable_turns = 0
	fight.player_shield = 0
	Game.run["hp"] = Game.max_hp()


func _set_test_enemy(fight: Variant, index: int, enemy_id: String, hp: int) -> void:
	if index < 0 or index >= fight.enemies.size():
		return
	fight.enemies[index] = CombatRules.enemy_by_id(enemy_id).duplicate(true)
	fight.enemy_max_hps[index] = maxi(1, hp)
	fight.enemy_hps[index] = maxi(1, hp)


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
	var staff := {"weapon": "arcane_staff"}
	_check(CombatRules.player_attack(0, staff, "arcane_lance") == CombatRules.player_attack(0, {}, "arcane_lance"), "el hechizo no bonifica la Lanza en Fácil")
	_check(CombatRules.player_attack(2, staff, "arcane_lance") == CombatRules.player_attack(2, {}, "arcane_lance") + 4, "el hechizo bonifica la Lanza en Avanzado")
	_check(CombatRules.player_attack(0, staff, "piercing_strike") == CombatRules.player_attack(0, {}, "piercing_strike") + 1, "el daño del báculo sí bonifica las técnicas físicas")
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
	_check(CombatRules.ENEMIES.size() == 18, "el repertorio crece a dieciocho enemigos")
	_check(CombatRules.ITEMS.size() == 26, "la base de objetos crece a veintiséis entradas")
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


func _test_enemy_kits_and_ward() -> void:
	var valid_kinds := ["attack", "defend", "heal", "buff", "debuff", "summon"]
	var counts_ok := true
	var kinds_ok := true
	var basic_ok := true
	for data in CombatRules.ENEMIES:
		var abilities: Array = data.get("abilities", [])
		var tier := String(data.get("tier", "weak"))
		var maximum := 4 if tier in ["miniboss", "boss"] else 3
		if abilities.size() < 2 or abilities.size() > maximum:
			counts_ok = false
		if tier in ["miniboss", "boss"] and abilities.size() != 4:
			counts_ok = false
		var has_basic := false
		for ability in abilities:
			if not valid_kinds.has(String(ability.get("kind", ""))):
				kinds_ok = false
			if String(ability.get("kind", "")) == "attack" and String(ability.get("effect", "")) == "":
				has_basic = true
		if not has_basic:
			basic_ok = false
		var basic := CombatRules.enemy_basic_attack(data)
		if int(basic.get("damage", 0)) != int(data.get("attack", 0)):
			basic_ok = false
	_check(counts_ok, "cada enemigo tiene 2-3 habilidades y los jefes cuatro")
	_check(kinds_ok, "las habilidades enemigas usan tipos válidos")
	_check(basic_ok, "cada enemigo conserva un ataque básico con su daño original")
	_check(CombatRules.ATTACK_IDS.size() == 6 and CombatRules.ATTACK_IDS[4] == "ward_sigil" and CombatRules.ATTACK_IDS[5] == "vital_breath", "el repertorio incluye sello y aliento vital")
	_check(CombatRules.is_defense_attack("ward_sigil") and not CombatRules.is_defense_attack("piercing_strike"), "el sello se identifica como defensa")
	_check(CombatRules.is_healing_attack("vital_breath") and not CombatRules.is_healing_attack("ward_sigil"), "el aliento se identifica como curación")
	_check(CombatRules.player_shield(0, 0) == 12 and CombatRules.player_shield(3, 0) == 34, "el escudo escala con la dificultad")
	_check(CombatRules.player_shield(1, 2) == 22, "la defensa del jugador suma al escudo")
	_check(CombatRules.player_heal(0) == 7 and CombatRules.player_heal(3) == 16, "la curación escala con la dificultad")
	_check(CombatRules.damage_for_attack(99, "ward_sigil", CombatRules.enemy_by_id("skeleton")) == 0, "el sello no hace daño")
	_check(CombatRules.damage_for_attack(99, "vital_breath", CombatRules.enemy_by_id("skeleton")) == 0, "el aliento no hace daño")
	_check(CombatRules.attack_effectiveness_label("ward_sigil", CombatRules.enemy_by_id("skeleton")) == "Protección para este turno", "la carta defensiva no muestra debilidad ofensiva")
	var parity_ok := true
	for difficulty in range(4):
		if CombatRules.player_attack(difficulty, {}, "piercing_strike") != CombatRules.player_attack(difficulty, {}, "arcane_lance"):
			parity_ok = false
	_check(parity_ok, "Tajo y Lanza comparten la misma fuerza base")
	var range_parity := CombatRules.attack_difficulty_range(1, 3, "piercing_strike") == CombatRules.attack_difficulty_range(1, 3, "arcane_lance")
	_check(range_parity, "Tajo y Lanza afrontan la misma dificultad")
	var cultist := CombatRules.enemy_by_id("cultist")
	var skeleton := CombatRules.enemy_by_id("skeleton")
	var tajo_vs_cultist := CombatRules.damage_for_attack(20, "piercing_strike", cultist)
	var lanza_vs_cultist := CombatRules.damage_for_attack(20, "arcane_lance", cultist)
	var tajo_vs_skeleton := CombatRules.damage_for_attack(20, "piercing_strike", skeleton)
	var lanza_vs_skeleton := CombatRules.damage_for_attack(20, "arcane_lance", skeleton)
	_check(tajo_vs_cultist > lanza_vs_cultist, "el Tajo supera a la Lanza contra un enemigo débil a lo físico")
	_check(lanza_vs_skeleton > tajo_vs_skeleton, "la Lanza supera al Tajo contra un enemigo débil a lo mágico")
	var brigand := CombatRules.enemy_by_id("brigand")
	var warden := CombatRules.enemy_by_id("warden")
	var cultist_tags_ok := CombatRules.is_living_enemy(cultist) and CombatRules.is_magic_flux_immune(cultist)
	_check(brigand.get("id", "") == "brigand" and CombatRules.is_living_enemy(brigand), "el bandido es un enemigo vivo")
	_check(not CombatRules.is_living_enemy(skeleton) and CombatRules.is_magic_flux_immune(skeleton), "el esqueleto es no muerto e inmune al flujo mágico")
	_check(not CombatRules.is_living_enemy(warden) and CombatRules.is_magic_flux_immune(warden), "el guardián constructo es inmune y no sangra")
	_check(cultist_tags_ok, "el cultista vivo pero mágico es inmune al flujo y puede sangrar")
	_check(not CombatRules.is_magic_flux_immune(brigand), "un enemigo vivo común no es inmune al flujo mágico")
	var tags_ok := CombatRules.ENEMY_TAGS.size() == CombatRules.ENEMIES.size()
	for data in CombatRules.ENEMIES:
		if CombatRules.enemy_tags(data).is_empty() or CombatRules.enemy_type_label(data) == "":
			tags_ok = false
	_check(tags_ok, "todo el bestiario declara un tipo de cuerpo")
	var sweep_profile: Dictionary = CombatRules.PLAYER_ATTACKS["sweeping_cut"]
	_check(is_equal_approx(float(sweep_profile.get("mutilation_chance", 0.0)), 0.33), "Barrido declara 33% de Mutilación")
	var mut_rng := RandomNumberGenerator.new()
	mut_rng.seed = 987654
	var mut_applied := 0
	for i in range(10000):
		if mut_rng.randf() < float(sweep_profile.get("mutilation_chance", 0.0)):
			mut_applied += 1
	_check(mut_applied > 3000 and mut_applied < 3600, "la tirada de Mutilación ronda el 33%")
	_check(CombatRules.ability_indicator({"kind": "summon"}) == "INVOCACIÓN", "la invocación muestra su tipo")
	_check(CombatRules.ability_indicator({"kind": "attack", "effect": "vulnerable"}) == "ATAQUE · MARCA", "las intenciones híbridas muestran su efecto")
	var kit_rng := RandomNumberGenerator.new()
	kit_rng.seed = 4417
	var choices_ok := true
	var defend_blocked := true
	var boss := CombatRules.enemy_by_id("colossus")
	var ability_names: Array[String] = []
	for ability in boss.get("abilities", []):
		ability_names.append(String(ability.get("name", "")))
	for i in range(240):
		var chosen_ability := CombatRules.choose_enemy_ability(boss, kit_rng)
		if not ability_names.has(String(chosen_ability.get("name", ""))):
			choices_ok = false
	for i in range(120):
		var chosen_ability := CombatRules.choose_enemy_ability(boss, kit_rng, "", "defend")
		if String(chosen_ability.get("kind", "")) == "defend":
			defend_blocked = false
	_check(choices_ok, "la IA enemiga elige sólo habilidades de su kit")
	_check(defend_blocked, "la IA no defiende dos veces seguidas")

	Game._reset_mastery()
	Game.start_run()
	var app: Variant = MainSceneScript.new()
	get_tree().root.add_child(app)
	await get_tree().process_frame
	_click(app, "Nueva run")
	await get_tree().process_frame
	var fight: Variant = app.current
	if not _is_script(fight, CombatScreenScript):
		_check(false, "combate activo para probar kits y sello")
		app.queue_free()
		await get_tree().process_frame
		return
	_check(int(fight.turn_number) == 1, "el primer turno del combate está activo")
	_check(fight.enemy_intents.size() == fight.enemies.size(), "cada enemigo recibe una intención")
	_check(String(fight._enemy_intent_for(0).get("kind", "")) == "attack", "el primer turno enemigo siempre ataca")
	var basic := CombatRules.enemy_basic_attack(fight.enemies[0])
	fight.enemy_intents[0] = basic
	Game.run["hp"] = Game.max_hp()
	var raw_hit := Game.enemy_ability_damage(basic, 1, 0, 0)
	fight.player_shield = 1000
	var shield_result: Dictionary = fight._apply_enemy_attacks()
	_check(int(shield_result.get("absorbed", 0)) == raw_hit, "el escudo absorbe el golpe básico")
	_check(Game.hp() == Game.max_hp(), "el escudo evita el daño a la vida")
	_check(fight.player_shield == 1000 - raw_hit, "el escudo se consume al absorber")
	Game.run["hp"] = Game.max_hp()
	fight.player_shield = 0
	var plain_result: Dictionary = fight._apply_enemy_attacks()
	_check(int(plain_result.get("total", 0)) == raw_hit, "sin escudo el golpe básico llega completo")
	_check(Game.hp() == Game.max_hp() - raw_hit, "sin escudo la vida baja")

	fight.enemy_hps[0] = fight.enemy_max_hps[0]
	fight._sync_selected_enemy()
	fight.enemy_guards[0] = 4
	fight.phase = "select"
	fight._choose_attack("piercing_strike")
	var raw_player_hit := CombatRules.damage_for_attack(Game.attack_damage(fight.chosen_diff, "piercing_strike"), "piercing_strike", fight.enemies[0])
	var before_guard_hp := int(fight.enemy_hps[0])
	fight._resolve(true)
	_check(fight.enemy_hps[0] == maxi(0, before_guard_hp - maxi(0, raw_player_hit - 4)), "la guardia enemiga reduce el daño recibido")
	_check(int(fight.enemy_guards[0]) == 0, "la guardia enemiga se consume con el golpe")

	fight.enemy_hps[0] = fight.enemy_max_hps[0]
	fight.enemy_intents[0] = {"name": "Prueba de cura", "kind": "heal", "value": 8, "text": "Cura de prueba."}
	var before_heal := int(fight.enemy_hps[0]) - 10
	fight.enemy_hps[0] = before_heal
	fight._sync_selected_enemy()
	fight._apply_enemy_attacks()
	_check(fight.enemy_hps[0] == mini(fight.enemy_max_hps[0], before_heal + 8), "la habilidad de cura restaura vida enemiga")

	fight.enemy_intents[0] = {"name": "Prueba de furia", "kind": "buff", "value": 4, "turns": 3, "text": "Furia de prueba."}
	fight._apply_enemy_attacks()
	_check(fight.enemy_bonus_damage[0] == 4 and fight.enemy_bonus_turns[0] == 3, "la furia enemiga acumula daño y duración")

	fight.player_weaken_pct = 0
	fight.player_weaken_turns = 0
	fight.enemy_intents[0] = {"name": "Prueba de maldición", "kind": "debuff", "effect": "weaken", "value": 25, "turns": 2, "text": "Maldición de prueba."}
	fight._apply_enemy_attacks()
	_check(fight.player_weaken_pct == 25 and fight.player_weaken_turns == 2, "la maldición reduce el daño del jugador")

	fight.player_vulnerable_bonus = 0
	fight.player_vulnerable_turns = 0
	fight.enemy_intents[0] = {"name": "Prueba de marca", "kind": "attack", "damage": 1, "effect": "vulnerable", "value": 3, "turns": 2, "text": "Marca de prueba."}
	fight._apply_enemy_attacks()
	_check(fight.player_vulnerable_bonus == 3 and fight.player_vulnerable_turns == 2, "la marca aumenta el daño recibido")

	Game.run["hp"] = Game.max_hp()
	fight.player_shield = 0
	fight.player_vulnerable_bonus = 0
	fight.player_vulnerable_turns = 0
	fight.enemy_bonus_damage[0] = 0
	fight.enemy_bonus_turns[0] = 0
	fight.enemy_intents[0] = {"name": "Prueba doble", "kind": "attack", "damage": 1, "effect": "multi", "hits": 2, "text": "Doble golpe de prueba."}
	var multi_result: Dictionary = fight._apply_enemy_attacks()
	_check(int(multi_result.get("total", 0)) == 2, "el ataque múltiple golpea dos veces")

	fight.enemy_hps[0] = fight.enemy_max_hps[0] - 10
	fight._sync_selected_enemy()
	fight.enemy_intents[0] = {"name": "Prueba de drenaje", "kind": "attack", "damage": 5, "effect": "drain", "value": 0.5, "text": "Drenaje de prueba."}
	Game.run["hp"] = Game.max_hp()
	var before_drain := int(fight.enemy_hps[0])
	fight._apply_enemy_attacks()
	_check(fight.enemy_hps[0] == mini(fight.enemy_max_hps[0], before_drain + 3), "el drenaje cura la mitad del daño causado")

	fight.phase = "select"
	fight.enemy_hps[0] = fight.enemy_max_hps[0]
	fight._sync_selected_enemy()
	fight.enemy_guards[0] = 0
	fight.player_shield = 0
	fight.player_weaken_pct = 0
	fight.player_weaken_turns = 0
	fight.player_vulnerable_bonus = 0
	fight.player_vulnerable_turns = 0
	fight.enemy_bonus_damage[0] = 0
	fight.enemy_bonus_turns[0] = 0
	fight.enemy_intents[0] = basic
	Game.run["hp"] = Game.max_hp()
	fight._choose_attack("ward_sigil")
	_check(fight.attack_target_indices.is_empty(), "el sello no exige objetivo enemigo")
	var shield_value := Game.attack_shield(fight.chosen_diff)
	fight._resolve(true)
	_check(fight.last_message.contains("escudo"), "el resultado explica el escudo del sello")
	_check(fight.enemy_hps[0] == fight.enemy_max_hps[0], "el sello no daña al enemigo")
	_check(Game.hp() == Game.max_hp(), "el sello bloquea por completo el ataque básico")
	_check(fight.player_shield == maxi(0, shield_value - raw_hit), "el escudo restante queda registrado")

	fight.phase = "select"
	for i in range(fight.enemies.size()):
		fight.enemy_hps[i] = fight.enemy_max_hps[i]
		fight.enemy_guards[i] = 0
		fight.enemy_fragile_bonus[i] = 0
		fight.enemy_fragile_turns[i] = 0
		fight.enemy_intents[i] = {"name": "Prueba defensiva", "kind": "defend", "value": 0, "text": "Sin ataque."}
	fight._sync_selected_enemy()
	fight._choose_attack("vital_breath")
	var expected_heal := Game.attack_heal(fight.chosen_diff, "vital_breath")
	Game.run["hp"] = 10
	var enemy_hp_before_heal := int(fight.enemy_hps[0])
	fight._resolve(true)
	_check(Game.hp() == 10 + expected_heal, "el aliento vital cura sin depender de un objetivo enemigo")
	_check(fight.enemy_hps[0] == enemy_hp_before_heal, "la curación no daña a los enemigos")

	# --- Estados de las técnicas: Debilidad, Flujo, Sangrado y Mutilación ---
	_set_test_enemy(fight, 0, "brigand", 500)
	fight.phase = "select"
	fight.selected_enemy_index = 0
	fight._sync_selected_enemy()
	_clear_fight_statuses(fight)
	fight._refresh_battlefield()

	# Debilidad de Lanza arcana: no reduce el golpe de la ronda en que se aplica,
	# pero sí los dos contraataques siguientes.
	fight._choose_attack("arcane_lance")
	fight._resolve(true)
	_check(fight.enemy_weak_pct[0] == 25 and fight.enemy_weak_turns[0] == 2, "Lanza arcana aplica Debilidad −25% durante 2 turnos")
	_check(fight.enemy_weak_applied_turn[0] == fight.turn_number, "Debilidad registra el turno en que se aplicó")
	fight.turn_number += 1
	for i in range(fight.enemies.size()):
		fight.enemy_intents[i] = {"name": "Prueba defensiva", "kind": "defend", "value": 0, "text": "Sin ataque."}
	fight.enemy_intents[0] = CombatRules.enemy_basic_attack(fight.enemies[0])
	Game.run["hp"] = Game.max_hp()
	fight.player_shield = 0
	var living_count: int = fight._living_enemy_indices().size()
	var weak_base := Game.enemy_ability_damage(fight.enemy_intents[0], living_count, 0, 0)
	var weak_expected := maxi(1, int(roundf(float(weak_base) * 0.75)))
	var weak_result: Dictionary = fight._apply_enemy_attacks()
	_check(int(weak_result.get("total", 0)) == weak_expected, "Debilidad reduce un 25% el daño enemigo")
	_check(fight.enemy_weak_turns[0] == 2, "Debilidad no se descuenta en el turno en que se aplicó")
	fight._tick_enemy_weakness()
	_check(fight.enemy_weak_turns[0] == 1, "Debilidad descuenta un turno después de la ronda")
	fight.turn_number += 1
	fight.enemy_intents[0] = CombatRules.enemy_basic_attack(fight.enemies[0])
	Game.run["hp"] = Game.max_hp()
	var weak_result_second: Dictionary = fight._apply_enemy_attacks()
	_check(int(weak_result_second.get("total", 0)) == weak_expected, "Debilidad sigue reduciendo el daño en el segundo turno")
	fight._tick_enemy_weakness()
	_check(fight.enemy_weak_turns[0] == 0 and fight.enemy_weak_pct[0] == 0, "Debilidad expira tras dos turnos")

	# Flujo de magia de Nova astral: daño por turno durante tres turnos.
	_clear_fight_statuses(fight)
	_set_test_enemy(fight, 0, "brigand", 500)
	fight.phase = "select"
	fight.selected_enemy_index = 0
	fight._sync_selected_enemy()
	fight._refresh_battlefield()
	fight._choose_attack("arcane_nova")
	var nova_hp_before := int(fight.enemy_hps[0])
	fight._resolve(true)
	_check(fight.enemy_flux_damage[0] == 3 and fight.enemy_flux_turns[0] == 3, "Nova astral aplica Flujo de magia 3 durante 3 turnos")
	_check(fight.enemy_fragile_turns[0] == 0 and fight.enemy_fragile_bonus[0] == 0, "Nova astral ya no aplica Frágil")
	_check(fight.enemy_hps[0] < nova_hp_before, "Nova astral daña a los enemigos vivos")
	var nova_after := int(fight.enemy_hps[0])
	var same_turn_flux: Dictionary = fight._tick_enemy_damage_over_time()
	_check(int(same_turn_flux.get("total", 0)) == 0 and int(fight.enemy_hps[0]) == nova_after, "el Flujo no daña en la ronda en que se aplica")
	for tick in range(3):
		fight.turn_number += 1
		var flux_tick: Dictionary = fight._tick_enemy_damage_over_time()
		_check(int(fight.enemy_hps[0]) == maxi(0, nova_after - 3 * (tick + 1)), "el Flujo resta 3 HP por turno")
		_check(fight.enemy_flux_turns[0] == 2 - tick, "el Flujo descuenta un turno por ronda")
		if tick == 0:
			_check(String(flux_tick.get("summary", "")).contains("flujo −3"), "el resumen del Flujo informa el daño")
	_check(fight.enemy_flux_turns[0] == 0 and fight.enemy_flux_damage[0] == 0, "el Flujo expira después de tres turnos")

	# Inmunidad al Flujo: los no muertos no reciben el estado.
	_clear_fight_statuses(fight)
	for i in range(fight.enemies.size()):
		_set_test_enemy(fight, i, "skeleton", 500)
	fight.phase = "select"
	fight.selected_enemy_index = 0
	fight._sync_selected_enemy()
	fight._refresh_battlefield()
	fight._choose_attack("arcane_nova")
	fight._resolve(true)
	var flux_immune := true
	for i in range(fight.enemies.size()):
		if fight.enemy_flux_turns[i] != 0:
			flux_immune = false
	_check(flux_immune, "los no muertos son inmunes al Flujo de magia")

	# Sangrado de Tajo perforante: sólo en cuerpos vivos.
	_clear_fight_statuses(fight)
	_set_test_enemy(fight, 0, "brigand", 500)
	fight.phase = "select"
	fight.selected_enemy_index = 0
	fight._sync_selected_enemy()
	fight._refresh_battlefield()
	fight._choose_attack("piercing_strike")
	fight._resolve(true)
	_check(fight.enemy_bleed_damage[0] == 2 and fight.enemy_bleed_turns[0] == 3, "Tajo perforante aplica Sangrado 2 durante 3 turnos")
	var bleed_after := int(fight.enemy_hps[0])
	var same_turn_bleed: Dictionary = fight._tick_enemy_damage_over_time()
	_check(int(same_turn_bleed.get("total", 0)) == 0 and int(fight.enemy_hps[0]) == bleed_after, "el Sangrado no daña en la ronda en que se aplica")
	for tick in range(3):
		fight.turn_number += 1
		fight._tick_enemy_damage_over_time()
		_check(int(fight.enemy_hps[0]) == maxi(0, bleed_after - 2 * (tick + 1)), "el Sangrado resta 2 HP por turno")
		_check(fight.enemy_bleed_turns[0] == 2 - tick, "el Sangrado descuenta un turno por ronda")
	_check(fight.enemy_bleed_turns[0] == 0 and fight.enemy_bleed_damage[0] == 0, "el Sangrado expira después de tres turnos")
	_clear_fight_statuses(fight)
	_set_test_enemy(fight, 0, "skeleton", 500)
	fight.phase = "select"
	fight.selected_enemy_index = 0
	fight._sync_selected_enemy()
	fight._refresh_battlefield()
	fight._choose_attack("piercing_strike")
	fight._resolve(true)
	_check(fight.enemy_bleed_turns[0] == 0, "los no muertos no sangran")
	_clear_fight_statuses(fight)
	_set_test_enemy(fight, 0, "cultist", 500)
	fight.phase = "select"
	fight.selected_enemy_index = 0
	fight._sync_selected_enemy()
	fight._refresh_battlefield()
	fight._choose_attack("piercing_strike")
	fight._resolve(true)
	_check(fight.enemy_bleed_turns[0] == 3, "un enemigo vivo de naturaleza mágica todavía sangra")

	# Mutilación: el enemigo pierde el turno inmediato siguiente.
	_clear_fight_statuses(fight)
	_set_test_enemy(fight, 0, "brigand", 500)
	fight.enemy_stun_turns[0] = 1
	fight.enemy_intents[0] = CombatRules.enemy_basic_attack(fight.enemies[0])
	Game.run["hp"] = Game.max_hp()
	var stun_result: Dictionary = fight._apply_enemy_attacks()
	_check(int(stun_result.get("total", 0)) == 0, "Mutilación hace perder el turno enemigo")
	_check(String(stun_result.get("summary", "")).contains("mutilado"), "el resumen informa la Mutilación")
	_check(fight.enemy_stun_turns[0] == 0, "Mutilación se consume después del turno perdido")

	# Barrido aplica Mutilación con una tirada real; se busca una semilla cuyo
	# primer randf esté por debajo del 33%, sin alterar la probabilidad del juego.
	_clear_fight_statuses(fight)
	_set_test_enemy(fight, 0, "brigand", 500)
	fight.phase = "select"
	fight.selected_enemy_index = 0
	fight._sync_selected_enemy()
	fight._refresh_battlefield()
	fight._choose_attack("sweeping_cut")
	var mut_seed := 1
	while true:
		var probe := RandomNumberGenerator.new()
		probe.seed = mut_seed
		if probe.randf() < 0.33:
			break
		mut_seed += 1
	fight.rng.seed = mut_seed
	fight._resolve(true)
	_check(fight.last_message.contains("Mutilación") or fight.last_message.contains("mutilado"), "Barrido puede aplicar Mutilación al golpear")
	_check(fight.enemy_stun_turns[0] == 0, "la Mutilación de Barrido se consume en el contraataque inmediato")

	# La muerte por daño por turno limpia los estados y registra el turno.
	_clear_fight_statuses(fight)
	_set_test_enemy(fight, 0, "brigand", 1)
	fight.turn_number += 1
	fight.enemy_bleed_damage[0] = 2
	fight.enemy_bleed_turns[0] = 3
	fight.enemy_bleed_applied_turn[0] = fight.turn_number - 1
	fight.enemy_flux_damage[0] = 3
	fight.enemy_flux_turns[0] = 3
	fight.enemy_flux_applied_turn[0] = fight.turn_number - 1
	fight.enemy_weak_pct[0] = 25
	fight.enemy_weak_turns[0] = 2
	fight.enemy_stun_turns[0] = 1
	var dot_death_turn := int(fight.turn_number)
	fight._tick_enemy_damage_over_time()
	_check(fight.enemy_hps[0] == 0, "el daño por turno puede derrotar a un enemigo")
	_check(fight.enemy_death_turns[0] == dot_death_turn, "la muerte por daño por turno registra el turno")
	_check(fight.enemy_bleed_turns[0] == 0 and fight.enemy_flux_turns[0] == 0 and fight.enemy_weak_turns[0] == 0 and fight.enemy_stun_turns[0] == 0, "los estados se limpian al morir")

	# Deja el combate listo para las pruebas de invocación y retirada.
	_clear_fight_statuses(fight)
	_set_test_enemy(fight, 0, "brigand", 500)
	fight.enemy_death_turns[0] = -1
	fight.phase = "select"
	fight.selected_enemy_index = 0
	fight._sync_selected_enemy()
	fight._refresh_battlefield()

	fight.phase = "select"
	for i in range(fight.enemies.size()):
		fight.enemy_intents[i] = {"name": "Prueba defensiva", "kind": "defend", "value": 0, "text": "Sin ataque."}
	fight.player_shield = 0
	fight.player_shield_expires_turn = 0
	fight._sync_selected_enemy()
	Game.run["hp"] = Game.max_hp()
	fight._choose_attack("ward_sigil")
	fight._resolve(true)
	_check(fight.player_shield > 0 and fight.player_shield_expires_turn == fight.turn_number + 3, "el sello intacto persiste dos turnos extra")
	_check(fight.last_message.contains("2 turnos más"), "el resultado avisa que el escudo persiste")

	if fight.enemies.size() < CombatRules.MAX_ENEMIES_PER_ENCOUNTER:
		var summon_name := str(fight._summon_enemy({"enemy": "skeleton", "summon_name": "Esqueleto de Cripta"}))
		_check(summon_name == "Esqueleto de Cripta" and fight.enemies.size() == fight.enemy_fragile_turns.size(), "la invocación añade un enemigo con sus estados")
		_check(fight.enemy_death_turns.size() == fight.enemies.size(), "la invocación mantiene el registro de turnos de muerte")
	if fight.enemies.size() >= 2:
		var purge_index := 0
		var purge_total: int = int(fight.enemies.size())
		fight.phase = "select"
		for i in range(fight.enemies.size()):
			fight.enemy_guards[i] = 0
			fight.enemy_intents[i] = {"name": "Prueba defensiva", "kind": "defend", "value": 0, "text": "Sin ataque."}
		fight.enemy_hps[purge_index] = 1
		fight.selected_enemy_index = purge_index
		fight._sync_selected_enemy()
		Game.run["hp"] = Game.max_hp()
		fight._choose_attack("piercing_strike")
		fight._resolve(true)
		_check(fight.enemy_hps[purge_index] == 0, "el golpe puede derrotar al enemigo de prueba")
		var death_turn := int(fight.turn_number)
		_check(fight.enemy_death_turns[purge_index] == death_turn, "la muerte queda registrada en el turno actual")
		fight.turn_number = death_turn + 1
		fight._purge_expired_enemy_corpses()
		_check(fight.enemies.size() == purge_total, "el derrotado permanece durante el turno de su muerte")
		fight.turn_number = death_turn + 2
		fight._purge_expired_enemy_corpses()
		_check(fight.enemies.size() == purge_total, "el derrotado permanece durante el primer turno siguiente")
		fight.turn_number = death_turn + 3
		fight._purge_expired_enemy_corpses()
		_check(fight.enemies.size() == purge_total - 1, "el derrotado desaparece después de dos turnos completos")
		_check(fight.enemy_actors.size() == fight.enemies.size(), "la formación se reajusta al retirar al derrotado")
		_check(fight.enemy_death_turns.size() == fight.enemies.size(), "los registros de muerte quedan alineados")
		_check(fight.selected_enemy_index >= 0 and fight.selected_enemy_index < fight.enemy_hps.size() and fight.enemy_hps[fight.selected_enemy_index] > 0, "la selección apunta a un enemigo vivo tras la retirada")
	app.queue_free()
	await get_tree().process_frame


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
