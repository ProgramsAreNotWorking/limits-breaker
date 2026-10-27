extends SceneTree
## Creates cohesive angel/death scene plates from the game's detailed raster scenes.

const SOURCES := {
	"angel": "res://assets/art/environments/boss-arena.png",
	"death": "res://assets/art/environments/dungeon.png",
}
const TARGETS := {
	"angel": "res://assets/art/environments/angel.png",
	"death": "res://assets/art/environments/death.png",
}


func _initialize() -> void:
	var arena := Image.load_from_file(ProjectSettings.globalize_path(SOURCES["angel"]))
	var corridor := Image.load_from_file(ProjectSettings.globalize_path(SOURCES["death"]))
	if arena.is_empty() or corridor.is_empty():
		push_error("No se pudieron cargar las placas de escenario fuente.")
		quit(1)
		return

	var angel_result := _save_variant(_angel_plate(arena), TARGETS["angel"])
	var death_result := _save_variant(_death_plate(corridor), TARGETS["death"])
	if angel_result == OK and death_result == OK:
		print("Fondos cohesivos exportados desde boss-arena.png y dungeon.png.")
		quit(0)
	else:
		push_error("No se pudieron guardar las placas de escenario.")
		quit(1)


func _angel_plate(source: Image) -> Image:
	var output := Image.create(source.get_width(), source.get_height(), false, Image.FORMAT_RGBA8)
	for y in range(source.get_height()):
		for x in range(source.get_width()):
			var color := source.get_pixel(x, y)
			var brightness := maxf(color.r, maxf(color.g, color.b))
			var violet := color.s > 0.20 and color.h > 0.64 and color.h < 0.88
			if violet:
				var gold := Color.from_hsv(0.105, minf(color.s * 0.76, 0.56), brightness, 1.0)
				color = color.lerp(gold, clampf((color.s - 0.12) * 1.45, 0.0, 0.78))

			# Warm light at the distant portal and a soft reflection on the dais,
			# leaving the source's painted stone texture and shadows intact.
			var portal_light := _ellipse_light(x, y, 512.0, 166.0, 176.0, 104.0)
			var floor_light := _ellipse_light(x, y, 512.0, 354.0, 286.0, 128.0)
			var glow := portal_light * 0.105 + floor_light * 0.052
			color.r = minf(color.r + glow * 0.72, 1.0)
			color.g = minf(color.g + glow * 0.43, 1.0)
			color.b = minf(color.b + glow * 0.15, 1.0)
			color.a = 1.0
			output.set_pixel(x, y, color)
	return output


func _death_plate(source: Image) -> Image:
	var width := source.get_width()
	var height := source.get_height()
	var output := Image.create(width, height, false, Image.FORMAT_RGBA8)
	for y in range(height):
		for x in range(width):
			var color := source.get_pixel(x, y)
			var luminance := color.r * 0.2126 + color.g * 0.7152 + color.b * 0.0722
			var cold_stone := Color(luminance * 0.86, luminance * 0.91, luminance * 1.02, 1.0)
			color = color.lerp(cold_stone, 0.20)
			color.r *= 0.91
			color.g *= 0.93
			color.b *= 0.97

			# A restrained vignette protects the summary UI while keeping the
			# high-detail passage readable around the frame.
			var nx := (float(x) - float(width) * 0.5) / (float(width) * 0.5)
			var ny := (float(y) - float(height) * 0.5) / (float(height) * 0.5)
			var edge := nx * nx * 0.62 + ny * ny * 0.20
			var vignette := clampf((edge - 0.08) * 0.15, 0.0, 0.12)
			color *= 0.91 - vignette

			# The corridor's distant light becomes a small burgundy ember instead
			# of a large focal object, matching the game's existing death accent.
			var ember_haze := _ellipse_light(x, y, 512.0, 229.0, 88.0, 52.0) * 0.18
			var ember_core := _ellipse_light(x, y, 512.0, 229.0, 3.4, 8.0) * 0.52
			color.r = minf(color.r + ember_haze * 0.42 + ember_core * 0.56, 1.0)
			color.g = minf(color.g + ember_haze * 0.035 + ember_core * 0.025, 1.0)
			color.b = minf(color.b + ember_haze * 0.07 + ember_core * 0.06, 1.0)
			color.a = 1.0
			output.set_pixel(x, y, color)
	return output


func _ellipse_light(x: int, y: int, center_x: float, center_y: float, radius_x: float, radius_y: float) -> float:
	var dx := (float(x) - center_x) / radius_x
	var dy := (float(y) - center_y) / radius_y
	return exp(-1.8 * (dx * dx + dy * dy))


func _save_variant(image: Image, resource_path: String) -> Error:
	var absolute_path := ProjectSettings.globalize_path(resource_path)
	var parent := absolute_path.get_base_dir()
	DirAccess.make_dir_recursive_absolute(parent)
	return image.save_png(absolute_path)
