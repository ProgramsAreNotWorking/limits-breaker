class_name AngelScreen
extends Control

const MediaManifest = preload("res://src/core/asset_manifest.gd")

signal go(target: String, payload: Variant)

var rng := RandomNumberGenerator.new()
var problem: MathEngine.Problem
var answered := false
var content: VBoxContainer
var answer_input: LineEdit
var angel_portrait: FantasyPortrait


func _ready() -> void:
	rng.seed = int(Time.get_unix_time_from_system() * 1000.0) ^ 0xA9E1
	if not bool(Game.run.get("active", false)):
		go.emit("menu", null)
		return
	problem = MathEngine.angel_problem(rng.randi_range(0, 3), rng)
	Audio.play_music("angel")
	Audio.play_sfx("angel")
	_build()


func _build() -> void:
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 48)
	margin.add_theme_constant_override("margin_right", 48)
	margin.add_theme_constant_override("margin_top", 38)
	margin.add_theme_constant_override("margin_bottom", 32)
	add_child(margin)
	content = UIKit.vbox(12)
	margin.add_child(content)
	_render_question()


func _clear() -> void:
	for c in content.get_children():
		c.queue_free()


func _render_question() -> void:
	_clear()
	var head := UIKit.hbox(14)
	content.add_child(head)
	var copy := UIKit.vbox(2)
	head.add_child(copy)
	copy.add_child(UIKit.eyebrow("Santuario entre encuentros", UIKit.GOLD_SOFT))
	copy.add_child(UIKit.title("EL ÁNGEL", 38, UIKit.TEXT))
	var fill := Control.new()
	fill.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(fill)
	head.add_child(UIKit.badge("UNA OPORTUNIDAD", UIKit.GOLD, 10))

	var center := CenterContainer.new()
	center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_child(center)
	var panel := UIKit.panel(Color(0.058, 0.066, 0.082, 0.94), Color("#3d4149"), true, UIKit.GOLD_SOFT)
	panel.custom_minimum_size = Vector2(900, 0)
	center.add_child(panel)
	var row := UIKit.hbox(22)
	panel.add_child(row)

	var left := UIKit.vbox(6)
	left.custom_minimum_size = Vector2(232, 0)
	left.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_child(left)
	angel_portrait = UIKit.add_portrait(left, MediaManifest.character("angel"), Vector2(218, 168))
	left.add_child(UIKit.heading("No pide fe.", 21, UIKit.GOLD))
	left.add_child(UIKit.label("Pide una factorización.", 14, UIKit.STEEL))
	left.add_child(UIKit.label("La luz no juzga la respuesta: mide lo que entendiste.", 12, UIKit.STEEL_DARK))

	row.add_child(UIKit.vertical_rule(Color(UIKit.STONE, 0.6), 1))

	var right := UIKit.vbox(10)
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_child(right)
	right.add_child(UIKit.eyebrow("PREGUNTA", UIKit.GOLD))
	right.add_child(UIKit.label(problem.statement, 15, UIKit.MUTED))
	right.add_child(UIKit.math_label(problem.expression, 38, UIKit.TEXT))
	var input_row := UIKit.hbox(10)
	right.add_child(input_row)
	answer_input = UIKit.line_edit("Raíces ordenadas: menor, mayor", 18)
	answer_input.text_submitted.connect(func(raw: String) -> void: _answer(raw))
	input_row.add_child(answer_input)
	var submit := UIKit.button("Responder", UIKit.BURGUNDY)
	submit.custom_minimum_size = Vector2(154, 50)
	submit.pressed.connect(func() -> void: _answer(answer_input.text))
	input_row.add_child(submit)
	var hint := UIKit.hbox(8)
	right.add_child(hint)
	hint.add_child(UIKit.keycap("ENTER  RESPONDER"))
	var hint_copy := UIKit.inline_label("Escribí las dos raíces separadas por una coma. Ejemplo: -2, 5", 12, UIKit.STEEL_DARK)
	hint_copy.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hint.add_child(hint_copy)
	answer_input.grab_focus()


func _answer(raw: String) -> void:
	if answered:
		return
	answered = true
	var correct := MathEngine.grade(problem, raw)
	var healed := 0
	if correct:
		healed = Game.add_hp(Game.angel_heal_for(problem.difficulty))
		Audio.play_sfx("correct")
		Audio.play_sfx("heal")
	else:
		Game.add_hp(1)
		Audio.play_sfx("incorrect")
	_render_result(correct, healed)


func _render_result(correct: bool, healed: int) -> void:
	_clear()
	var center := CenterContainer.new()
	center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_child(center)
	var panel := UIKit.panel(Color(0.058, 0.066, 0.082, 0.94), Color("#3d4149"), true, UIKit.GOLD if correct else UIKit.STEEL_DARK)
	panel.custom_minimum_size = Vector2(760, 0)
	center.add_child(panel)
	var v := UIKit.vbox(9)
	v.alignment = BoxContainer.ALIGNMENT_CENTER
	panel.add_child(v)
	var portrait_row := CenterContainer.new()
	v.add_child(portrait_row)
	UIKit.add_portrait(portrait_row, MediaManifest.character("angel"), Vector2(126, 126))
	v.add_child(UIKit.eyebrow("El ángel respondió", UIKit.GOLD if correct else UIKit.STEEL_DARK))
	v.add_child(UIKit.heading("Luz restauradora" if correct else "La luz apenas alcanza", 28, UIKit.GOLD if correct else UIKit.STEEL))
	v.add_child(UIKit.label("Raíces correctas: %s" % MathEngine.format_answer(problem), 16, UIKit.OK if correct else UIKit.GOLD))
	v.add_child(UIKit.label("Recuperás %d HP (tope: %d)." % [healed, Game.max_hp()] if correct else "Recuperás exactamente 1 HP.", 14, UIKit.TEXT if correct else UIKit.MUTED))
	for s in problem.steps:
		v.add_child(UIKit.label("· " + s, 12, UIKit.STEEL))
	var row := UIKit.hbox(10)
	row.alignment = BoxContainer.ALIGNMENT_END
	v.add_child(row)
	var cont := UIKit.button("Continuar", UIKit.BURGUNDY)
	cont.custom_minimum_size = Vector2(220, 46)
	cont.pressed.connect(func() -> void:
		Audio.play_music("combat")
		go.emit("combat", null))
	row.add_child(cont)
