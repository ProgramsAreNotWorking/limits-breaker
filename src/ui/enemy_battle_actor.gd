class_name EnemyBattleActor
extends Button
## Enemigo seleccionable representado sobre el escenario del combate.

const MediaManifest = preload("res://src/core/asset_manifest.gd")

var enemy_index := -1
var enemy_data: Dictionary = {}
var current_hp := 1
var maximum_hp := 1
var art_size := Vector2(170, 210)
var incoming_intent := ""
var incoming_intent_color := UIKit.STEEL
var status_text := ""
var status_color := UIKit.STEEL
var selected_for_action := false

var portrait: FantasyPortrait
var glow_texture: GradientTexture2D
var _glow_accent := Color.TRANSPARENT
var health_bar: ProgressBar
var health_label: Label
var name_label: Label
var intent_label: Label
var status_label: Label


func configure(index: int, data: Dictionary, hp: int, max_hp: int, intent: String, selected: bool, portrait_size: Vector2 = Vector2(170, 210), intent_color: Color = UIKit.STEEL, effects: String = "", effects_color: Color = UIKit.STEEL) -> void:
	enemy_index = index
	enemy_data = data
	current_hp = hp
	maximum_hp = maxi(1, max_hp)
	art_size = portrait_size
	incoming_intent = intent
	incoming_intent_color = intent_color
	status_text = effects
	status_color = effects_color
	selected_for_action = selected
	if is_inside_tree() and portrait == null:
		_build_view()
	if portrait != null:
		portrait.custom_minimum_size = art_size
		_refresh_view()


func _ready() -> void:
	flat = true
	focus_mode = Control.FOCUS_ALL
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_build_view()
	_refresh_view()


func set_selected_for_action(value: bool) -> void:
	selected_for_action = value
	_refresh_style()
	queue_redraw()


func set_targetable(value: bool) -> void:
	disabled = current_hp <= 0
	mouse_filter = Control.MOUSE_FILTER_STOP if value and current_hp > 0 else Control.MOUSE_FILTER_IGNORE


func play_effect(effect: String) -> void:
	if portrait != null:
		portrait.play_effect(effect)


func play_lunge() -> void:
	if portrait != null:
		portrait.play_lunge()


func _build_view() -> void:
	if portrait != null:
		return
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 2)
	margin.add_theme_constant_override("margin_right", 2)
	margin.add_theme_constant_override("margin_top", 1)
	margin.add_theme_constant_override("margin_bottom", 1)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(margin)
	var stack := UIKit.vbox(1)
	stack.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_child(stack)
	var health_center := CenterContainer.new()
	health_center.custom_minimum_size = Vector2(0, 15)
	health_center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	health_center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stack.add_child(health_center)
	var health_row := UIKit.hbox(5)
	health_row.custom_minimum_size = Vector2(minf(art_size.x * 0.72, 220.0), 15)
	health_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	health_center.add_child(health_row)
	health_label = UIKit.inline_label("", 9, UIKit.STEEL)
	health_label.custom_minimum_size = Vector2(36, 0)
	health_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	health_row.add_child(health_label)
	health_bar = UIKit.bar(1, 1, UIKit.DANGER, 5)
	health_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	health_bar.custom_minimum_size = Vector2(0, 7)
	health_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	health_row.add_child(health_bar)
	var art_center := CenterContainer.new()
	art_center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	art_center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	art_center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stack.add_child(art_center)
	var enemy_id := String(enemy_data.get("id", "skeleton"))
	var portrait_id := MediaManifest.enemy(enemy_id)
	portrait = UIKit.add_portrait(art_center, portrait_id if portrait_id != "" else "skeleton", art_size)
	portrait.set_free_standing(true)
	portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	name_label = UIKit.inline_label("", 14, UIKit.TEXT, 600)
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stack.add_child(name_label)
	intent_label = UIKit.inline_label("", 10, UIKit.STEEL)
	intent_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	intent_label.clip_text = true
	intent_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	intent_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stack.add_child(intent_label)
	status_label = UIKit.inline_label("", 9, UIKit.STEEL, 600)
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_label.clip_text = true
	status_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	status_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stack.add_child(status_label)
	_refresh_style()


func _refresh_view() -> void:
	if health_bar == null or portrait == null:
		return
	var is_boss := String(enemy_data.get("tier", "")) == "boss"
	health_bar.visible = not is_boss
	health_label.visible = not is_boss
	health_bar.max_value = maximum_hp
	health_bar.value = clampf(float(current_hp), 0.0, float(maximum_hp))
	health_bar.add_theme_stylebox_override("fill", UIKit.flat(UIKit.DANGER, Color.TRANSPARENT, 3))
	health_label.text = "%d/%d" % [maxi(0, current_hp), maximum_hp]
	name_label.text = String(enemy_data.get("name", "Enemigo"))
	intent_label.text = incoming_intent
	if status_label != null:
		status_label.text = status_text
		status_label.visible = status_text != ""
		status_label.add_theme_color_override("font_color", status_color)
	name_label.add_theme_color_override("font_color", Color("#f0d28b") if selected_for_action else UIKit.TEXT)
	var intent_color := incoming_intent_color
	if selected_for_action:
		intent_color = intent_color.lightened(0.12)
	if current_hp <= 0:
		intent_color = UIKit.STEEL_DARK
	intent_label.add_theme_color_override("font_color", intent_color)
	var enemy_id := String(enemy_data.get("id", "skeleton"))
	var portrait_id := MediaManifest.enemy(enemy_id)
	portrait.configure(portrait_id if portrait_id != "" else "skeleton")
	var tint := String(enemy_data.get("tint", ""))
	var has_dedicated_art := portrait_id == enemy_id
	portrait.modulate = Color.WHITE
	if not has_dedicated_art and tint != "":
		portrait.modulate = Color(tint)
	var accent := _enemy_accent()
	_set_glow_texture(accent)
	disabled = current_hp <= 0
	modulate = Color(0.42, 0.42, 0.46, 0.7) if disabled else Color.WHITE
	_refresh_style()
	queue_redraw()


func _refresh_style() -> void:
	add_theme_stylebox_override("normal", _stylebox(Color.TRANSPARENT, Color.TRANSPARENT, 0))
	add_theme_stylebox_override("hover", _stylebox(Color(0.72, 0.57, 0.28, 0.06), Color.TRANSPARENT, 0))
	add_theme_stylebox_override("pressed", _stylebox(Color(0.86, 0.66, 0.28, 0.1), Color.TRANSPARENT, 0))
	add_theme_stylebox_override("focus", _stylebox(Color.TRANSPARENT, Color.TRANSPARENT, 0))


func _draw() -> void:
	if size.x <= 0.0 or size.y <= 0.0:
		return
	var accent := _enemy_accent()
	if not disabled:
		var halo_center := Vector2(size.x * 0.5, size.y * 0.48)
		var halo_scale := Vector2(minf(size.x * 0.44, art_size.x * 0.55), minf(size.y * 0.42, art_size.y * 0.48))
		if glow_texture != null:
			var halo_size := halo_scale * 2.0
			draw_texture_rect(glow_texture, Rect2(halo_center - halo_size * 0.5, halo_size), false)
	var ground := Vector2(size.x * 0.5, size.y - 28.0)
	var radius_x := minf(size.x * 0.28, 92.0)
	draw_set_transform(ground, 0.0, Vector2(radius_x, 9.0))
	var shadow := Color(0.012, 0.016, 0.023, 0.72)
	if selected_for_action:
		shadow = Color(0.61, 0.39, 0.15, 0.38)
	draw_circle(Vector2.ZERO, 1.18, Color(accent.r, accent.g, accent.b, 0.09))
	draw_arc(Vector2.ZERO, 1.12, 0.0, TAU, 48, Color(accent.r, accent.g, accent.b, 0.16), 0.03, true)
	draw_circle(Vector2.ZERO, 1.0, shadow)
	if selected_for_action and current_hp > 0:
		draw_arc(Vector2.ZERO, 1.08, 0.0, TAU, 48, Color("#e7be68"), 0.09, true)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _enemy_accent() -> Color:
	var tint := String(enemy_data.get("tint", ""))
	if tint != "":
		return Color(tint)
	match String(enemy_data.get("id", "")):
		"skeleton", "colossus":
			return Color("#d6c59c")
		"brigand":
			return Color("#d17a63")
		"warden":
			return Color("#89b7c9")
		"cultist":
			return Color("#d45b70")
		"limitless":
			return Color("#a88af1")
	match String(enemy_data.get("tier", "")):
		"weak":
			return Color("#9ebd78")
		"ordinary":
			return Color("#91a9c7")
		"strong":
			return Color("#e0a064")
		"elite":
			return Color("#df6179")
		"miniboss":
			return Color("#a88af1")
		_:
			return Color("#cb637c")


func _set_glow_texture(accent: Color) -> void:
	if glow_texture != null and _glow_accent == accent:
		return
	_glow_accent = accent
	var gradient := Gradient.new()
	gradient.offsets = PackedFloat32Array([0.0, 0.46, 1.0])
	gradient.colors = PackedColorArray([
		Color(accent.r, accent.g, accent.b, 0.18),
		Color(accent.r, accent.g, accent.b, 0.09),
		Color(accent.r, accent.g, accent.b, 0.0),
	])
	glow_texture = GradientTexture2D.new()
	glow_texture.width = 256
	glow_texture.height = 256
	glow_texture.fill = GradientTexture2D.FILL_RADIAL
	glow_texture.fill_from = Vector2(0.5, 0.5)
	glow_texture.fill_to = Vector2(1.0, 0.5)
	glow_texture.gradient = gradient


func _stylebox(background: Color, border: Color, width: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = background
	style.border_color = border
	style.set_border_width_all(width)
	style.set_corner_radius_all(6)
	style.content_margin_left = 3.0
	style.content_margin_right = 3.0
	style.content_margin_top = 3.0
	style.content_margin_bottom = 3.0
	return style
