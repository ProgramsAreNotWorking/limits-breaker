@tool
extends RefCounted
## Colors, fonts and style boxes. Switches between dark and light palettes based on the editor theme.

var dark: bool
var scale: float
var accent: Color
var bg: Color
var surface: Color
var code_bg: Color
var border: Color
var text: Color
var muted: Color
var heading: Color
var inline_code_fg: Color
var inline_code_bg: Color
var quote_bg: Color
var row_alt: Color

var font: Font
var font_bold: Font
var font_italic: Font
var font_mono: Font
var size_body: int
var size_code: int

var _theme: Theme


func _init(zoom := 1.0) -> void:
	_theme = EditorInterface.get_editor_theme()
	var editor_scale := EditorInterface.get_editor_scale()
	scale = editor_scale * zoom  # Spacing and corner radii scale with zoom too.
	var base := _theme.get_color("base_color", "Editor")
	accent = _theme.get_color("accent_color", "Editor")
	dark = base.get_luminance() < 0.5
	if dark:
		bg = base.lerp(Color.BLACK, 0.2)
		surface = base.lerp(Color.WHITE, 0.04)
		code_bg = base.lerp(Color.BLACK, 0.42)
		border = base.lerp(Color.WHITE, 0.13)
		text = Color("#d5dbe3")
		muted = Color("#8b95a3")
		heading = Color("#f2f5f8")
		inline_code_fg = Color("#f5ad82")
		inline_code_bg = Color(1, 1, 1, 0.075)
		row_alt = Color(1, 1, 1, 0.025)
	else:
		bg = Color("#ffffff")
		surface = Color("#f6f8fa")
		code_bg = Color("#f6f8fa")
		border = Color("#d8dee4")
		text = Color("#1f2328")
		muted = Color("#656d76")
		heading = Color("#111418")
		inline_code_fg = Color("#c2410c")
		inline_code_bg = Color(0, 0, 0, 0.055)
		row_alt = Color(0, 0, 0, 0.022)
	quote_bg = Color(accent, 0.07)

	font = _font("doc", "main")
	font_bold = _font("doc_bold", "bold")
	font_italic = _font("doc_italic", "doc")
	font_mono = _font("doc_source", "source")
	size_body = roundi(_size("doc_size", roundi(16 * editor_scale)) * zoom)
	size_code = roundi(size_body * 0.9)


func px(v: float) -> int:
	return roundi(v * scale)


func heading_size(level: int) -> int:
	var ratio: float = [2.0, 1.55, 1.28, 1.12, 1.0, 0.92][clampi(level - 1, 0, 5)]
	return roundi(size_body * ratio)


func box(color: Color, radius := 0, margin := Vector2.ZERO, border_color := Color.TRANSPARENT, border_width := 0) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = color
	sb.set_corner_radius_all(px(radius))
	sb.content_margin_left = px(margin.x)
	sb.content_margin_right = px(margin.x)
	sb.content_margin_top = px(margin.y)
	sb.content_margin_bottom = px(margin.y)
	if border_width > 0:
		sb.border_color = border_color
		sb.set_border_width_all(maxi(1, px(border_width)))
	sb.anti_aliasing = radius > 0
	return sb


func check_icon(checked: bool) -> Texture2D:
	return _theme.get_icon("checked" if checked else "unchecked", "CheckBox")


func editor_icon(name: String) -> Texture2D:
	return _theme.get_icon(name, "EditorIcons") if _theme.has_icon(name, "EditorIcons") else null


func _font(name: String, fallback: String) -> Font:
	if _theme.has_font(name, "EditorFonts"):
		return _theme.get_font(name, "EditorFonts")
	return _theme.get_font(fallback, "EditorFonts")


func _size(name: String, fallback: int) -> int:
	return _theme.get_font_size(name, "EditorFonts") if _theme.has_font_size(name, "EditorFonts") else fallback
