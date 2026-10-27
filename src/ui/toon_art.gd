class_name ToonArt
extends RefCounted
## Aplica un tratamiento ilustrado sutil al arte raster.
## La UI, la tipografía y los controles quedan fuera: solo se estilizan
## fondos, retratos de personajes e iconos de equipo.

const SHADER := preload("res://src/ui/cartoon_art.gdshader")
const ENABLED := true


static func material(
		levels: float = 10.0,
		edge_strength: float = 0.22,
		ink_width: float = 3.0,
		saturation: float = 1.06,
		brightness: float = 1.0,
		shadow_lift: float = 0.0,
		rim_color: Color = Color(0.72, 0.78, 0.92, 1.0),
		rim_strength: float = 0.0
	) -> ShaderMaterial:
	if not ENABLED:
		return null
	var result := ShaderMaterial.new()
	result.shader = SHADER
	result.set_shader_parameter("levels", levels)
	result.set_shader_parameter("posterize_mix", 0.55)
	result.set_shader_parameter("saturation", saturation)
	result.set_shader_parameter("edge_strength", edge_strength)
	result.set_shader_parameter("edge_threshold", 0.075)
	result.set_shader_parameter("ink_width", ink_width)
	result.set_shader_parameter("ink_color", Color(0.015, 0.02, 0.035, 1.0))
	result.set_shader_parameter("brightness", brightness)
	result.set_shader_parameter("shadow_lift", shadow_lift)
	result.set_shader_parameter("rim_color", rim_color)
	result.set_shader_parameter("rim_strength", rim_strength)
	return result


static func apply(
		node: CanvasItem,
		levels: float = 10.0,
		edge_strength: float = 0.22,
		ink_width: float = 3.0,
		saturation: float = 1.06,
		brightness: float = 1.0,
		shadow_lift: float = 0.0,
		rim_color: Color = Color(0.72, 0.78, 0.92, 1.0),
		rim_strength: float = 0.0
	) -> void:
	if not ENABLED or node == null:
		return
	node.material = material(levels, edge_strength, ink_width, saturation, brightness, shadow_lift, rim_color, rim_strength)
