class_name SettingsScreen
extends Control

signal go(target: String, payload: Variant)


func _ready() -> void:
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 56)
	margin.add_theme_constant_override("margin_right", 56)
	margin.add_theme_constant_override("margin_top", 42)
	margin.add_theme_constant_override("margin_bottom", 38)
	add_child(margin)

	var root := UIKit.hbox(34)
	root.size_flags_vertical = Control.SIZE_EXPAND_FILL
	margin.add_child(root)

	# Columna izquierda: contexto y compromiso visual.
	var aside := UIKit.vbox(12)
	aside.custom_minimum_size = Vector2(292, 0)
	aside.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(aside)
	aside.add_child(UIKit.eyebrow("Configuración del pasillo", UIKit.GOLD))
	aside.add_child(UIKit.title("AJUSTES", 42, UIKit.TEXT))
	aside.add_child(UIKit.label("Ajustá el tono del descenso. La dificultad no se negocia desde acá.", 15, UIKit.MUTED))
	aside.add_child(UIKit.rule(UIKit.GOLD_SOFT, 2))
	aside.add_child(UIKit.spacer(12))
	aside.add_child(_info_line("Audio", "Sintetizado en tiempo real"))
	aside.add_child(_info_line("Progreso", "Se guarda en este dispositivo"))
	aside.add_child(_info_line("Entrada", "Teclado físico, sin teclado en pantalla"))
	var aside_spacer := Control.new()
	aside_spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	aside.add_child(aside_spacer)
	aside.add_child(UIKit.eyebrow("El enemigo marca el reloj. Resolver no tiene cronómetro.", UIKit.STEEL_DARK))

	# Columna derecha: formulario legible y sin marcos estirados.
	var content := UIKit.vbox(14)
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(content)

	var head := UIKit.hbox(12)
	content.add_child(head)
	var head_copy := UIKit.vbox(2)
	head_copy.custom_minimum_size = Vector2(260, 0)
	head.add_child(head_copy)
	head_copy.add_child(UIKit.eyebrow("Preferencias", UIKit.STEEL))
	head_copy.add_child(UIKit.inline_label("Audio, gráficos y accesibilidad", 16, UIKit.TEXT, 500))
	var head_spacer := Control.new()
	head_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(head_spacer)
	var back := UIKit.button("Volver", UIKit.STEEL_DARK)
	back.custom_minimum_size = Vector2(132, 44)
	back.pressed.connect(func() -> void:
		Audio.play_sfx("select")
		go.emit("menu", null))
	head.add_child(back)

	var panel := UIKit.panel(Color(0.06, 0.071, 0.09, 0.93), Color("#3a4350"), true, UIKit.GOLD_SOFT)
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_child(panel)
	var form_scroll := ScrollContainer.new()
	form_scroll.custom_minimum_size = Vector2(0, 180)
	form_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	form_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	form_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	form_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	panel.add_child(form_scroll)
	var form := UIKit.vbox(0)
	form.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	form.add_theme_constant_override("separation", 7)
	form_scroll.add_child(form)

	form.add_child(_slider_row(
		"Volumen de música",
		"El tema del pasillo y sus variaciones.",
		0.0, 1.0, 0.01, float(Game.settings.get("music", 0.65)), "percent",
		func(val: float) -> void:
			Game.settings["music"] = val
			Audio.apply_volumes()
	))
	form.add_child(UIKit.rule(Color(UIKit.STONE, 0.7), 1))
	form.add_child(_slider_row(
		"Volumen de efectos",
		"Golpes, respuestas y el sonido de la fragua.",
		0.0, 1.0, 0.01, float(Game.settings.get("sfx", 0.85)), "percent",
		func(val: float) -> void:
			Game.settings["sfx"] = val
			Audio.apply_volumes()
	))
	form.add_child(UIKit.rule(Color(UIKit.STONE, 0.7), 1))
	form.add_child(UIKit.eyebrow("Gráficos", UIKit.GOLD_SOFT))

	var resolution_selector := _option_button()
	var resolutions := Game.available_window_resolutions()
	var selected_resolution := String(Game.settings.get("resolution", "1280x720"))
	if not resolutions.has(selected_resolution):
		selected_resolution = resolutions[resolutions.size() - 1]
		Game.settings["resolution"] = selected_resolution
		Game.apply_display_settings()
	var selected_resolution_index := 0
	var resolution_index := 0
	for resolution in resolutions:
		resolution_selector.add_item(resolution.replace("x", " × "))
		resolution_selector.set_item_metadata(resolution_index, resolution)
		if resolution == selected_resolution:
			selected_resolution_index = resolution_index
		resolution_index += 1
	resolution_selector.select(selected_resolution_index)
	resolution_selector.item_selected.connect(func(index: int) -> void:
		Game.settings["resolution"] = String(resolution_selector.get_item_metadata(index))
		Game.apply_display_settings()
		Game.save_game())
	form.add_child(_option_row(
		"Resolución de ventana",
		"Tamaño de ventana. En pantalla completa se usa la resolución del monitor.",
		resolution_selector
	))

	var screen_mode_selector := _option_button()
	screen_mode_selector.add_item("Ventana")
	screen_mode_selector.set_item_metadata(0, "windowed")
	screen_mode_selector.add_item("Pantalla completa")
	screen_mode_selector.set_item_metadata(1, "fullscreen")
	var selected_screen_mode := String(Game.settings.get("screen_mode", "windowed"))
	screen_mode_selector.select(1 if selected_screen_mode == "fullscreen" else 0)
	resolution_selector.disabled = selected_screen_mode == "fullscreen"
	screen_mode_selector.item_selected.connect(func(index: int) -> void:
		var screen_mode := String(screen_mode_selector.get_item_metadata(index))
		Game.settings["screen_mode"] = screen_mode
		resolution_selector.disabled = screen_mode == "fullscreen"
		Game.apply_display_settings()
		Game.save_game())
	form.add_child(_option_row(
		"Modo de pantalla",
		"Elegí jugar en una ventana o usar toda la pantalla.",
		screen_mode_selector
	))
	if Engine.is_embedded_in_editor():
		form.add_child(UIKit.label(
			"Godot controla el tamaño y el modo de esta vista. La preferencia guardada se aplicará al ejecutar el juego en una ventana independiente.",
			12,
			UIKit.STEEL_DARK
		))
	form.add_child(UIKit.rule(Color(UIKit.STONE, 0.7), 1))

	var motion_row := UIKit.vbox(4)
	form.add_child(motion_row)
	motion_row.add_child(UIKit.eyebrow("Accesibilidad", UIKit.STEEL_DARK))
	var motion := UIKit.button("Reducir movimiento: %s" % ("Sí" if bool(Game.settings.get("reduced_motion", false)) else "No"), UIKit.GOLD_SOFT)
	motion.toggle_mode = true
	motion.button_pressed = bool(Game.settings.get("reduced_motion", false))
	motion.alignment = HORIZONTAL_ALIGNMENT_LEFT
	motion.custom_minimum_size = Vector2(300, 46)
	motion.add_theme_font_size_override("font_size", 15)
	motion.toggled.connect(func(on: bool) -> void:
		Game.settings["reduced_motion"] = on
		motion.text = "Reducir movimiento: %s" % ("Sí" if on else "No")
		Game.save_game())
	motion_row.add_child(motion)
	motion_row.add_child(UIKit.label("Desactiva pulsos, partículas de interfaz y movimientos de cámara.", 12, UIKit.STEEL_DARK))

	var footer := UIKit.hbox(12)
	content.add_child(footer)
	footer.add_child(UIKit.inline_label("Los cambios se guardan en este dispositivo.", 12, UIKit.STEEL_DARK))
	var footer_spacer := Control.new()
	footer_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	footer.add_child(footer_spacer)
	var save := UIKit.button("Guardar ajustes", UIKit.GOLD_SOFT)
	save.custom_minimum_size = Vector2(210, 46)
	save.pressed.connect(func() -> void:
		Game.save_game()
		Audio.play_sfx("confirm")
		save.text = "Guardado ✓")
	footer.add_child(save)


func _info_line(caption: String, detail: String) -> Control:
	var row := UIKit.vbox(2)
	row.add_child(UIKit.eyebrow(caption, UIKit.GOLD_SOFT))
	row.add_child(UIKit.label(detail, 13, UIKit.STEEL))
	return row


func _option_row(caption: String, hint: String, option: OptionButton) -> Control:
	var box := UIKit.vbox(4)
	var row := UIKit.hbox(12)
	var copy := UIKit.vbox(3)
	copy.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var title := UIKit.inline_label(caption, 14, UIKit.TEXT, 500)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	copy.add_child(title)
	var detail := UIKit.label(hint, 11, UIKit.STEEL_DARK)
	detail.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	copy.add_child(detail)
	row.add_child(copy)
	option.size_flags_horizontal = Control.SIZE_SHRINK_END
	row.add_child(option)
	box.add_child(row)
	return box


func _option_button() -> OptionButton:
	var option := OptionButton.new()
	option.custom_minimum_size = Vector2(224, 46)
	option.focus_mode = Control.FOCUS_ALL
	option.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	option.add_theme_font_override("font", UIKit.body_font(600))
	option.add_theme_font_size_override("font_size", 14)
	option.add_theme_color_override("font_color", UIKit.TEXT)
	option.add_theme_color_override("font_hover_color", Color.WHITE)
	option.add_theme_color_override("font_pressed_color", UIKit.TEXT)
	option.add_theme_color_override("font_disabled_color", Color(0.68, 0.71, 0.76, 0.42))
	option.add_theme_stylebox_override("normal", UIKit._button_style(UIKit.GOLD_SOFT, 0))
	option.add_theme_stylebox_override("hover", UIKit._button_style(UIKit.GOLD_SOFT, 1))
	option.add_theme_stylebox_override("pressed", UIKit._button_style(UIKit.GOLD_SOFT, 2))
	option.add_theme_stylebox_override("disabled", UIKit._button_style(UIKit.STEEL_DARK, 3))
	var focus := UIKit.flat(Color(0.0, 0.0, 0.0, 0.0), UIKit.GOLD, 5)
	focus.set_border_width_all(1)
	focus.set_expand_margin_all(2)
	focus.content_margin_left = 0
	focus.content_margin_right = 0
	focus.content_margin_top = 0
	focus.content_margin_bottom = 0
	option.add_theme_stylebox_override("focus", focus)
	var popup := option.get_popup()
	popup.add_theme_font_override("font", UIKit.body_font(500))
	popup.add_theme_font_size_override("font_size", 14)
	popup.add_theme_color_override("font_color", UIKit.TEXT)
	popup.add_theme_color_override("font_hover_color", Color.WHITE)
	popup.add_theme_stylebox_override("panel", UIKit.flat(Color("#12151b"), Color("#3a4350"), 6))
	popup.add_theme_stylebox_override("hover", UIKit.flat(Color("#2a303a"), UIKit.GOLD_SOFT, 4))
	return option


func _slider_row(caption: String, hint: String, minv: float, maxv: float, step: float, value: float, format: String, on_change: Callable) -> Control:
	var box := UIKit.vbox(3)
	box.add_theme_constant_override("separation", 4)
	box.add_child(UIKit.spacer(2))
	var head := UIKit.hbox(10)
	box.add_child(head)
	var title := UIKit.inline_label(caption, 16, UIKit.TEXT, 500)
	title.custom_minimum_size = Vector2(230, 0)
	head.add_child(title)
	var filler := Control.new()
	filler.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(filler)
	var value_badge := UIKit.badge(_format_value(value, format), UIKit.GOLD, 11)
	head.add_child(value_badge)
	var s := UIKit.slider(minv, maxv, step, value)
	box.add_child(s)
	var hint_label := UIKit.label(hint, 12, UIKit.STEEL_DARK)
	box.add_child(hint_label)
	box.add_child(UIKit.spacer(2))
	s.value_changed.connect(func(val: float) -> void:
		var badge_label := value_badge.get_child(0) as Label
		if badge_label != null:
			badge_label.text = _format_value(val, format)
		on_change.call(val))
	return box


func _format_value(value: float, format: String) -> String:
	if format == "percent":
		return "%d%%" % int(round(value * 100.0))
	return "%.2f" % value
