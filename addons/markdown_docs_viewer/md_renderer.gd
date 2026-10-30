@tool
extends RefCounted
## Turns parsed blocks into Control nodes: RichTextLabel for text and headings,
## styled containers for code blocks, tables and quotes.

signal link_clicked(target: String)

const Inline := preload("md_inline.gd")
const Highlight := preload("md_highlight.gd")
const Style := preload("md_style.gd")
const I18n := preload("md_i18n.gd")

var s: Style
var anchors := {}  # Heading slug -> node, used for jumping.
var headings: Array[Dictionary] = []  # Data for the outline.
var _hl: Highlight
var _first := true


func _init(style: Style) -> void:
	s = style
	_hl = Highlight.new(style.text)


func build(blocks: Array[Dictionary]) -> VBoxContainer:
	var box := VBoxContainer.new()
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.add_theme_constant_override("separation", s.px(14))
	for b in blocks:
		var c := _block(b)
		if c:
			box.add_child(c)
		_first = false
	return box


func _block(b: Dictionary) -> Control:
	match b.type:
		"heading": return _heading(b)
		"para": return rich(Inline.to_bbcode(b.text, s))
		"code": return _code(b)
		"table": return _table(b)
		"list": return _list(b)
		"quote": return _quote(b)
		"hr": return _hr()
	return null


func rich(bbcode: String, size := 0, color: Variant = null, normal_font: Font = null, wrap := true) -> RichTextLabel:
	var r := RichTextLabel.new()
	r.bbcode_enabled = true
	r.fit_content = true
	r.scroll_active = false
	r.selection_enabled = true
	r.meta_underlined = false
	r.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART if wrap else TextServer.AUTOWRAP_OFF
	r.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var sz := size if size > 0 else s.size_body
	r.add_theme_font_override("normal_font", normal_font if normal_font else s.font)
	r.add_theme_font_override("bold_font", s.font_bold)
	r.add_theme_font_override("italics_font", s.font_italic)
	r.add_theme_font_override("bold_italics_font", s.font_bold)
	r.add_theme_font_override("mono_font", s.font_mono)
	for key in ["normal_font_size", "bold_font_size", "italics_font_size", "bold_italics_font_size"]:
		r.add_theme_font_size_override(key, sz)
	r.add_theme_font_size_override("mono_font_size", roundi(sz * 0.9))
	r.add_theme_color_override("default_color", color if color != null else s.text)
	r.add_theme_color_override("selection_color", Color(s.accent, 0.35))
	r.add_theme_constant_override("line_separation", s.px(5))
	r.add_theme_stylebox_override("normal", StyleBoxEmpty.new())
	r.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	r.text = bbcode
	r.meta_clicked.connect(func(meta: Variant) -> void: link_clicked.emit(str(meta)))
	return r


func _heading(b: Dictionary) -> Control:
	var level: int = b.level
	var slug := Inline.slugify(b.text)
	var base := slug
	var k := 1
	while anchors.has(slug):  # Duplicate headings get -1, -2, ... like on GitHub.
		slug = "%s-%d" % [base, k]
		k += 1
	var m := MarginContainer.new()
	m.add_theme_constant_override("margin_top", 0 if _first else s.px([20, 22, 12, 8, 6, 6][level - 1]))
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", s.px(10))
	m.add_child(v)
	var color: Color = s.muted if level == 6 else s.heading
	v.add_child(rich(Inline.to_bbcode(b.text, s), s.heading_size(level), color, s.font_bold))
	if level <= 2:
		v.add_child(_line(s.border))
	anchors[slug] = m
	headings.append({level = level, text = Inline.plain(b.text), slug = slug})
	return m


func _line(color: Color) -> ColorRect:
	var line := ColorRect.new()
	line.color = color
	line.custom_minimum_size.y = maxi(1, s.px(1))
	line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return line


func _hr() -> Control:
	var m := MarginContainer.new()
	m.add_theme_constant_override("margin_top", s.px(8))
	m.add_theme_constant_override("margin_bottom", s.px(8))
	m.add_child(_line(s.border))
	return m

func _code(b: Dictionary) -> Control:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", s.box(s.code_bg, 8, Vector2.ZERO, s.border, 1))
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 0)
	panel.add_child(v)

	# Header bar: language name + copy button.
	var bar := HBoxContainer.new()
	var bar_m := MarginContainer.new()
	for side in ["left", "right"]:
		bar_m.add_theme_constant_override("margin_" + side, s.px(12))
	bar_m.add_theme_constant_override("margin_top", s.px(4))
	bar_m.add_child(bar)
	v.add_child(bar_m)
	var lang := Label.new()
	lang.text = b.lang if not b.lang.is_empty() else "text"
	lang.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lang.add_theme_color_override("font_color", s.muted)
	lang.add_theme_font_override("font", s.font_mono)
	lang.add_theme_font_size_override("font_size", roundi(s.size_code * 0.85))
	bar.add_child(lang)
	var copy := Button.new()
	copy.flat = true
	copy.text = I18n.t("copy")
	copy.icon = s.editor_icon("ActionCopy")
	copy.focus_mode = Control.FOCUS_NONE
	copy.add_theme_font_size_override("font_size", roundi(s.size_code * 0.85))
	copy.add_theme_color_override("font_color", s.muted)
	copy.add_theme_color_override("icon_normal_color", s.muted)
	var code_text: String = b.code
	copy.pressed.connect(func() -> void:
		DisplayServer.clipboard_set(code_text)
		copy.text = I18n.t("copied")
		await copy.get_tree().create_timer(1.5).timeout
		if is_instance_valid(copy):
			copy.text = I18n.t("copy"))
	bar.add_child(copy)
	v.add_child(_line(Color(s.border, 0.6)))

	# Code area: no wrapping, scroll horizontally instead so alignment (e.g. file trees) is kept.
	var scroll := ScrollContainer.new()
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	var m := MarginContainer.new()
	m.add_theme_constant_override("margin_left", s.px(16))
	m.add_theme_constant_override("margin_right", s.px(16))
	m.add_theme_constant_override("margin_top", s.px(12))
	m.add_theme_constant_override("margin_bottom", s.px(14))
	var label := rich(_hl.highlight(code_text, b.lang), s.size_code, _hl.text_color, s.font_mono, false)
	label.size_flags_horizontal = Control.SIZE_FILL
	m.add_child(label)
	scroll.add_child(m)
	v.add_child(scroll)
	return panel


func _table(b: Dictionary) -> Control:
	var cols: int = b.header.size()
	# The frame color doubles as grid lines: cells leave a 1px gap that shows it through.
	var frame := PanelContainer.new()
	frame.add_theme_stylebox_override("panel", s.box(s.border, 8, Vector2(1, 1)))
	frame.clip_children = CanvasItem.CLIP_CHILDREN_AND_DRAW
	frame.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	var grid := GridContainer.new()
	grid.columns = cols
	grid.add_theme_constant_override("h_separation", maxi(1, s.px(1)))
	grid.add_theme_constant_override("v_separation", maxi(1, s.px(1)))
	frame.add_child(grid)
	var alt: Color = s.bg.lerp(s.surface, 0.55)
	for c in cols:
		grid.add_child(_cell("[b]%s[/b]" % Inline.to_bbcode(b.header[c], s), b.aligns[c] if c < b.aligns.size() else "left", s.surface, s.heading))
	var row_i := 0
	for row: PackedStringArray in b.rows:
		for c in cols:
			grid.add_child(_cell(Inline.to_bbcode(row[c], s), b.aligns[c] if c < b.aligns.size() else "left", alt if row_i % 2 else s.bg, s.text))
		row_i += 1
	# Scroll horizontally when the table is too wide.
	var scroll := ScrollContainer.new()
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.add_child(frame)
	return scroll


func _cell(bbcode: String, align: String, bg: Color, color: Color) -> Control:
	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", s.box(bg, 0, Vector2(14, 7)))
	p.size_flags_horizontal = Control.SIZE_FILL
	if align == "center":
		bbcode = "[center]%s[/center]" % bbcode
	elif align == "right":
		bbcode = "[right]%s[/right]" % bbcode
	var label := rich(bbcode, 0, color, null, false)
	label.size_flags_vertical = Control.SIZE_SHRINK_CENTER  # Vertically center when cells in a row differ in height.
	p.add_child(label)
	return p


func _list(b: Dictionary) -> Control:
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", s.px(6))
	var counters := {}  # Ordered-list counter per nesting level.
	for item: Dictionary in b.items:
		var level: int = item.level
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", s.px(8))
		var indent := Control.new()
		indent.custom_minimum_size.x = s.px(4 + level * 24)
		row.add_child(indent)
		var marker_box := CenterContainer.new()
		marker_box.custom_minimum_size = Vector2(s.px(18), s.font.get_height(s.size_body) + s.px(5))
		marker_box.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
		row.add_child(marker_box)
		var color: Color = s.text
		if item.task >= 0:
			var icon := TextureRect.new()
			icon.texture = s.check_icon(item.task == 1)
			icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			icon.modulate = s.accent if item.task == 1 else s.muted
			marker_box.add_child(icon)
			if item.task == 1:
				color = s.muted
		else:
			var mark := Label.new()
			if item.ordered:
				counters[level] = counters.get(level, 0) + 1
				mark.text = "%d." % counters[level]
			else:
				mark.text = ["•", "◦", "▪"][level % 3]
			mark.add_theme_color_override("font_color", s.accent if not item.ordered else s.muted)
			mark.add_theme_font_override("font", s.font_bold if item.ordered else s.font)
			mark.add_theme_font_size_override("font_size", s.size_body)
			marker_box.add_child(mark)
		for deeper in counters.keys():
			if deeper > level:
				counters.erase(deeper)
		row.add_child(rich(Inline.to_bbcode(item.text, s), 0, color))
		v.add_child(row)
	return v


func _quote(b: Dictionary) -> Control:
	var p := PanelContainer.new()
	var sb: StyleBoxFlat = s.box(s.quote_bg, 0, Vector2(18, 12))
	sb.border_width_left = s.px(4)
	sb.border_color = s.accent
	sb.corner_radius_top_right = s.px(6)
	sb.corner_radius_bottom_right = s.px(6)
	sb.anti_aliasing = true
	p.add_theme_stylebox_override("panel", sb)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", s.px(10))
	for child in b.blocks:
		var c := _block(child)
		if c:
			if c is RichTextLabel:
				(c as RichTextLabel).add_theme_color_override("default_color", s.muted)
			v.add_child(c)
	p.add_child(v)
	return p
