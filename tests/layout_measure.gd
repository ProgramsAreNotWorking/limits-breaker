extends Node

const MainMenu := preload("res://src/ui/main_menu.gd")
const Combat := preload("res://src/ui/combat_screen.gd")
const Blacksmith := preload("res://src/ui/blacksmith_screen.gd")
const Angel := preload("res://src/ui/angel_screen.gd")
const Death := preload("res://src/ui/death_screen.gd")
const Victory := preload("res://src/ui/victory_screen.gd")
const Mastery := preload("res://src/ui/mastery_screen.gd")
const Settings := preload("res://src/ui/settings_screen.gd")


func _ready() -> void:
	await get_tree().process_frame
	Audio.playback_enabled = false
	Game.start_run()
	Game.run["active"] = true
	for entry in [
		["menu", MainMenu],
		["settings", Settings],
		["mastery", Mastery],
		["death", Death],
		["victory", Victory],
		["blacksmith", Blacksmith],
		["angel", Angel],
	]:
		await _measure_plain(String(entry[0]), entry[1])
	await _measure_combat()
	await _measure_blacksmith()
	get_tree().quit()


func _mount(script: Script) -> Control:
	var screen: Control = script.new()
	add_child(screen)
	screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	if screen.has_signal("go"):
		screen.connect("go", func(_target: String, _payload: Variant) -> void: pass)
	await get_tree().process_frame
	return screen


func _measure_plain(label: String, script: Script) -> void:
	var screen := await _mount(script)
	_print_size(label, screen)
	screen.queue_free()
	await get_tree().process_frame


func _measure_combat() -> void:
	var fight: Control = await _mount(Combat)
	_print_size("combat-select", fight)
	fight._choose(0)
	await get_tree().process_frame
	_print_size("combat-solve", fight)
	fight._submit("999999")
	await get_tree().process_frame
	_print_size("combat-feedback", fight)
	fight.queue_free()
	await get_tree().process_frame

	var graph: Control = await _mount(Combat)
	graph.chosen = MathEngine.generate("graph", 0, graph.rng)
	graph.chosen_diff = 0
	graph.topic = "graph"
	graph.phase = "solve"
	graph._render_solve()
	await get_tree().process_frame
	_print_size("combat-graph", graph)
	graph.queue_free()
	await get_tree().process_frame

	var table: Control = await _mount(Combat)
	table.chosen = MathEngine.generate("table", 0, table.rng)
	table.chosen_diff = 0
	table.topic = "table"
	table.phase = "solve"
	table._render_solve()
	await get_tree().process_frame
	_print_size("combat-table", table)
	table.queue_free()
	await get_tree().process_frame


func _measure_blacksmith() -> void:
	var smith: Control = await _mount(Blacksmith)
	_print_size("blacksmith-offer", smith)
	smith.selected_upgrade = "temper"
	smith._render_question()
	await get_tree().process_frame
	_print_size("blacksmith-question", smith)
	var answer := MathEngine.format_answer(smith.problem)
	smith._answer(answer)
	await get_tree().process_frame
	_print_size("blacksmith-result", smith)
	smith.queue_free()
	await get_tree().process_frame


func _print_size(label: String, screen: Control) -> void:
	var content: Control = screen.get_child(0) if screen.get_child_count() > 0 else screen
	print("%s: viewport=%s min=%s" % [label, screen.size, content.get_combined_minimum_size()])
