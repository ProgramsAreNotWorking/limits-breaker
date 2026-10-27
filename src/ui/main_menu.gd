class_name MainMenuScreen
extends Control

const MediaManifest = preload("res://src/core/asset_manifest.gd")

signal go(target: String, payload: Variant)


func _ready() -> void:
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 56)
	margin.add_theme_constant_override("margin_right", 64)
	margin.add_theme_constant_override("margin_top", 34)
	margin.add_theme_constant_override("margin_bottom", 28)
	add_child(margin)

	var root := UIKit.vbox(0)
	margin.add_child(root)

	# Cabecera de contexto: pequeña, informativa, sin competir con el título.
	var top := UIKit.hbox(12)
	top.custom_minimum_size = Vector2(0, 24)
	root.add_child(top)
	var mark := UIKit.inline_label("◆", 12, UIKit.GOLD)
	top.add_child(mark)
	top.add_child(UIKit.eyebrow("Roguelike de combate matemático", UIKit.STEEL))
	var top_spacer := Control.new()
	top_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(top_spacer)
	top.add_child(UIKit.eyebrow("Sin conexión  ·  Iteración I", UIKit.STEEL_DARK))

	root.add_child(UIKit.spacer(8))
	var main := UIKit.hbox(34)
	main.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(main)

	# Columna editorial: identidad del juego + el héroe como figura completa.
	var left := UIKit.vbox(8)
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main.add_child(left)

	var logo_row := UIKit.hbox(14)
	left.add_child(logo_row)
	var logo_a := UIKit.display_label("LIMITS", 58, UIKit.GOLD, 600, 2)
	logo_a.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.7))
	logo_a.add_theme_constant_override("shadow_offset_x", 2)
	logo_a.add_theme_constant_override("shadow_offset_y", 3)
	logo_row.add_child(logo_a)
	var logo_b := UIKit.display_label("BREAKER", 58, UIKit.TEXT, 600, 2)
	logo_b.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.7))
	logo_b.add_theme_constant_override("shadow_offset_x", 2)
	logo_b.add_theme_constant_override("shadow_offset_y", 3)
	logo_row.add_child(logo_b)

	var subtitle := UIKit.label("El conocimiento es el arma. La muerte es solo otra iteración.", 18, UIKit.STEEL)
	left.add_child(subtitle)
	var accent_rule := UIKit.rule(UIKit.GOLD_SOFT, 2)
	accent_rule.custom_minimum_size = Vector2(84, 2)
	accent_rule.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	left.add_child(accent_rule)
	left.add_child(UIKit.spacer(4))

	var art_center := CenterContainer.new()
	art_center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	left.add_child(art_center)
	var hero_stage := Control.new()
	hero_stage.custom_minimum_size = Vector2(390, 352)
	art_center.add_child(hero_stage)
	var halo := UIKit.display_label("∞", 300, Color(UIKit.GOLD, 0.075), 600, 0)
	halo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	halo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	halo.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	halo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hero_stage.add_child(halo)
	var hero := UIKit.add_transparent_art(hero_stage, MediaManifest.character_art("player"), Vector2(390, 352))
	if hero != null:
		hero.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		hero.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

	var hero_caption := UIKit.hbox(8)
	hero_caption.alignment = BoxContainer.ALIGNMENT_CENTER
	left.add_child(hero_caption)
	hero_caption.add_child(UIKit.rule(UIKit.GOLD_SOFT, 1, 46))
	hero_caption.add_child(UIKit.eyebrow("El que rompe límites", UIKit.STEEL_DARK))
	hero_caption.add_child(UIKit.rule(UIKit.GOLD_SOFT, 1, 46))

	main.add_child(UIKit.vertical_rule(Color(UIKit.STONE, 0.65), 1))

	# Columna de decisiones: un solo panel, tres niveles de jerarquía.
	var menu_panel := UIKit.panel(Color(0.055, 0.065, 0.082, 0.88), Color("#394250"), true, UIKit.GOLD_SOFT)
	menu_panel.custom_minimum_size = Vector2(422, 0)
	menu_panel.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	main.add_child(menu_panel)
	var menu := UIKit.vbox(11)
	menu.add_theme_constant_override("separation", 11)
	menu_panel.add_child(menu)

	var menu_head := UIKit.vbox(3)
	menu.add_child(menu_head)
	menu_head.add_child(UIKit.eyebrow("Elegí tu camino", UIKit.GOLD))
	menu_head.add_child(UIKit.heading("El descenso", 28, UIKit.TEXT))
	menu_head.add_child(UIKit.label("Cada respuesta abre una puerta. Cada error deja una cicatriz.", 13, UIKit.MUTED))
	menu.add_child(UIKit.rule(Color(UIKit.STONE, 0.7), 1))

	var b_new := _menu_entry(menu, "Nueva run", "Descender desde el Encuentro I", UIKit.GOLD)
	b_new.pressed.connect(func() -> void:
		Game.start_run()
		Audio.play_sfx("confirm")
		go.emit("combat", null))

	var b_mast := _menu_entry(menu, "Registro de maestría", "El códice que sobrevive a la muerte", UIKit.BURGUNDY_HI)
	b_mast.pressed.connect(func() -> void:
		Audio.play_sfx("select")
		go.emit("mastery", null))

	var b_set := _menu_entry(menu, "Ajustes", "Audio, movimiento y accesibilidad", UIKit.STEEL_DARK)
	b_set.pressed.connect(func() -> void:
		Audio.play_sfx("select")
		go.emit("settings", null))

	var b_quit := _menu_entry(menu, "Salir", "Abandonar el pasillo por ahora", UIKit.STONE_HI)
	b_quit.pressed.connect(func() -> void: go.emit("quit", null))

	var total_attempts := 0
	var total_correct := 0
	for topic in MathEngine.TOPICS:
		var s := Game.topic_stats(topic)
		total_attempts += int(s.get("attempts", 0))
		total_correct += int(s.get("correct", 0))
	var acc := 0.0 if total_attempts == 0 else float(total_correct) / float(total_attempts) * 100.0

	menu.add_child(UIKit.spacer(3))
	var memory := UIKit.hbox(14)
	memory.alignment = BoxContainer.ALIGNMENT_CENTER
	menu.add_child(memory)
	memory.add_child(UIKit.eyebrow("MEMORIA", UIKit.STEEL_DARK))
	memory.add_child(UIKit.rule(Color(UIKit.STONE, 0.6), 1, 36))
	memory.add_child(UIKit.inline_label("%d problemas" % total_attempts, 12, UIKit.MUTED))
	memory.add_child(UIKit.inline_label("·", 12, UIKit.STEEL_DARK))
	memory.add_child(UIKit.inline_label("%d aciertos" % total_correct, 12, UIKit.MUTED))
	memory.add_child(UIKit.inline_label("·", 12, UIKit.STEEL_DARK))
	memory.add_child(UIKit.inline_label("%.1f%% precisión" % acc, 12, UIKit.GOLD if total_attempts > 0 else UIKit.STEEL_DARK))

	root.add_child(UIKit.spacer(8))
	var footer := UIKit.panel(Color(0.035, 0.043, 0.055, 0.78), Color(0.22, 0.27, 0.34, 0.75), false, UIKit.STEEL_DARK)
	footer.custom_minimum_size = Vector2(0, 50)
	root.add_child(footer)
	var footer_row := UIKit.hbox(18)
	footer_row.alignment = BoxContainer.ALIGNMENT_CENTER
	footer.add_child(footer_row)
	footer_row.add_child(UIKit.eyebrow("EL PASILLO RECUERDA", UIKit.GOLD_SOFT))
	footer_row.add_child(UIKit.vertical_rule(Color(UIKit.STONE, 0.7), 1))
	footer_row.add_child(UIKit.inline_label("La maestría persiste entre runs.", 13, UIKit.STEEL))
	var footer_spacer := Control.new()
	footer_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	footer_row.add_child(footer_spacer)
	footer_row.add_child(UIKit.keycap("ENTER  ELEGIR"))
	footer_row.add_child(UIKit.keycap("ESC  VOLVER"))
	footer_row.add_child(UIKit.inline_label("v0.1", 11, UIKit.STEEL_DARK))


func _menu_entry(parent: VBoxContainer, text: String, hint: String, accent: Color) -> Button:
	var wrap := UIKit.vbox(2)
	parent.add_child(wrap)
	var b := UIKit.button(text, accent)
	b.alignment = HORIZONTAL_ALIGNMENT_LEFT
	b.custom_minimum_size = Vector2(0, 50)
	b.add_theme_font_size_override("font_size", 17)
	wrap.add_child(b)
	var hint_label := UIKit.inline_label(hint, 12, UIKit.STEEL_DARK)
	hint_label.add_theme_constant_override("line_spacing", 0)
	var hint_style := StyleBoxEmpty.new()
	hint_style.content_margin_left = 22
	hint_label.add_theme_stylebox_override("normal", hint_style)
	wrap.add_child(hint_label)
	return b
