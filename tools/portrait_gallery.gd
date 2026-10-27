extends SceneTree
## Render de revisión local para los retratos e iconos vectoriales.

const PortraitPainter := preload("res://src/ui/fantasy_portrait.gd")
const ItemIconPainter := preload("res://src/ui/equipment_icon.gd")

const PORTRAITS := ["player", "skeleton", "brigand", "warden", "cultist", "colossus", "limitless", "blacksmith", "angel"]
const ITEMS := [
	"rusted_blade", "ashen_edge", "arcane_staff", "iron_cuirass", "warden_plate", "oak_shield",
	"ember_charm", "void_sigil", "pilgrim_relic", "healing_draught", "greater_draught",
]
const WIDTH := 1440
const HEIGHT := 840


func _initialize() -> void:
	call_deferred("_render")


func _render() -> void:
	var viewport := SubViewport.new()
	viewport.size = Vector2i(WIDTH, HEIGHT)
	viewport.transparent_bg = false
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(viewport)

	var canvas := Control.new()
	canvas.size = Vector2(WIDTH, HEIGHT)
	canvas.mouse_filter = Control.MOUSE_FILTER_IGNORE
	viewport.add_child(canvas)
	var background := ColorRect.new()
	background.color = Color("#0c0e11")
	background.size = Vector2(WIDTH, HEIGHT)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(background)

	_add_label(canvas, "LIMITS BREAKER · ARTE VECTORIAL DIBUJADO POR CÓDIGO", Vector2(30, 18), Vector2(1380, 34), 22, Color("#d9ab52"), HORIZONTAL_ALIGNMENT_CENTER)
	_add_label(canvas, "Retratos · 128 × 128 · sin modelo de imagen", Vector2(30, 52), Vector2(1380, 24), 14, Color("#98a0ab"), HORIZONTAL_ALIGNMENT_CENTER)

	for index in range(PORTRAITS.size()):
		var col := index % 5
		var row := index / 5
		var x := 38.0 + float(col) * 274.0
		var y := 92.0 + float(row) * 174.0
		var portrait: Control = PortraitPainter.new()
		portrait.configure(String(PORTRAITS[index]))
		portrait.position = Vector2(x + 78.0, y)
		portrait.size = Vector2(118, 118)
		canvas.add_child(portrait)
		_add_label(canvas, String(PORTRAITS[index]).to_upper(), Vector2(x, y + 120.0), Vector2(274, 24), 13, Color("#c9c4b8"), HORIZONTAL_ALIGNMENT_CENTER)

	_add_label(canvas, "EQUIPO · 11 IDENTIFICADORES", Vector2(30, 452), Vector2(1380, 28), 19, Color("#d9ab52"), HORIZONTAL_ALIGNMENT_CENTER)
	for index in range(ITEMS.size()):
		var x := 36.0 + float(index) * 128.0
		var icon: Control = ItemIconPainter.new()
		icon.configure(String(ITEMS[index]))
		icon.position = Vector2(x + 31.0, 500.0)
		icon.size = Vector2(66, 66)
		canvas.add_child(icon)
		_add_label(canvas, String(ITEMS[index]).replace("_", " "), Vector2(x, 570.0), Vector2(128, 30), 11, Color("#98a0ab"), HORIZONTAL_ALIGNMENT_CENTER)

	_add_label(canvas, "Efectos disponibles: corte · arcano · impacto · curación · chispas", Vector2(30, 655), Vector2(1380, 30), 15, Color("#8b95a6"), HORIZONTAL_ALIGNMENT_CENTER)
	var sample: Control = PortraitPainter.new()
	sample.configure("angel")
	sample.position = Vector2(474, 685)
	sample.size = Vector2(64, 64)
	canvas.add_child(sample)
	sample.play_effect("heal")
	var sample_hit: Control = PortraitPainter.new()
	sample_hit.configure("warden")
	sample_hit.position = Vector2(684, 685)
	sample_hit.size = Vector2(64, 64)
	canvas.add_child(sample_hit)
	sample_hit.play_effect("hit")
	var sample_spell: Control = PortraitPainter.new()
	sample_spell.configure("limitless")
	sample_spell.position = Vector2(894, 685)
	sample_spell.size = Vector2(64, 64)
	canvas.add_child(sample_spell)
	sample_spell.play_effect("arcane")

	await process_frame
	await process_frame
	var output_dir := ProjectSettings.globalize_path("res://output/codeart")
	DirAccess.make_dir_recursive_absolute(output_dir)
	var output_path := output_dir.path_join("portrait-gallery.png")
	var viewport_texture := viewport.get_texture()
	if viewport_texture == null or not viewport_texture.is_valid():
		push_error("El renderer actual no ofrece una textura para la galería.")
		quit(2)
		return
	var image := viewport_texture.get_image()
	if image == null or image.is_empty():
		push_error("El renderer actual no dibujó la galería.")
		quit(2)
		return
	print("Viewport render: %d × %d" % [image.get_width(), image.get_height()])
	var error_code := image.save_png(output_path)
	if error_code != OK:
		push_error("No se pudo guardar la galería: %d" % error_code)
	else:
		print("Galería: %s (%d × %d)" % [output_path, image.get_width(), image.get_height()])
	quit(1 if error_code != OK else 0)


func _add_label(parent: Control, text: String, position: Vector2, dimensions: Vector2, font_size: int, color: Color, align: int) -> void:
	var label := Label.new()
	label.text = text
	label.position = position
	label.size = dimensions
	label.horizontal_alignment = align
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	parent.add_child(label)
