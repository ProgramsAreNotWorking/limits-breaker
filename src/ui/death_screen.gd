class_name DeathScreen
extends Control

signal go(target: String, payload: Variant)


func _ready() -> void:
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 46)
	margin.add_theme_constant_override("margin_right", 46)
	margin.add_theme_constant_override("margin_top", 30)
	margin.add_theme_constant_override("margin_bottom", 28)
	add_child(margin)

	var center := CenterContainer.new()
	margin.add_child(center)
	var root := UIKit.vbox(8)
	root.custom_minimum_size = Vector2(880, 0)
	center.add_child(root)

	var eyebrow := UIKit.eyebrow("La run ha terminado", UIKit.BURGUNDY_HI)
	eyebrow.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(eyebrow)
	var t := UIKit.title("HAS CAÍDO", 54, UIKit.BURGUNDY_HI)
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(t)
	var sub := UIKit.label("La run termina. Lo aprendido no.", 17, UIKit.MUTED)
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(sub)

	var fallen := CenterContainer.new()
	fallen.custom_minimum_size = Vector2(0, 122)
	root.add_child(fallen)
	UIKit.add_portrait(fallen, "player", Vector2(116, 116))

	var stats: Dictionary = Game.run.get("stats", {})
	var furthest := int(stats.get("furthest", Game.run.get("encounter", 1)))
	var enemies := int(stats.get("enemies", 0))
	var attempts := int(stats.get("problems", 0))
	var solved := int(stats.get("solved", 0))
	var acc := 0.0 if attempts == 0 else float(solved) / float(attempts) * 100.0

	var tiles := UIKit.hbox(9)
	root.add_child(tiles)
	tiles.add_child(UIKit.stat_tile("ENCUENTRO", _roman(furthest), UIKit.BURGUNDY_HI, 150))
	tiles.add_child(UIKit.stat_tile("ENEMIGOS", str(enemies), UIKit.STEEL, 150))
	tiles.add_child(UIKit.stat_tile("PROBLEMAS", "%d/%d" % [solved, attempts], UIKit.STEEL, 150))
	tiles.add_child(UIKit.stat_tile("PRECISIÓN", "—" if attempts == 0 else "%.0f%%" % acc, UIKit.GOLD, 150))

	var panel := UIKit.panel(Color(0.055, 0.065, 0.082, 0.94), Color("#3a3038"), true, UIKit.BURGUNDY)
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(panel)
	var details := UIKit.vbox(6)
	panel.add_child(details)

	var detail_head := UIKit.hbox(10)
	details.add_child(detail_head)
	detail_head.add_child(UIKit.eyebrow("Resumen de la run", UIKit.BURGUNDY_HI))
	detail_head.add_child(UIKit.rule(Color(UIKit.STONE, 0.7), 1))
	details.add_child(UIKit.label("El pasillo conserva lo que aprendiste. La run, no.", 13, UIKit.MUTED))
	var reached_world := Combat.world_for_encounter(furthest)
	details.add_child(UIKit.label("Mundo alcanzado: %s. %s" % [
		String(reached_world.get("name", "La Cripta")),
		String(reached_world.get("subtitle", "")),
	], 12, UIKit.STEEL))

	var by_topic: Dictionary = stats.get("by_topic", {})
	if not by_topic.is_empty():
		var topic_parts: PackedStringArray = []
		for topic in by_topic.keys():
			var d: Dictionary = by_topic[topic]
			var a := int(d.get("attempts", 0))
			var c := int(d.get("correct", 0))
			var pct := 0.0 if a == 0 else float(c) / float(a) * 100.0
			topic_parts.append("%s %d/%d (%.0f%%)" % [String(MathEngine.TOPIC_LABELS.get(topic, topic)), c, a, pct])
		var topic_line := UIKit.label(" · ".join(topic_parts), 12, UIKit.MUTED)
		details.add_child(topic_line)

	var need: Array = stats.get("topics_need_practice", [])
	if not need.is_empty():
		var names: PackedStringArray = []
		for t2 in need:
			names.append(String(MathEngine.TOPIC_LABELS.get(t2, t2)))
		details.add_child(UIKit.label("Para practicar: " + ", ".join(names), 13, UIKit.GOLD))

	var loot: Array = stats.get("loot", [])
	if not loot.is_empty():
		var names2: PackedStringArray = []
		for id in loot:
			names2.append(String(Combat.item(id).get("name", id)))
		details.add_child(UIKit.label("Equipo obtenido: " + ", ".join(names2), 12, UIKit.STEEL))

	if by_topic.is_empty() and need.is_empty() and loot.is_empty():
		details.add_child(UIKit.label("No hubo botín ni temas registrados en esta incursión.", 12, UIKit.STEEL_DARK))

	var row := UIKit.hbox(12)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	root.add_child(row)
	var again := UIKit.button("Nueva run", UIKit.BURGUNDY)
	again.custom_minimum_size = Vector2(210, 48)
	again.pressed.connect(func() -> void:
		Game.start_run()
		Audio.play_music("combat")
		go.emit("combat", null))
	row.add_child(again)
	var menu := UIKit.button("Menú", UIKit.STEEL_DARK)
	menu.custom_minimum_size = Vector2(150, 48)
	menu.pressed.connect(func() -> void:
		Audio.play_music("menu")
		go.emit("menu", null))
	row.add_child(menu)


func _roman(value: int) -> String:
	var values := ["I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X", "XI", "XII"]
	return values[clampi(value - 1, 0, values.size() - 1)]
