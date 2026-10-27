class_name EquipmentIcon
extends Control
## Iconografía de equipo cargada desde los PNG definidos en AssetManifest.

const MediaManifest = preload("res://src/core/asset_manifest.gd")
const ToonArt = preload("res://src/ui/toon_art.gd")

const INK := Color("#101218")
const OUTLINE := Color("#08090c")
const STEEL := Color("#aeb8c3")
const GOLD := Color("#d9ab52")
const VIOLET := Color("#9575eb")
const RED := Color("#ae4e55")

var item_id := "rusted_blade"
var icon_texture: Texture2D


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	ToonArt.apply(self, 10.0, 0.16, 2.0, 1.06)
	_load_icon()
	queue_redraw()


func configure(value: String, tint_hex: String = "") -> void:
	item_id = value.to_lower()
	modulate = Color(tint_hex) if tint_hex != "" else Color.WHITE
	_load_icon()
	queue_redraw()


func _load_icon() -> void:
	var path := MediaManifest.item_art(item_id)
	icon_texture = load(path) as Texture2D if path != "" and ResourceLoader.exists(path) else null


func _draw() -> void:
	if size.x <= 0.0 or size.y <= 0.0:
		return
	var side := minf(size.x, size.y)
	var scale_factor := side / 64.0
	draw_set_transform(Vector2((size.x - side) * 0.5, (size.y - side) * 0.5), 0.0, Vector2.ONE * scale_factor)
	if icon_texture != null:
		draw_texture_rect(icon_texture, Rect2(Vector2.ZERO, Vector2(64, 64)), false)
	else:
		_draw_tile()
		match item_id:
			"":
				_draw_empty_slot()
			"rusted_blade":
				_draw_sword(Color("#899098"), Color("#76503e"))
			"ashen_edge":
				_draw_axe(Color("#4f5863"), Color("#aeb7c1"))
			"arcane_staff":
				_draw_staff()
			"iron_cuirass":
				_draw_cuirass(Color("#8d969d"), Color("#606b76"))
			"warden_plate":
				_draw_cuirass(Color("#bac0c4"), Color("#596577"))
			"oak_shield":
				_draw_shield()
			"ember_charm":
				_draw_gem(RED, GOLD)
			"void_sigil":
				_draw_gem(VIOLET, Color("#d5c2ff"))
			"pilgrim_relic":
				_draw_gem(Color("#a8a18b"), GOLD)
			"healing_draught":
				_draw_potion(Color("#54a36e"))
			"greater_draught":
				_draw_potion(Color("#c47d43"))
			_:
				_draw_gem(STEEL, GOLD)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _draw_empty_slot() -> void:
	draw_circle(Vector2(32, 32), 11, Color("#20252d"))
	draw_arc(Vector2(32, 32), 12, 0.0, TAU, 32, Color("#6c7581"), 2.0, true)
	draw_line(Vector2(27, 32), Vector2(37, 32), Color("#9ba3ad"), 2.0, true)


func _draw_tile() -> void:
	var accent := GOLD if item_id in ["ashen_edge", "warden_plate", "void_sigil", "greater_draught"] else Color("#616b79")
	draw_rect(Rect2(2, 2, 60, 60), Color("#08090b"), true, -1.0, true)
	draw_rect(Rect2(4, 4, 56, 56), INK, true, -1.0, true)
	draw_rect(Rect2(4, 4, 56, 56), accent.darkened(0.25), false, 1.5, true)
	draw_arc(Vector2(32, 32), 25, deg_to_rad(205), deg_to_rad(335), 24, Color(accent, 0.45), 1.2, true)


func _draw_sword(blade: Color, grip: Color) -> void:
	_draw_poly([Vector2(43, 11), Vector2(48, 8), Vector2(39, 35), Vector2(34, 31)], blade)
	draw_line(Vector2(35, 30), Vector2(44, 34), GOLD, 3.0, true)
	draw_line(Vector2(37, 34), Vector2(27, 48), grip, 4.5, true)
	draw_line(Vector2(24, 45), Vector2(31, 51), GOLD, 2.0, true)


func _draw_axe(head: Color, edge: Color) -> void:
	draw_line(Vector2(24, 52), Vector2(43, 13), Color("#795439"), 5.0, true)
	_draw_poly([Vector2(38, 12), Vector2(53, 9), Vector2(51, 26), Vector2(44, 33), Vector2(36, 27)], head)
	_draw_poly([Vector2(49, 11), Vector2(54, 10), Vector2(52, 25), Vector2(49, 27)], edge, Color.TRANSPARENT)
	draw_line(Vector2(21, 49), Vector2(28, 54), GOLD, 2.0, true)


func _draw_staff() -> void:
	draw_line(Vector2(27, 53), Vector2(40, 19), Color("#7f523d"), 4.0, true)
	draw_line(Vector2(29, 43), Vector2(36, 45), GOLD, 2.0, true)
	draw_arc(Vector2(41, 14), 8, deg_to_rad(205), deg_to_rad(335), 18, GOLD, 2.4, true)
	draw_circle(Vector2(41, 15), 5, VIOLET)
	draw_circle(Vector2(39, 13), 1.8, Color("#e5dcff"))


func _draw_cuirass(main: Color, shade: Color) -> void:
	_draw_poly([Vector2(17, 17), Vector2(26, 13), Vector2(32, 19), Vector2(38, 13), Vector2(47, 17), Vector2(52, 27), Vector2(47, 37), Vector2(43, 52), Vector2(32, 56), Vector2(21, 52), Vector2(17, 37), Vector2(12, 27)], main)
	_draw_poly([Vector2(17, 27), Vector2(31, 31), Vector2(31, 52), Vector2(22, 49), Vector2(19, 37)], shade, Color.TRANSPARENT)
	_draw_poly([Vector2(47, 27), Vector2(33, 31), Vector2(33, 52), Vector2(42, 49), Vector2(45, 37)], shade, Color.TRANSPARENT)
	_draw_poly([Vector2(27, 30), Vector2(32, 25), Vector2(37, 30), Vector2(34, 38), Vector2(30, 38)], GOLD)
	draw_line(Vector2(32, 21), Vector2(32, 50), Color("#d0d2d0"), 1.2, true)


func _draw_shield() -> void:
	_draw_poly([Vector2(13, 15), Vector2(32, 10), Vector2(51, 15), Vector2(49, 39), Vector2(32, 55), Vector2(15, 39)], Color("#78553d"))
	_draw_poly([Vector2(19, 19), Vector2(32, 16), Vector2(32, 48), Vector2(20, 38)], Color("#936d49"), Color.TRANSPARENT)
	_draw_poly([Vector2(32, 16), Vector2(45, 19), Vector2(44, 38), Vector2(32, 48)], Color("#66503d"), Color.TRANSPARENT)
	draw_line(Vector2(32, 14), Vector2(32, 51), GOLD, 2.0, true)
	draw_line(Vector2(17, 28), Vector2(47, 28), GOLD, 1.5, true)


func _draw_gem(main: Color, light: Color) -> void:
	draw_arc(Vector2(32, 22), 14, deg_to_rad(200), deg_to_rad(340), 20, GOLD, 2.0, true)
	_draw_poly([Vector2(19, 25), Vector2(32, 14), Vector2(45, 25), Vector2(42, 43), Vector2(32, 53), Vector2(22, 43)], main)
	_draw_poly([Vector2(32, 15), Vector2(44, 25), Vector2(40, 40), Vector2(32, 46)], main.lightened(0.18), Color.TRANSPARENT)
	_draw_poly([Vector2(22, 25), Vector2(32, 18), Vector2(32, 46), Vector2(24, 40)], main.darkened(0.16), Color.TRANSPARENT)
	_draw_poly([Vector2(27, 25), Vector2(32, 20), Vector2(36, 26), Vector2(32, 34)], light, Color.TRANSPARENT)
	_draw_poly([Vector2(28, 44), Vector2(32, 49), Vector2(36, 44), Vector2(32, 39)], GOLD, Color.TRANSPARENT)


func _draw_potion(liquid: Color) -> void:
	draw_rect(Rect2(26, 12, 12, 8), GOLD, true, -1.0, true)
	draw_rect(Rect2(28, 20, 8, 8), Color("#b3a58d"), true, -1.0, true)
	_draw_poly([Vector2(25, 26), Vector2(39, 26), Vector2(43, 33), Vector2(41, 47), Vector2(35, 54), Vector2(29, 54), Vector2(23, 47), Vector2(21, 33)], Color("#d7d4cb"))
	_draw_poly([Vector2(24, 36), Vector2(40, 36), Vector2(39, 46), Vector2(34, 51), Vector2(29, 51), Vector2(24, 46)], liquid, Color.TRANSPARENT)
	draw_line(Vector2(27, 30), Vector2(30, 28), Color.WHITE, 1.6, true)


func _draw_poly(points: Array, fill: Color, stroke: Color = OUTLINE) -> void:
	if points.size() < 3:
		return
	var shape := PackedVector2Array()
	for point in points:
		shape.append(point)
	draw_colored_polygon(shape, fill)
	if stroke.a > 0.0:
		shape.append(points[0])
		draw_polyline(shape, stroke, 1.8, true)
