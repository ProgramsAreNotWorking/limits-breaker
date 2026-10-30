extends Node

const MainSceneScript := preload("res://src/main.gd")


func _ready() -> void:
	await get_tree().process_frame
	Audio.playback_enabled = false
	get_window().size = Vector2i(1280, 720)
	await get_tree().process_frame
	var app: Control = MainSceneScript.new()
	add_child(app)
	app.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	await get_tree().process_frame
	await _snap("menu")

	app._on_go("settings")
	await _snap("settings")
	app._on_go("mastery")
	await _snap("mastery")
	app._on_go("death")
	await _snap("death")
	app._on_go("victory")
	await _snap("victory")
	Game.start_run()
	app._on_go("angel")
	await _snap("angel")

	Game.start_run()
	app._on_go("combat")
	await _snap("combat-select")
	app.current._show_system_menu()
	await _snap("combat-menu")
	app.current._show_end_run_confirm()
	await _snap("combat-end-run")
	app.current._close_overlay()
	app.current._choose(0)
	await _snap("combat-solve")
	app.current._submit("999999")
	await _snap("combat-feedback")

	Game.start_run()
	app._on_go("combat")
	app.current._choose_attack("ward_sigil")
	await _snap("combat-defense-solve")
	app.current._submit(MathEngine.format_answer(app.current.chosen))
	await _snap("combat-defense-feedback")

	Game.start_run()
	app._on_go("combat")
	Game.run["hp"] = 50
	app.current._refresh_hud()
	app.current._choose_attack("vital_breath")
	await _snap("combat-heal-solve")
	app.current._submit(MathEngine.format_answer(app.current.chosen))
	await _snap("combat-heal-feedback")

	Game.start_run()
	app._on_go("combat")
	app.current._choose_attack("arcane_nova")
	await _snap("combat-nova-solve")
	app.current._submit(MathEngine.format_answer(app.current.chosen))
	await _snap("combat-nova-feedback")

	Game.start_run()
	Game.run["encounter"] = 9
	app._on_go("combat")
	while app.current.enemies.size() < 4:
		app.current._summon_enemy({"enemy": "skeleton", "summon_name": "Esqueleto de Cripta"})
	for i in range(mini(4, app.current.enemies.size())):
		var kinds: Array[String] = ["attack", "defend", "heal", "summon"]
		var kind := kinds[i % kinds.size()]
		app.current.enemy_intents[i] = {
			"name": "Prueba de intención",
			"kind": kind,
			"value": 6 if kind in ["defend", "heal"] else 0,
			"summon_name": "Esqueleto de Cripta",
			"text": "Vista previa del indicador de intención.",
		}
	app.current._refresh_battlefield()
	app.current._refresh_hud()
	await _snap("combat-indicators")

	Game.start_run()
	app._on_go("combat")
	app.current._summon_enemy({"enemy": "skeleton", "summon_name": "Esqueleto de Cripta"})
	app.current._refresh_battlefield()
	app.current._refresh_hud()
	await _snap("combat-summon")

	Game.start_run()
	app._on_go("combat")
	for i in range(app.current.enemies.size()):
		app.current.enemy_intents[i] = {"name": "Prueba defensiva", "kind": "defend", "value": 0, "text": "Sin ataque."}
	app.current._choose_attack("ward_sigil")
	app.current._submit(MathEngine.format_answer(app.current.chosen))
	await _snap("combat-shield-persist")

	Game.start_run()
	app._on_go("combat")
	app.current.player_weaken_pct = 25
	app.current.player_weaken_turns = 2
	app.current.player_vulnerable_bonus = 2
	app.current.player_vulnerable_turns = 2
	app.current._refresh_hud()
	await _snap("combat-status")

	Game.start_run()
	Game.run["encounter"] = 8
	app._on_go("combat")
	app.current.enemy_intents[0] = {"name": "Círculo de ceniza", "kind": "defend", "value": 6}
	app.current.enemy_guards[0] = 6
	app.current._refresh_battlefield()
	app.current._refresh_hud()
	await _snap("combat-guard")

	Game.start_run()
	app._on_go("combat")
	app.current.chosen = MathEngine.generate("graph", 0, app.current.rng)
	app.current.chosen_diff = 0
	app.current.topic = "graph"
	app.current.phase = "solve"
	app.current._render_solve()
	await _snap("combat-graph")

	Game.start_run()
	app._on_go("combat")
	app.current.chosen = MathEngine.generate("graph", 3, app.current.rng)
	app.current.chosen_diff = 3
	app.current.topic = "graph"
	app.current.phase = "solve"
	app.current._render_solve()
	await _snap("combat-graph-discontinuous")

	Game.start_run()
	Game.run["encounter"] = 9
	app._on_go("combat")
	while app.current.enemies.size() < 4:
		app.current._summon_enemy({"enemy": "skeleton", "summon_name": "Esqueleto de Cripta"})
	for i in range(mini(4, app.current.enemies.size())):
		var kinds: Array[String] = ["attack", "defend", "heal", "summon"]
		var kind := kinds[i % kinds.size()]
		app.current.enemy_intents[i] = {
			"name": "Prueba de intención",
			"kind": kind,
			"value": 6 if kind in ["defend", "heal"] else 0,
			"summon_name": "Esqueleto de Cripta",
			"text": "Vista previa del indicador de intención.",
		}
	app.current._refresh_battlefield()
	await get_tree().process_frame
	await get_tree().process_frame
	app.current.chosen = MathEngine.generate("graph", 0, app.current.rng)
	app.current.chosen_diff = 0
	app.current.topic = "graph"
	app.current.phase = "solve"
	app.current._render_solve()
	await _snap("combat-graph-four-enemies")

	Game.start_run()
	app._on_go("combat")
	app.current.chosen = MathEngine.generate("table", 0, app.current.rng)
	app.current.chosen_diff = 0
	app.current.topic = "table"
	app.current.phase = "solve"
	app.current._render_solve()
	await _snap("combat-table")

	Game.start_run()
	app._on_go("combat")
	app.current._show_inventory()
	await _snap("inventory-empty")
	app.current._close_overlay()

	Game.start_run()
	app._on_go("combat")
	for item_id in ["rusted_blade", "ember_charm", "greater_draught", "ashen_edge"]:
		Game.add_item(item_id)
	app.current._show_inventory()
	await _snap("inventory-full")
	app.current._close_overlay()

	Game.start_run()
	app._on_go("combat")
	app.current.phase = "transition"
	app.current.enemy_hp = 0
	app._on_go("blacksmith")
	await _snap("blacksmith-offer")
	app.current.selected_upgrade = "temper"
	app.current._render_question()
	await _snap("blacksmith-question")
	app.current._answer(MathEngine.format_answer(app.current.problem))
	await _snap("blacksmith-result")

	get_window().size = Vector2i(960, 540)
	await get_tree().process_frame
	await get_tree().process_frame
	Game.start_run()
	app._on_go("combat")
	await _snap("combat-select-960")
	Game.run["encounter"] = 2
	app._on_go("combat")
	while app.current.enemies.size() < 2:
		app.current._summon_enemy({"enemy": "bell_keeper"})
	app.current._refresh_battlefield()
	app.current._refresh_hud()
	await _snap("combat-two-960")
	Game.run["encounter"] = 9
	app._on_go("combat")
	while app.current.enemies.size() < 4:
		app.current._summon_enemy({"enemy": "skeleton", "summon_name": "Esqueleto de Cripta"})
	app.current._refresh_battlefield()
	app.current._refresh_hud()
	await _snap("combat-indicators-960")
	Game.start_run()
	app._on_go("combat")
	app.current.chosen = MathEngine.generate("graph", 0, app.current.rng)
	app.current.chosen_diff = 0
	app.current.topic = "graph"
	app.current.phase = "solve"
	app.current._render_solve()
	await _snap("combat-graph-960")
	Game.start_run()
	Game.run["encounter"] = 9
	app._on_go("combat")
	while app.current.enemies.size() < 4:
		app.current._summon_enemy({"enemy": "skeleton", "summon_name": "Esqueleto de Cripta"})
	for i in range(mini(4, app.current.enemies.size())):
		var kinds: Array[String] = ["attack", "defend", "heal", "summon"]
		var kind := kinds[i % kinds.size()]
		app.current.enemy_intents[i] = {
			"name": "Prueba de intención",
			"kind": kind,
			"value": 6 if kind in ["defend", "heal"] else 0,
			"summon_name": "Esqueleto de Cripta",
			"text": "Vista previa del indicador de intención.",
		}
	app.current._refresh_battlefield()
	app.current.chosen = MathEngine.generate("graph", 0, app.current.rng)
	app.current.chosen_diff = 0
	app.current.topic = "graph"
	app.current.phase = "solve"
	app.current._render_solve()
	await _snap("combat-graph-four-960")

	for i in range(mini(4, app.current.enemies.size())):
		app.current.enemy_weak_pct[i] = 25
		app.current.enemy_weak_turns[i] = 2
		app.current.enemy_flux_damage[i] = 3
		app.current.enemy_flux_turns[i] = 3
		app.current.enemy_bleed_damage[i] = 2
		app.current.enemy_bleed_turns[i] = 3
	app.current.enemy_stun_turns[1] = 1
	app.current._refresh_battlefield()
	await _snap("combat-graph-four-status-960")

	print("preview viewport: %s" % get_viewport().get_visible_rect().size)
	get_tree().quit()


func _snap(label: String) -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var image := get_viewport().get_texture().get_image()
	image.save_png("res://output/previews/final-review-%s.png" % label)
