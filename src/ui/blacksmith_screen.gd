class_name BlacksmithScreen
extends Control

const MediaManifest = preload("res://src/core/asset_manifest.gd")

signal go(target: String, payload: Variant)

var rng := RandomNumberGenerator.new()
var problem: MathEngine.Problem
var selected_upgrade := ""
var answered := false
var content: VBoxContainer
var answer_input: LineEdit


func _ready() -> void:
	rng.seed = int(Time.get_unix_time_from_system() * 1000.0) ^ 0x5A17
	if not bool(Game.run.get("active", false)):
		go.emit("menu", null)
		return
	problem = MathEngine.generate("trig", rng.randi_range(0, 3), rng)
	Audio.play_music("blacksmith")
	Audio.play_sfx("blacksmith")
	_build()


func _build() -> void:
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 48)
	margin.add_theme_constant_override("margin_right", 48)
	margin.add_theme_constant_override("margin_top", 36)
	margin.add_theme_constant_override("margin_bottom", 30)
	add_child(margin)
	content = UIKit.vbox(12)
	margin.add_child(content)
	_render_offer()


func _clear() -> void:
	for c in content.get_children():
		c.queue_free()


func _render_offer() -> void:
	_clear()
	var head := UIKit.hbox(14)
	content.add_child(head)
	var copy := UIKit.vbox(2)
	head.add_child(copy)
	copy.add_child(UIKit.eyebrow("Descanso · Encuentro %d" % int(Game.run.get("encounter", 1)), UIKit.GOLD_SOFT))
	copy.add_child(UIKit.title("LA FRAGUA", 38, UIKit.TEXT))
	var fill := Control.new()
	fill.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(fill)
	head.add_child(UIKit.badge("UNA MEJORA POR VISITA", UIKit.GOLD, 10))

	var intro := UIKit.panel(Color(0.06, 0.068, 0.078, 0.9), Color("#423b30"), true, UIKit.GOLD_SOFT)
	intro.custom_minimum_size = Vector2(0, 156)
	content.add_child(intro)
	var intro_row := UIKit.hbox(18)
	intro.add_child(intro_row)
	UIKit.add_portrait(intro_row, MediaManifest.character("blacksmith"), Vector2(144, 128))
	var intro_copy := UIKit.vbox(4)
	intro_copy.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	intro_copy.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	intro_row.add_child(intro_copy)
	intro_copy.add_child(UIKit.heading("El metal obedece a quien entiende.", 20, UIKit.GOLD))
	intro_copy.add_child(UIKit.label("No regalo nada. Elegí una mejora y demostrame que sabés qué hace el calor sobre el acero.", 14, UIKit.STEEL))
	intro_copy.add_child(UIKit.label("La mejora es permanente durante esta run.", 12, UIKit.STEEL_DARK))

	var cards := UIKit.hbox(10)
	cards.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_child(cards)
	for up in Combat.BLACKSMITH_UPGRADES:
		var card := UIKit.panel(Color(0.07, 0.078, 0.092, 0.94), Color("#3c4149"), true, _upgrade_accent(String(up["id"])))
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		card.custom_minimum_size = Vector2(0, 220)
		cards.add_child(card)
		var v := UIKit.vbox(8)
		v.alignment = BoxContainer.ALIGNMENT_CENTER
		card.add_child(v)
		var icon_id := "ashen_edge" if String(up["id"]) == "temper" else ("warden_plate" if String(up["id"]) == "reinforce" else "void_sigil")
		var icon_center := CenterContainer.new()
		v.add_child(icon_center)
		UIKit.add_item_icon(icon_center, icon_id, Vector2(58, 58))
		v.add_child(UIKit.eyebrow(_upgrade_kind(String(up["id"])), _upgrade_accent(String(up["id"]))))
		var label := UIKit.heading(String(up["label"]), 18, UIKit.TEXT)
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		v.add_child(label)
		v.add_child(UIKit.label(String(up["desc"]), 13, UIKit.STEEL))
		var b := UIKit.button("Elegir", _upgrade_accent(String(up["id"])))
		b.pressed.connect(func() -> void:
			selected_upgrade = String(up["id"])
			Audio.play_sfx("blacksmith")
			_render_question())
		v.add_child(b)

	content.add_child(UIKit.label("La fragua no admite codicia: elegí una sola mejora.", 12, UIKit.STEEL_DARK))


func _upgrade_accent(id: String) -> Color:
	match id:
		"temper":
			return UIKit.BURGUNDY_HI
		"reinforce":
			return UIKit.STEEL
		"enchant":
			return UIKit.VIOLET
	return UIKit.GOLD_SOFT


func _upgrade_kind(id: String) -> String:
	match id:
		"temper":
			return "ARMA · DAÑO"
		"reinforce":
			return "ARMADURA · VITALIDAD"
		"enchant":
			return "RELIQUIA · DEFENSA"
	return "MEJORA"


func _render_question() -> void:
	_clear()
	content.add_child(_page_head("DESAFÍO DEL HERRERO", "La fragua escucha. Una respuesta, una oportunidad."))
	var center := CenterContainer.new()
	center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_child(center)
	var panel := UIKit.panel(Color(0.06, 0.068, 0.082, 0.94), Color("#3b414b"), true, _upgrade_accent(selected_upgrade))
	panel.custom_minimum_size = Vector2(820, 0)
	center.add_child(panel)
	var v := UIKit.vbox(12)
	panel.add_child(v)
	v.add_child(UIKit.eyebrow("PREGUNTA", _upgrade_accent(selected_upgrade)))
	v.add_child(UIKit.label(problem.statement, 15, UIKit.MUTED))
	var expr := UIKit.math_label(problem.expression, 38, UIKit.TEXT)
	v.add_child(expr)
	var row := UIKit.hbox(10)
	v.add_child(row)
	answer_input = UIKit.line_edit("Resultado decimal, por ejemplo 0,866", 19)
	answer_input.text_submitted.connect(func(raw: String) -> void: _answer(raw))
	row.add_child(answer_input)
	var submit := UIKit.button("Responder", UIKit.BURGUNDY)
	submit.custom_minimum_size = Vector2(154, 50)
	submit.pressed.connect(func() -> void: _answer(answer_input.text))
	row.add_child(submit)
	var hint := UIKit.hbox(8)
	v.add_child(hint)
	hint.add_child(UIKit.keycap("ENTER  RESPONDER"))
	var hint_copy := UIKit.inline_label("Teclado físico. Escribí el resultado y pulsá Enter.", 12, UIKit.STEEL_DARK)
	hint_copy.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hint.add_child(hint_copy)
	answer_input.grab_focus()


func _render_result(correct: bool) -> void:
	_clear()
	var center := CenterContainer.new()
	center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_child(center)
	var panel := UIKit.panel(Color(0.06, 0.068, 0.082, 0.94), Color("#3b414b"), true, UIKit.OK if correct else UIKit.DANGER)
	panel.custom_minimum_size = Vector2(760, 0)
	center.add_child(panel)
	var v := UIKit.vbox(9)
	v.alignment = BoxContainer.ALIGNMENT_CENTER
	panel.add_child(v)
	var portrait_row := CenterContainer.new()
	v.add_child(portrait_row)
	UIKit.add_portrait(portrait_row, MediaManifest.character("blacksmith"), Vector2(116, 116))
	v.add_child(UIKit.eyebrow("La fragua respondió", UIKit.OK if correct else UIKit.DANGER))
	v.add_child(UIKit.heading("El metal cede" if correct else "El metal se niega", 28, UIKit.OK if correct else UIKit.DANGER))
	v.add_child(UIKit.label("Respuesta correcta: %s" % MathEngine.format_answer(problem), 16, UIKit.GOLD))
	for s in problem.steps:
		v.add_child(UIKit.label("· " + s, 12, UIKit.STEEL))
	v.add_child(UIKit.label("Mejora aplicada." if correct else "No obtenés la mejora esta vez.", 14, UIKit.TEXT if correct else UIKit.MUTED))
	var row := UIKit.hbox(10)
	row.alignment = BoxContainer.ALIGNMENT_END
	v.add_child(row)
	var cont := UIKit.button("Volver al camino", UIKit.VIOLET_SOFT)
	cont.custom_minimum_size = Vector2(220, 46)
	cont.pressed.connect(func() -> void:
		Audio.play_music("combat")
		go.emit("combat", null))
	row.add_child(cont)


func _page_head(title: String, subtitle: String) -> Control:
	var box := UIKit.vbox(2)
	box.add_child(UIKit.eyebrow("La fragua", UIKit.GOLD_SOFT))
	box.add_child(UIKit.title(title, 30, UIKit.TEXT))
	box.add_child(UIKit.label(subtitle, 13, UIKit.MUTED))
	return box


func _answer(raw: String) -> void:
	if answered:
		return
	answered = true
	var correct := MathEngine.grade(problem, raw)
	if correct:
		Game.apply_upgrade(selected_upgrade)
		Audio.play_sfx("correct")
		Audio.play_sfx("equipment")
	else:
		Audio.play_sfx("incorrect")
	_render_result(correct)
