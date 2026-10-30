@tool
extends HSplitContainer
## The "Docs" main screen: file list and outline on the left, rendered document on the right.

const Parser := preload("md_parser.gd")
const Renderer := preload("md_renderer.gd")
const Style := preload("md_style.gd")
const I18n := preload("md_i18n.gd")

const MAX_WIDTH := 920  # Max text column width; long lines are hard to read.
const META_SECTION := "markdown_docs_viewer"

var current_path := ""
var _zoom := 1.0
var _mtime := 0
var _style: Style

var _files: ItemList
var _outline: Tree
var _title: Label
var _scroll: ScrollContainer
var _page: MarginContainer
var _doc: Control
var _anchors := {}


func _ready() -> void:
	# Plugin controls are auto-translated with the editor's catalog by default, which would
	# turn "Copy" into the editor's wording or translate headings that match editor terms.
	# Strings are localized by md_i18n.gd instead; children inherit this setting.
	auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	split_offset = roundi(240 * EditorInterface.get_editor_scale())
	_build_ui()
	_zoom = _meta("zoom", 1.0)
	EditorInterface.get_resource_filesystem().filesystem_changed.connect(_refresh_file_list)
	EditorInterface.get_editor_settings().settings_changed.connect(_on_settings_changed)
	_refresh_file_list()
	var last: String = _meta("last_file", "res://README.md")
	if FileAccess.file_exists(last):
		open(last)

	# Poll once a second and re-render when the file changes on disk.
	var timer := Timer.new()
	timer.wait_time = 1.0
	timer.autostart = true
	timer.timeout.connect(_check_modified)
	add_child(timer)

func open(path: String, anchor := "") -> void:
	if not FileAccess.file_exists(path):
		push_warning(I18n.t("not_found") % path)
		return
	var same_file := path == current_path
	current_path = path
	_set_meta("last_file", path)
	_render(same_file)
	_select_in_list(path)
	if not anchor.is_empty():
		_scroll_to(anchor)


func _render(keep_scroll := false) -> void:
	var old_scroll := _scroll.scroll_vertical
	_mtime = FileAccess.get_modified_time(current_path)
	_style = Style.new(_zoom)
	_apply_page_style()
	_title.text = current_path.get_file()
	_title.tooltip_text = current_path

	var renderer := Renderer.new(_style)
	renderer.link_clicked.connect(_on_link)
	var doc: VBoxContainer = renderer.build(Parser.parse(FileAccess.get_file_as_string(current_path)))
	if _doc:
		_doc.queue_free()
	_doc = doc
	_page.add_child(doc)
	_anchors = renderer.anchors
	_fill_outline(renderer.headings)
	_update_page_margin()

	await get_tree().process_frame  # Wait for layout before restoring the scroll position.
	_scroll.scroll_vertical = old_scroll if keep_scroll else 0


func _scroll_to(anchor: String) -> void:
	var target: Control = _anchors.get(anchor.trim_prefix("#").to_lower())
	if target == null:
		return
	await get_tree().process_frame
	if is_instance_valid(target):
		_scroll.scroll_vertical = roundi(target.global_position.y - _doc.global_position.y)


func _build_ui() -> void:
	# Sidebar: file list + outline.
	var side := VBoxContainer.new()
	side.custom_minimum_size.x = 160 * EditorInterface.get_editor_scale()
	side.add_theme_constant_override("separation", 4)
	add_child(side)
	side.add_child(_section_label(I18n.t("docs")))
	_files = ItemList.new()
	_files.custom_minimum_size.y = 90 * EditorInterface.get_editor_scale()
	_files.auto_height = true
	_files.item_selected.connect(func(i: int) -> void: open(_files.get_item_metadata(i)))
	side.add_child(_files)
	side.add_child(_section_label(I18n.t("outline")))
	_outline = Tree.new()
	_outline.hide_root = true
	_outline.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_outline.item_selected.connect(func() -> void: _scroll_to(_outline.get_selected().get_metadata(0)))
	side.add_child(_outline)

	# Main area: toolbar + document.
	var main := VBoxContainer.new()
	main.add_theme_constant_override("separation", 0)
	add_child(main)
	var bar := HBoxContainer.new()
	main.add_child(bar)
	_title = Label.new()
	_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_title.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	bar.add_child(_title)
	bar.add_child(_tool_button("ZoomLess", I18n.t("zoom_out"), func() -> void: _set_zoom(_zoom - 0.1)))
	bar.add_child(_tool_button("ZoomReset", I18n.t("zoom_reset"), func() -> void: _set_zoom(1.0)))
	bar.add_child(_tool_button("ZoomMore", I18n.t("zoom_in"), func() -> void: _set_zoom(_zoom + 0.1)))
	bar.add_child(_tool_button("Reload", I18n.t("reload"), func() -> void: if current_path: _render(true)))
	bar.add_child(_tool_button("ExternalLink", I18n.t("open_external"), func() -> void:
		if current_path:
			OS.shell_open(ProjectSettings.globalize_path(current_path))))

	_scroll = ScrollContainer.new()
	_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_scroll.resized.connect(_update_page_margin)
	_scroll.gui_input.connect(_on_scroll_input)
	main.add_child(_scroll)
	_page = MarginContainer.new()
	_page.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_scroll.add_child(_page)


func _section_label(text: String) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_color_override("font_color", get_theme_color("font_disabled_color", "Editor"))
	return l


func _tool_button(icon: String, tip: String, action: Callable) -> Button:
	var b := Button.new()
	b.flat = true
	b.tooltip_text = tip
	b.focus_mode = Control.FOCUS_NONE
	var editor_theme := EditorInterface.get_editor_theme()
	if editor_theme.has_icon(icon, "EditorIcons"):
		b.icon = editor_theme.get_icon(icon, "EditorIcons")
	else:
		b.text = tip.left(2)
	b.pressed.connect(action)
	return b

func _apply_page_style() -> void:
	_scroll.add_theme_stylebox_override("panel", _style.box(_style.bg))
	_scroll.add_theme_stylebox_override("focus", StyleBoxEmpty.new())


## Center the text column (max MAX_WIDTH) with padding on both sides.
func _update_page_margin() -> void:
	if _style == null:
		return
	var max_w: float = MAX_WIDTH * _style.scale
	var pad: float = _style.px(32)
	var side := maxf(pad, (_scroll.size.x - max_w) / 2.0)
	_page.add_theme_constant_override("margin_left", roundi(side))
	_page.add_theme_constant_override("margin_right", roundi(side))
	_page.add_theme_constant_override("margin_top", _style.px(28))
	_page.add_theme_constant_override("margin_bottom", _style.px(64))


func _refresh_file_list() -> void:
	_files.clear()
	var icon := EditorInterface.get_editor_theme().get_icon("TextFile", "EditorIcons")
	for path in _find_markdown("res://"):
		var i := _files.add_item(path.trim_prefix("res://"), icon)
		_files.set_item_metadata(i, path)
		_files.set_item_tooltip(i, path)
	_select_in_list(current_path)


func _find_markdown(dir_path: String) -> PackedStringArray:
	var result: PackedStringArray = []
	var dir := DirAccess.open(dir_path)
	if dir == null:
		return result
	for f in dir.get_files():
		if f.get_extension().to_lower() == "md":
			result.append(dir_path.path_join(f))
	for d in dir.get_directories():
		if not d.begins_with(".") and d != "addons":
			result.append_array(_find_markdown(dir_path.path_join(d)))
	return result


func _select_in_list(path: String) -> void:
	for i in _files.item_count:
		if _files.get_item_metadata(i) == path:
			_files.select(i)
			return
	_files.deselect_all()


func _fill_outline(headings: Array[Dictionary]) -> void:
	_outline.clear()
	var root := _outline.create_item()
	var parents := {0: root}
	for h in headings:
		if h.level > 3:
			continue
		var parent: TreeItem = root
		for lv in range(h.level - 1, 0, -1):  # Nearest higher-level heading.
			if parents.has(lv):
				parent = parents[lv]
				break
		var item := _outline.create_item(parent)
		item.set_text(0, h.text)
		item.set_tooltip_text(0, h.text)
		item.set_metadata(0, h.slug)
		parents[h.level] = item
		for deeper in parents.keys():
			if deeper > h.level:
				parents.erase(deeper)


func _on_link(target: String) -> void:
	if target.begins_with("http://") or target.begins_with("https://") or target.begins_with("mailto:"):
		OS.shell_open(target)
		return
	var anchor := ""
	var hash_pos := target.find("#")
	if hash_pos >= 0:
		anchor = target.substr(hash_pos + 1)
		target = target.left(hash_pos)
	if target.is_empty():
		_scroll_to(anchor.uri_decode())
		return
	var path := target.uri_decode()
	if not path.begins_with("res://"):
		path = current_path.get_base_dir().path_join(path).simplify_path()
	if path.get_extension().to_lower() == "md":
		open(path, anchor.uri_decode())
	elif path.get_extension() in ["tscn", "scn"]:
		EditorInterface.open_scene_from_path(path)
	elif ResourceLoader.exists(path):
		EditorInterface.edit_resource(load(path))
	else:
		EditorInterface.select_file(path)  # Reveal in the FileSystem dock.


func _on_scroll_input(event: InputEvent) -> void:
	var mb := event as InputEventMouseButton
	if mb and mb.pressed and mb.ctrl_pressed:
		if mb.button_index == MOUSE_BUTTON_WHEEL_UP:
			_set_zoom(_zoom + 0.1)
			_scroll.accept_event()
		elif mb.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_set_zoom(_zoom - 0.1)
			_scroll.accept_event()


func _set_zoom(value: float) -> void:
	value = snappedf(clampf(value, 0.6, 2.0), 0.1)
	if is_equal_approx(value, _zoom):
		return
	_zoom = value
	_set_meta("zoom", _zoom)
	if current_path:
		_render(true)


func _check_modified() -> void:
	if is_visible_in_tree() and current_path and FileAccess.file_exists(current_path):
		if FileAccess.get_modified_time(current_path) != _mtime:
			_render(true)


func _on_settings_changed() -> void:
	# Editor theme or syntax colors may have changed.
	if current_path:
		_render.call_deferred(true)


func _meta(key: String, default: Variant) -> Variant:
	return EditorInterface.get_editor_settings().get_project_metadata(META_SECTION, key, default)


func _set_meta(key: String, value: Variant) -> void:
	EditorInterface.get_editor_settings().set_project_metadata(META_SECTION, key, value)
