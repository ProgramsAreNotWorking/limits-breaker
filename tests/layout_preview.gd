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
	app.current._choose(0)
	await _snap("combat-solve")
	app.current._submit("999999")
	await _snap("combat-feedback")

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

	print("preview viewport: %s" % get_viewport().get_visible_rect().size)
	get_tree().quit()


func _snap(label: String) -> void:
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var image := get_viewport().get_texture().get_image()
	image.save_png("res://output/previews/final-review-%s.png" % label)
