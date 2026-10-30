class_name VictoryScreen
extends Control
## Cierre de la primera expedición al derrotar al jefe del décimo encuentro.

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

	var eyebrow := UIKit.eyebrow("El pasillo se inclina", UIKit.GOLD)
	eyebrow.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(eyebrow)
	var t := UIKit.title("EL LÍMITE SE HA ROTO", 46, UIKit.GOLD)
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(t)
	var sub := UIKit.label("Limitless cae. Por primera vez, el pasillo termina.", 17, UIKit.TEXT)
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(sub)

	var fallen := CenterContainer.new()
	fallen.custom_minimum_size = Vector2(0, 118)
	root.add_child(fallen)
	UIKit.add_portrait(fallen, "limitless", Vector2(112, 112))

	var stats: Dictionary = Game.run.get("stats", {})
	var attempts := int(stats.get("problems", 0))
	var solved := int(stats.get("solved", 0))
	var enemies := int(stats.get("enemies", 0))
	var furthest := maxi(10, int(stats.get("furthest", 10)))
	var accuracy := 0.0 if attempts == 0 else float(solved) / float(attempts) * 100.0
	var tiles := UIKit.hbox(9)
	root.add_child(tiles)
	tiles.add_child(UIKit.stat_tile("ENCUENTRO", _roman(furthest), UIKit.GOLD, 150))
	tiles.add_child(UIKit.stat_tile("ENEMIGOS", str(enemies), UIKit.STEEL, 150))
	tiles.add_child(UIKit.stat_tile("RESUELTOS", "%d/%d" % [solved, attempts], UIKit.STEEL, 150))
	tiles.add_child(UIKit.stat_tile("PRECISIÓN", "—" if attempts == 0 else "%.0f%%" % accuracy, UIKit.GOLD, 150))

	var panel := UIKit.panel(Color(0.058, 0.065, 0.078, 0.94), Color("#4a402d"), true, UIKit.GOLD)
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(panel)
	var details := UIKit.vbox(6)
	panel.add_child(details)
	var detail_head := UIKit.hbox(10)
	details.add_child(detail_head)
	detail_head.add_child(UIKit.eyebrow("Expedición completada", UIKit.GOLD))
	detail_head.add_child(UIKit.rule(Color(UIKit.STONE, 0.7), 1))
	details.add_child(UIKit.label("El registro de maestría se conserva entre expediciones.", 13, UIKit.MUTED))
	details.add_child(UIKit.label("Jefe derrotado en el encuentro %d." % furthest, 14, UIKit.TEXT))
	var crossed: PackedStringArray = []
	for world in Combat.WORLDS:
		if int(world.get("index", 0)) < 4:
			crossed.append(String(world.get("name", "")))
	details.add_child(UIKit.label("Umbrales cruzados: " + ", ".join(crossed) + ".", 12, UIKit.STEEL))

	var need: Array = stats.get("topics_need_practice", [])
	if not need.is_empty():
		var names: PackedStringArray = []
		for topic in need:
			names.append(String(MathEngine.TOPIC_LABELS.get(topic, topic)))
		details.add_child(UIKit.label("Temas para practicar: " + ", ".join(names), 13, UIKit.GOLD))

	var row := UIKit.hbox(12)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	root.add_child(row)
	var again := UIKit.button("Nueva expedición", UIKit.GOLD_SOFT)
	again.custom_minimum_size = Vector2(230, 48)
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
