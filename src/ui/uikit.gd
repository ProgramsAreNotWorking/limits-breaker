class_name UIKit
extends RefCounted

# --- Paleta: piedra, tinta, latón gastado y vitela. ---
const BG := Color("#0b0d10")
const BG_DEEP := Color("#07080a")
const PANEL := Color("#12151b")
const PANEL_HI := Color("#1a1f27")
const PANEL_SOFT := Color("#171b22")
const STONE := Color("#2a303a")
const STONE_HI := Color("#3d4653")
const STEEL := Color("#a3adbb")
const STEEL_DARK := Color("#687283")
const BURGUNDY := Color("#8f3043")
const BURGUNDY_HI := Color("#c34d64")
const VIOLET := Color("#8c78d6")
const VIOLET_SOFT := Color("#6657a4")
const GOLD := Color("#d8ad60")
const GOLD_SOFT := Color("#8d713c")
const TEXT := Color("#f2ede3")
const MUTED := Color("#99a2af")
const INK := Color("#090b0e")
const DANGER := Color("#db5c55")
const OK := Color("#76b887")

const DIFF_NAMES := ["Fácil", "Intermedio", "Avanzado", "Superdifícil"]
const DIFF_COLORS := [Color("#6eae7b"), Color("#6f9ec8"), Color("#d0a15f"), Color("#c25b71")]
const PortraitPainter := preload("res://src/ui/fantasy_portrait.gd")
const ItemIconPainter := preload("res://src/ui/equipment_icon.gd")
const FramePanel := preload("res://src/ui/ui_frame.gd")

const DISPLAY_FONT_PATH := "res://assets/fonts/Cinzel.ttf"
const BODY_FONT_PATH := "res://assets/fonts/Inter.ttf"
const MATH_FONT_PATH := "res://assets/fonts/STIXTwoMath-Regular.ttf"

static var _font_cache: Dictionary = {}
static var _grabber_cache: Dictionary = {}


# ----------------------------------------------------------------- tipografía
static func font() -> Font:
	return body_font(400)


static func body_font(weight: int = 400) -> Font:
	return _variation(BODY_FONT_PATH, weight, 0.0)


static func display_font(weight: int = 600, tracking: float = 1.0) -> Font:
	return _variation(DISPLAY_FONT_PATH, weight, tracking)


static func math_font() -> Font:
	if not _font_cache.has("math"):
		_font_cache["math"] = load(MATH_FONT_PATH) as FontFile
	return _font_cache["math"]


static func _variation(path: String, weight: int, tracking: float) -> Font:
	var key := "%s|%d|%.2f" % [path, weight, tracking]
	if _font_cache.has(key):
		return _font_cache[key]
	var base := load(path) as FontFile
	if base == null:
		return ThemeDB.fallback_font
	var variation := FontVariation.new()
	variation.base_font = base
	variation.variation_opentype = { &"wght": float(weight) }
	variation.spacing_glyph = int(round(tracking))
	_font_cache[key] = variation
	return variation


static func label(text: String, size: int = 16, color: Color = TEXT, weight: int = 400) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_override("font", body_font(weight))
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	l.add_theme_constant_override("line_spacing", 4)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return l


static func inline_label(text: String, size: int = 16, color: Color = TEXT, weight: int = 400) -> Label:
	var l := label(text, size, color, weight)
	l.autowrap_mode = TextServer.AUTOWRAP_OFF
	return l


static func display_label(text: String, size: int = 32, color: Color = TEXT, weight: int = 600, tracking: int = 1) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_override("font", display_font(weight, tracking))
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	l.add_theme_constant_override("line_spacing", 4)
	l.autowrap_mode = TextServer.AUTOWRAP_OFF
	return l


static func title(text: String, size: int = 42, color: Color = TEXT) -> Label:
	var l := display_label(text, size, color, 600, 2)
	l.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.55))
	l.add_theme_constant_override("shadow_offset_x", 2)
	l.add_theme_constant_override("shadow_offset_y", 2)
	return l


static func heading(text: String, size: int = 28, color: Color = TEXT) -> Label:
	return display_label(text, size, color, 600, 1)


static func eyebrow(text: String, color: Color = MUTED) -> Label:
	var l := inline_label(text.to_upper(), 11, color, 600)
	l.add_theme_font_override("font", body_font(650))
	l.add_theme_color_override("font_color", color)
	l.add_theme_constant_override("outline_size", 0)
	return l


static func math_label(text: String, size: int = 34, color: Color = TEXT) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_override("font", math_font())
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.autowrap_mode = TextServer.AUTOWRAP_OFF
	return l


# --------------------------------------------------------------------- formas
static func flat(bg: Color, border: Color = Color.TRANSPARENT, radius: int = 5) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.border_color = border
	s.set_border_width_all(2 if border.a > 0.0 else 0)
	s.set_corner_radius_all(radius)
	s.content_margin_left = 16
	s.content_margin_right = 16
	s.content_margin_top = 12
	s.content_margin_bottom = 12
	return s


static func panel(bg: Color = PANEL, border: Color = STONE, framed: bool = true, accent: Color = GOLD_SOFT) -> PanelContainer:
	var p := FramePanel.new() as PanelContainer
	var panel_style := flat(bg, border, 4)
	panel_style.shadow_color = Color(0.0, 0.0, 0.0, 0.42)
	panel_style.shadow_size = 12
	panel_style.shadow_offset = Vector2(0, 6)
	p.add_theme_stylebox_override("panel", panel_style)
	p.set("ornaments", framed)
	p.call("set_accent", accent)
	return p


static func button(text: String, accent: Color = BURGUNDY) -> Button:
	var b := Button.new()
	b.text = text
	b.focus_mode = Control.FOCUS_ALL
	b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	b.add_theme_font_override("font", body_font(600))
	b.add_theme_font_size_override("font_size", 16)
	b.add_theme_color_override("font_color", TEXT)
	b.add_theme_color_override("font_hover_color", Color.WHITE)
	b.add_theme_color_override("font_pressed_color", TEXT)
	b.add_theme_color_override("font_focus_color", Color.WHITE)
	b.add_theme_color_override("font_disabled_color", Color(0.68, 0.71, 0.76, 0.42))
	b.add_theme_stylebox_override("normal", _button_style(accent, 0))
	b.add_theme_stylebox_override("hover", _button_style(accent, 1))
	b.add_theme_stylebox_override("pressed", _button_style(accent, 2))
	b.add_theme_stylebox_override("disabled", _button_style(STEEL_DARK, 3))
	var focus := flat(Color(0.0, 0.0, 0.0, 0.0), GOLD, 5)
	focus.set_border_width_all(1)
	focus.set_expand_margin_all(2)
	focus.content_margin_left = 0
	focus.content_margin_right = 0
	focus.content_margin_top = 0
	focus.content_margin_bottom = 0
	b.add_theme_stylebox_override("focus", focus)
	b.custom_minimum_size = Vector2(0, 46)
	return b


static func _button_style(accent: Color, state: int) -> StyleBoxFlat:
	var bg := Color("#11151b")
	var border := accent.darkened(0.5)
	if state == 1:
		bg = accent.darkened(0.78)
		border = accent.darkened(0.08)
	elif state == 2:
		bg = accent.darkened(0.86)
		border = accent
	elif state == 3:
		bg = Color("#15181e")
		border = Color("#2a303a")
	var s := flat(bg, border, 6)
	s.border_width_left = 4
	s.border_width_top = 2
	s.border_width_right = 2
	s.border_width_bottom = 2
	s.content_margin_left = 22
	s.content_margin_right = 22
	s.content_margin_top = 13
	s.content_margin_bottom = 13
	return s


static func slider(minv: float, maxv: float, step: float, value: float) -> HSlider:
	var s := HSlider.new()
	s.min_value = minv
	s.max_value = maxv
	s.step = step
	s.value = value
	s.custom_minimum_size = Vector2(0, 30)
	s.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	s.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	var track := flat(Color("#0a0c10"), Color("#303844"), 4)
	track.content_margin_top = 4
	track.content_margin_bottom = 4
	track.content_margin_left = 0
	track.content_margin_right = 0
	var fill := flat(GOLD_SOFT, Color.TRANSPARENT, 4)
	fill.content_margin_top = 4
	fill.content_margin_bottom = 4
	fill.content_margin_left = 0
	fill.content_margin_right = 0
	var fill_hi := fill.duplicate() as StyleBoxFlat
	fill_hi.bg_color = GOLD
	s.add_theme_stylebox_override("slider", track)
	s.add_theme_stylebox_override("grabber_area", fill)
	s.add_theme_stylebox_override("grabber_area_highlight", fill_hi)
	s.add_theme_icon_override("grabber", _grabber_texture(GOLD))
	s.add_theme_icon_override("grabber_highlight", _grabber_texture(GOLD.lightened(0.18)))
	return s


static func _grabber_texture(color: Color) -> Texture2D:
	var key := color.to_html()
	if _grabber_cache.has(key):
		return _grabber_cache[key]
	var size := 20
	var image := Image.create(size, size, false, Image.FORMAT_RGBA8)
	image.fill(Color(0.0, 0.0, 0.0, 0.0))
	var center := Vector2((size - 1) * 0.5, (size - 1) * 0.5)
	for y in range(size):
		for x in range(size):
			var d := Vector2(x, y).distance_to(center)
			if d <= 7.5:
				var c := color
				if d > 5.2:
					c = color.darkened(0.45)
				elif d < 2.8:
					c = INK
				image.set_pixel(x, y, c)
	_grabber_cache[key] = ImageTexture.create_from_image(image)
	return _grabber_cache[key]


static func line_edit(placeholder: String, font_size: int = 18) -> LineEdit:
	var e := LineEdit.new()
	e.placeholder_text = placeholder
	e.custom_minimum_size = Vector2(0, 50)
	e.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	e.add_theme_font_override("font", body_font(500))
	e.add_theme_font_size_override("font_size", font_size)
	e.add_theme_color_override("font_color", TEXT)
	e.add_theme_color_override("font_placeholder_color", Color(STEEL, 0.65))
	e.add_theme_color_override("font_selected_color", INK)
	e.add_theme_color_override("caret_color", GOLD)
	e.add_theme_color_override("selection_color", Color(GOLD, 0.28))
	e.add_theme_stylebox_override("normal", _input_style(STONE))
	e.add_theme_stylebox_override("focus", _input_style(GOLD_SOFT))
	e.add_theme_stylebox_override("read_only", _input_style(Color("#242a33")))
	e.add_theme_constant_override("caret_width", 2)
	return e


static func _input_style(border: Color) -> StyleBoxFlat:
	var s := flat(Color("#0b0e13", 0.96), border, 4)
	s.content_margin_left = 16
	s.content_margin_right = 16
	s.content_margin_top = 12
	s.content_margin_bottom = 12
	s.shadow_color = Color(0.0, 0.0, 0.0, 0.35)
	s.shadow_size = 6
	s.shadow_offset = Vector2(0, 3)
	return s


static func rule(color: Color = STONE, thickness: int = 1, width: int = 0) -> ColorRect:
	var r := ColorRect.new()
	r.color = color
	r.custom_minimum_size = Vector2(width, thickness)
	r.size_flags_horizontal = Control.SIZE_EXPAND_FILL if width <= 0 else Control.SIZE_SHRINK_BEGIN
	r.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return r


static func vertical_rule(color: Color = STONE, thickness: int = 1) -> ColorRect:
	var r := ColorRect.new()
	r.color = color
	r.custom_minimum_size = Vector2(thickness, 0)
	r.size_flags_vertical = Control.SIZE_EXPAND_FILL
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return r


static func badge(text: String, accent: Color = GOLD, size: int = 11) -> PanelContainer:
	var p := PanelContainer.new()
	var s := flat(Color(accent, 0.11), Color(accent, 0.45), 20)
	s.content_margin_left = 10
	s.content_margin_right = 10
	s.content_margin_top = 4
	s.content_margin_bottom = 4
	p.add_theme_stylebox_override("panel", s)
	var l := inline_label(text, size, accent, 600)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	p.add_child(l)
	p.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	p.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	return p


static func keycap(text: String) -> Label:
	var l := inline_label(text, 10, MUTED, 600)
	var s := flat(Color("#0b0e13", 0.85), Color("#3a4350"), 3)
	s.content_margin_left = 8
	s.content_margin_right = 8
	s.content_margin_top = 3
	s.content_margin_bottom = 3
	l.add_theme_stylebox_override("normal", s)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	return l


static func stat_tile(caption: String, value: String, accent: Color = GOLD, width: int = 166) -> PanelContainer:
	var p := panel(PANEL_SOFT, Color("#303845"), false, accent)
	p.custom_minimum_size = Vector2(width, 76)
	p.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var v := vbox(3)
	v.alignment = BoxContainer.ALIGNMENT_CENTER
	p.add_child(v)
	v.add_child(eyebrow(caption, MUTED))
	v.add_child(display_label(value, 25, accent, 600, 0))
	return p


static func icon_text(text: String, size: int = 18, color: Color = TEXT) -> Label:
	var l := inline_label(text, size, color, 500)
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.55))
	l.add_theme_constant_override("outline_size", 2)
	return l


# ------------------------------------------------------------------ contenedores
static func spacer(h: int = 8) -> Control:
	var c := Control.new()
	c.custom_minimum_size = Vector2(0, h)
	return c


static func hbox(sep: int = 12) -> HBoxContainer:
	var b := HBoxContainer.new()
	b.add_theme_constant_override("separation", sep)
	return b


static func vbox(sep: int = 10) -> VBoxContainer:
	var b := VBoxContainer.new()
	b.add_theme_constant_override("separation", sep)
	return b


static func add_optional_image(parent: Control, path: String, minimum_size: Vector2, covered: bool = false) -> TextureRect:
	if path == "" or not ResourceLoader.exists(path):
		return null
	var image := TextureRect.new()
	image.custom_minimum_size = minimum_size
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED if covered else TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	image.texture = load(path) as Texture2D
	image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(image)
	return image


static func add_transparent_art(parent: Control, path: String, minimum_size: Vector2) -> TextureRect:
	if path == "" or not ResourceLoader.exists(path):
		return null
	var image := TextureRect.new()
	image.custom_minimum_size = minimum_size
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	image.texture = load(path) as Texture2D
	image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(image)
	return image


static func add_portrait(parent: Control, portrait_id: String, minimum_size: Vector2) -> FantasyPortrait:
	var portrait: FantasyPortrait = PortraitPainter.new()
	portrait.configure(portrait_id)
	portrait.custom_minimum_size = minimum_size
	portrait.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	portrait.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	parent.add_child(portrait)
	return portrait


static func add_item_icon(parent: Control, item_id: String, minimum_size: Vector2, tint_hex: String = "") -> EquipmentIcon:
	var icon: EquipmentIcon = ItemIconPainter.new()
	icon.configure(item_id, tint_hex)
	icon.custom_minimum_size = minimum_size
	icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	parent.add_child(icon)
	return icon


static func bar(value: float, maximum: float, color: Color, height: int = 14) -> ProgressBar:
	var p := ProgressBar.new()
	p.max_value = max(1.0, maximum)
	p.value = clampf(value, 0.0, p.max_value)
	p.show_percentage = false
	p.custom_minimum_size = Vector2(0, height)
	var bg := StyleBoxFlat.new()
	bg.bg_color = Color("#080a0d")
	bg.set_corner_radius_all(3)
	bg.border_color = Color("#2b333f")
	bg.set_border_width_all(1)
	var fg := StyleBoxFlat.new()
	fg.bg_color = color
	fg.set_corner_radius_all(3)
	p.add_theme_stylebox_override("background", bg)
	p.add_theme_stylebox_override("fill", fg)
	p.add_theme_font_size_override("font_size", 1)
	p.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	return p


static func dimmer() -> ColorRect:
	var c := ColorRect.new()
	c.color = Color(0.02, 0.025, 0.035, 0.86)
	c.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	c.mouse_filter = Control.MOUSE_FILTER_STOP
	return c


# --------------------------------------------------------------------- helpers
static func signed_int(v: int) -> String:
	return ("+%d" % v) if v >= 0 else ("-%d" % abs(v))


static func signed_term(coef: int, var_name: String = "x") -> String:
	if coef == 0:
		return ""
	if coef == 1:
		return " + " + var_name
	if coef == -1:
		return " - " + var_name
	return (" + %d%s" % [coef, var_name]) if coef > 0 else (" - %d%s" % [abs(coef), var_name])


static func poly(a: int, b: int, c: int) -> String:
	var s := ""
	if a != 0:
		s = ("x²" if a == 1 else ("-x²" if a == -1 else "%dx²" % a))
	if b != 0:
		s += (" + x" if b == 1 else (" - x" if b == -1 else signed_term(b)))
		s = s if s.begins_with("-") == false else s
	if c != 0:
		s += (" + %d" % c) if c > 0 else (" - %d" % abs(c))
	return s if s != "" else "0"
