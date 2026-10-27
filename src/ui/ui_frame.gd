class_name UIFrame
extends PanelContainer
## Panel oscuro con marcas ornamentales discretas, sin estirar la textura antigua.

var accent := Color("#8d713c")
var ornaments := true
var accent_alpha := 0.55


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_PASS
	resized.connect(queue_redraw)


func set_accent(value: Color) -> void:
	accent = value
	queue_redraw()


func _draw() -> void:
	if not ornaments:
		return
	var w := size.x
	var h := size.y
	if w < 8.0 or h < 8.0:
		return
	var color := Color(accent, accent_alpha)
	var long_mark := minf(30.0, w * 0.22)
	var short_mark := minf(16.0, w * 0.14)
	# Esquinas superiores: la marca larga da la sensación de un marco grabado.
	draw_line(Vector2(1.0, 1.0), Vector2(long_mark, 1.0), color, 2.0)
	draw_line(Vector2(1.0, 1.0), Vector2(1.0, 17.0), color, 2.0)
	draw_line(Vector2(w - long_mark, 1.0), Vector2(w - 1.0, 1.0), color, 2.0)
	draw_line(Vector2(w - 1.0, 1.0), Vector2(w - 1.0, 17.0), color, 2.0)
	# Esquinas inferiores: más cortas para no competir con el contenido.
	draw_line(Vector2(1.0, h - 1.0), Vector2(short_mark, h - 1.0), color, 1.5)
	draw_line(Vector2(1.0, h - 17.0), Vector2(1.0, h - 1.0), color, 1.5)
	draw_line(Vector2(w - short_mark, h - 1.0), Vector2(w - 1.0, h - 1.0), color, 1.5)
	draw_line(Vector2(w - 1.0, h - 17.0), Vector2(w - 1.0, h - 1.0), color, 1.5)
	# Diamantes de las esquinas superiores.
	_diamond(Vector2(7.0, 7.0), 3.5, color)
	_diamond(Vector2(w - 7.0, 7.0), 3.5, color)


func _diamond(center: Vector2, radius: float, color: Color) -> void:
	var points := PackedVector2Array([
		center + Vector2(0.0, -radius),
		center + Vector2(radius, 0.0),
		center + Vector2(0.0, radius),
		center + Vector2(-radius, 0.0),
	])
	draw_colored_polygon(points, color)
