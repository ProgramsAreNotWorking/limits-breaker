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

	Game._reset_mastery()
	Game.start_run()
	app._on_go("combat")
	await get_tree().process_frame
	var fight: Variant = app.current
	Game.run["hp"] = Game.max_hp()
	fight.phase = "solve"
	fight.chosen_diff = 2
	fight.chosen = fight.problems[2]
	fight._resolve(false)
	await _snap_after("vfx-hard-005", 0.05)
	await _snap_after("vfx-hard-018", 0.13)
	await _snap_after("vfx-hard-040", 0.22)

	fight.phase = "solve"
	fight.chosen_diff = 3
	fight.chosen = fight.problems[3]
	fight._resolve(true)
	await _snap_after("vfx-critical-006", 0.06)
	await _snap_after("vfx-critical-020", 0.14)
	await _snap_after("vfx-critical-045", 0.25)
	get_tree().quit()


func _snap_after(label: String, seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var image := get_viewport().get_texture().get_image()
	image.save_png("res://output/previews/%s.png" % label)
