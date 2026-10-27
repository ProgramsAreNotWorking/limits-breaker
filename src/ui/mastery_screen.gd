class_name MasteryScreen
extends Control

signal go(target: String, payload: Variant)


func _ready() -> void:
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 56)
	margin.add_theme_constant_override("margin_right", 56)
	margin.add_theme_constant_override("margin_top", 38)
	margin.add_theme_constant_override("margin_bottom", 30)
	add_child(margin)

	var root := UIKit.vbox(12)
	margin.add_child(root)

	var head := UIKit.hbox(14)
	root.add_child(head)
	var head_copy := UIKit.vbox(2)
	head.add_child(head_copy)
	head_copy.add_child(UIKit.eyebrow("Códice permanente", UIKit.GOLD))
	head_copy.add_child(UIKit.title("REGISTRO DE MAESTRÍA", 36, UIKit.TEXT))
	var head_spacer := Control.new()
	head_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(head_spacer)
	var back := UIKit.button("Volver", UIKit.STEEL_DARK)
	back.custom_minimum_size = Vector2(132, 44)
	back.pressed.connect(func() -> void:
		Audio.play_sfx("select")
		go.emit("menu", null))
	head.add_child(back)

	root.add_child(UIKit.label("La muerte borra la run. Esto no se borra.", 15, UIKit.MUTED))

	var total_attempts := 0
	var total_correct := 0
	var total_level := 0
	for topic in MathEngine.TOPICS:
		var s := Game.topic_stats(topic)
		total_attempts += int(s.get("attempts", 0))
		total_correct += int(s.get("correct", 0))
		total_level += Game.mastery_level(topic)
	var accuracy := 0.0 if total_attempts == 0 else float(total_correct) / float(total_attempts) * 100.0

	var summary := UIKit.hbox(10)
	root.add_child(summary)
	summary.add_child(UIKit.stat_tile("NIVEL TOTAL", "%d / 15" % total_level, UIKit.GOLD, 210))
	summary.add_child(UIKit.stat_tile("PRECISIÓN", "—" if total_attempts == 0 else "%.0f%%" % accuracy, UIKit.STEEL, 210))
	summary.add_child(UIKit.stat_tile("PROBLEMAS", str(total_attempts), UIKit.STEEL, 210))
	var summary_fill := Control.new()
	summary_fill.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	summary.add_child(summary_fill)

	var panel := UIKit.panel(Color(0.055, 0.066, 0.083, 0.92), Color("#343d49"), true, UIKit.GOLD_SOFT)
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(panel)
	var list := UIKit.vbox(0)
	list.add_theme_constant_override("separation", 0)
	panel.add_child(list)

	var first := true
	for topic in MathEngine.TOPICS:
		if not first:
			list.add_child(UIKit.rule(Color(UIKit.STONE, 0.7), 1))
		first = false
		list.add_child(_topic_row(topic))

	var legend_gap := Control.new()
	legend_gap.size_flags_vertical = Control.SIZE_EXPAND_FILL
	list.add_child(legend_gap)
	list.add_child(UIKit.rule(Color(UIKit.STONE, 0.7), 1))
	var legend := UIKit.vbox(3)
	list.add_child(legend)
	legend.add_child(UIKit.eyebrow("Cómo se sube de nivel", UIKit.GOLD_SOFT))
	legend.add_child(UIKit.label("Nivel 1: 3 aciertos fáciles y 50% de precisión.  ·  Nivel 2: 4 intermedios y 60%.  ·  Nivel 3: 4 avanzados y 70%.", 11, UIKit.STEEL_DARK))

	root.add_child(UIKit.label("Las dificultades se desbloquean con acierto demostrado, no con kills.", 12, UIKit.STEEL_DARK))


func _topic_row(topic: String) -> Control:
	var s := Game.topic_stats(topic)
	var attempts := int(s.get("attempts", 0))
	var correct := int(s.get("correct", 0))
	var acc := 0.0 if attempts == 0 else float(correct) / float(attempts) * 100.0
	var level := Game.mastery_level(topic)
	var row := UIKit.hbox(12)
	row.custom_minimum_size = Vector2(0, 66)

	var index := UIKit.display_label(_roman(MathEngine.TOPICS.find(topic) + 1), 18, UIKit.GOLD_SOFT, 600, 0)
	index.custom_minimum_size = Vector2(30, 0)
	row.add_child(index)

	var identity := UIKit.vbox(2)
	identity.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	identity.add_child(UIKit.label(String(MathEngine.TOPIC_LABELS[topic]), 17, UIKit.TEXT, 500))
	var by: Array = s.get("by_diff", [0, 0, 0, 0])
	var cby: Array = s.get("correct_by_diff", [0, 0, 0, 0])
	var detail := "Fácil %d/%d  ·  Inter %d/%d  ·  Avanz %d/%d  ·  Súper %d/%d" % [
		int(cby[0]), int(by[0]), int(cby[1]), int(by[1]),
		int(cby[2]), int(by[2]), int(cby[3]), int(by[3]),
	]
	identity.add_child(UIKit.inline_label(detail, 12, UIKit.STEEL_DARK))
	row.add_child(identity)

	var level_box := UIKit.vbox(3)
	level_box.custom_minimum_size = Vector2(124, 0)
	level_box.alignment = BoxContainer.ALIGNMENT_CENTER
	level_box.add_child(UIKit.eyebrow("NIVEL %d / 3" % level, UIKit.GOLD if level > 0 else UIKit.STEEL_DARK))
	var pips := UIKit.inline_label(_pips(level), 16, UIKit.GOLD if level > 0 else UIKit.STONE_HI, 500)
	level_box.add_child(pips)
	row.add_child(level_box)

	var acc_box := UIKit.vbox(3)
	acc_box.custom_minimum_size = Vector2(104, 0)
	acc_box.alignment = BoxContainer.ALIGNMENT_CENTER
	acc_box.add_child(UIKit.eyebrow("PRECISIÓN", UIKit.STEEL_DARK))
	acc_box.add_child(UIKit.inline_label("—" if attempts == 0 else "%.0f%%" % acc, 16, UIKit.STEEL if attempts > 0 else UIKit.STEEL_DARK, 500))
	row.add_child(acc_box)

	var total_box := UIKit.vbox(3)
	total_box.custom_minimum_size = Vector2(76, 0)
	total_box.alignment = BoxContainer.ALIGNMENT_CENTER
	total_box.add_child(UIKit.eyebrow("TOTAL", UIKit.STEEL_DARK))
	total_box.add_child(UIKit.inline_label("%d/%d" % [correct, attempts], 16, UIKit.TEXT, 500))
	row.add_child(total_box)
	return row


func _pips(level: int) -> String:
	var out := ""
	for i in range(3):
		out += "◆" if i < level else "◇"
		if i < 2:
			out += " "
	return out


func _roman(value: int) -> String:
	var values := ["I", "II", "III", "IV", "V", "VI"]
	return values[clampi(value - 1, 0, values.size() - 1)]
