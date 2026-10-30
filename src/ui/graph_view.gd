class_name GraphView
extends Control
## Dibuja la gráfica de una función por tramos para el tópico "graph".
## El punto cerrado representa f(a); el punto abierto, el lateral que no
## incluye a x = a.

var data: Dictionary = {}
var line_color := UIKit.GOLD
var axis_color := UIKit.STEEL_DARK

const BACKGROUND := Color(0.04, 0.045, 0.055)
const LABEL_BG := Color(0.04, 0.045, 0.055, 0.92)


func setup(d: Dictionary) -> void:
	data = d
	custom_minimum_size = Vector2(500, 200)
	queue_redraw()


func _draw() -> void:
	if data.is_empty():
		return
	var w := size.x
	var h := size.y
	draw_rect(Rect2(0, 0, w, h), BACKGROUND)
	var a: float = float(data.get("a", 0))
	var xmin: float = float(data.get("xmin", a - 3.0))
	var xmax: float = float(data.get("xmax", a + 3.0))
	var ly: float = float(data.get("left_y", 0))
	var ry: float = float(data.get("right_y", 0))
	var left: Array = data.get("left", [0, 0])
	var right: Array = data.get("right", [0, 0])
	var y_at_xmin := float(left[0]) * xmin + float(left[1])
	var y_at_xmax := float(right[0]) * xmax + float(right[1])

	# El rango vertical incluye los extremos de ambos tramos para que las
	# rectas no se salgan del marco.
	var ymin := minf(minf(minf(ly, ry), minf(y_at_xmin, y_at_xmax)), 0.0) - 1.0
	var ymax := maxf(maxf(maxf(ly, ry), maxf(y_at_xmin, y_at_xmax)), 0.0) + 1.0
	if ymax - ymin < 4.0:
		var middle := (ymin + ymax) * 0.5
		ymin = middle - 2.0
		ymax = middle + 2.0
	# Deja espacio real para los valores de ambos ejes: el eje Y necesita
	# margen izquierdo para números negativos y el X necesita una franja
	# inferior para las marcas y la etiqueta de x = a.
	var pad_left := clampf(w * 0.10, 38.0, 52.0)
	var pad_right := clampf(w * 0.04, 16.0, 24.0)
	var pad_top := clampf(h * 0.10, 18.0, 26.0)
	var pad_bottom := clampf(h * 0.17, 30.0, 42.0)
	var plot := Rect2(pad_left, pad_top, w - pad_left - pad_right, h - pad_top - pad_bottom)

	# Rejilla
	for i in range(9):
		var gx := plot.position.x + plot.size.x * float(i) / 8.0
		draw_line(Vector2(gx, plot.position.y), Vector2(gx, plot.end.y), Color(1, 1, 1, 0.045), 1.0)
		var gy := plot.position.y + plot.size.y * float(i) / 8.0
		draw_line(Vector2(plot.position.x, gy), Vector2(plot.end.x, gy), Color(1, 1, 1, 0.045), 1.0)

	# Ejes
	var zero_y := _to_px_y(0.0, plot, ymin, ymax)
	if zero_y >= plot.position.y and zero_y <= plot.end.y:
		draw_line(Vector2(plot.position.x, zero_y), Vector2(plot.end.x, zero_y), axis_color, 1.5)
	var zero_x := _to_px_x(0.0, plot, xmin, xmax)
	if zero_x >= plot.position.x and zero_x <= plot.end.x:
		draw_line(Vector2(zero_x, plot.position.y), Vector2(zero_x, plot.end.y), axis_color, 1.5)

	# Tramos
	var left_pts := PackedVector2Array()
	var right_pts := PackedVector2Array()
	for i in range(61):
		var k := float(i) / 60.0
		var xl := lerpf(xmin, a, k)
		var yl := float(left[0]) * xl + float(left[1])
		left_pts.append(Vector2(_to_px_x(xl, plot, xmin, xmax), _to_px_y(yl, plot, ymin, ymax)))
		var xr := lerpf(a, xmax, k)
		var yr := float(right[0]) * xr + float(right[1])
		right_pts.append(Vector2(_to_px_x(xr, plot, xmin, xmax), _to_px_y(yr, plot, ymin, ymax)))
	draw_polyline(left_pts, line_color, 2.5, true)
	draw_polyline(right_pts, line_color, 2.5, true)

	var ax := _to_px_x(a, plot, xmin, xmax)
	var left_px := Vector2(ax, _to_px_y(ly, plot, ymin, ymax))
	var right_px := Vector2(ax, _to_px_y(ry, plot, ymin, ymax))
	var continuous := is_equal_approx(ly, ry)

	# Guía vertical en x = a
	draw_dashed_line(Vector2(ax, plot.position.y), Vector2(ax, plot.end.y), Color(0.55, 0.45, 0.85, 0.4), 1.0, 5.0)

	var font := ThemeDB.fallback_font
	if continuous:
		# La función es continua: un único punto cerrado en (a, f(a)).
		_dot(left_px, line_color, line_color)
	else:
		# La rama izquierda no incluye a x = a: punto abierto.
		# La rama derecha sí lo incluye: punto cerrado en f(a).
		_dot(left_px, BACKGROUND, line_color)
		_dot(right_px, line_color, line_color)
	_draw_axis_values(font, plot, xmin, xmax, ymin, ymax, a)
	_tag(font, "x = %s" % _fmt(a), Vector2(ax + 6.0, plot.end.y + 31.0), false, UIKit.MUTED)


func _draw_axis_values(font: Font, plot: Rect2, xmin: float, xmax: float, ymin: float, ymax: float, a: float) -> void:
	var axis_y := clampf(_to_px_y(0.0, plot, ymin, ymax), plot.position.y, plot.end.y)
	var axis_x := clampf(_to_px_x(0.0, plot, xmin, xmax), plot.position.x, plot.end.x)
	var tick_color := Color(0.70, 0.75, 0.82, 0.95)
	var tick_font_size := 12

	# Valores del eje X. El punto x = a ya lleva su etiqueta inferior.
	for x in range(int(ceil(xmin)), int(floor(xmax)) + 1):
		if is_equal_approx(float(x), a):
			continue
		var px := _to_px_x(float(x), plot, xmin, xmax)
		draw_line(Vector2(px, axis_y - 4.0), Vector2(px, axis_y + 4.0), axis_color, 1.0)
		var label := str(x)
		var text_size := font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, tick_font_size)
		var label_y := axis_y + size.y * 0.075
		if label_y > size.y - 4.0:
			label_y = axis_y - 6.0
		var label_x := clampf(px - text_size.x * 0.5, 2.0, size.x - text_size.x - 2.0)
		draw_string(font, Vector2(label_x, label_y), label, HORIZONTAL_ALIGNMENT_LEFT, -1, tick_font_size, tick_color)

	# Valores del eje Y, con un paso que evita amontonar etiquetas.
	var y_span := maxf(1.0, ymax - ymin)
	var y_step := maxi(1, int(ceil(y_span / 6.0)))
	var first_y := int(ceil(ymin / float(y_step))) * y_step
	for y in range(first_y, int(floor(ymax)) + 1, y_step):
		var py := _to_px_y(float(y), plot, ymin, ymax)
		draw_line(Vector2(axis_x - 4.0, py), Vector2(axis_x + 4.0, py), axis_color, 1.0)
		var label := str(y)
		var text_size := font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, tick_font_size)
		var label_x := axis_x - text_size.x - 6.0
		if label_x < 2.0:
			label_x = axis_x + 6.0
		var label_y := clampf(py + 4.0, text_size.y + 2.0, size.y - 2.0)
		draw_string(font, Vector2(label_x, label_y), label, HORIZONTAL_ALIGNMENT_LEFT, -1, tick_font_size, tick_color)


func _to_px_x(x: float, plot: Rect2, xmin: float, xmax: float) -> float:
	return plot.position.x + (x - xmin) / maxf(0.001, xmax - xmin) * plot.size.x


func _to_px_y(y: float, plot: Rect2, ymin: float, ymax: float) -> float:
	return plot.end.y - (y - ymin) / maxf(0.001, ymax - ymin) * plot.size.y


func _dot(p: Vector2, fill: Color, border: Color) -> void:
	draw_circle(p, 6.5, border)
	draw_circle(p, 4.4, fill)


func _tag(font: Font, text: String, pos: Vector2, align_right: bool, color: Color) -> void:
	var fs := 12
	var text_size := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs)
	var p := pos
	if align_right:
		p.x -= text_size.x
	# Mantener la etiqueta dentro del control.
	p.x = clampf(p.x, 4.0, maxf(4.0, size.x - text_size.x - 4.0))
	p.y = clampf(p.y, text_size.y + 4.0, size.y - 4.0)
	var rect := Rect2(p.x - 3.0, p.y - text_size.y, text_size.x + 6.0, text_size.y + 4.0)
	draw_rect(rect, LABEL_BG, true)
	draw_string(font, p, text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, color)


func _fmt(value: float) -> String:
	if is_equal_approx(value, roundf(value)):
		return str(int(roundf(value)))
	return "%.2f" % value
