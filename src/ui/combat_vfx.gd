class_name CombatVFX
extends Control
## Capa visual de combate: ráfagas de partículas y números de daño flotantes.
## Vive por encima del panel de fase y por debajo del HUD superior; nunca
## intercepta el ratón ni el teclado.

const VFXTexturesLib = preload("res://src/ui/vfx_textures.gd")
const SOFT_BURSTS := ["arcane", "critical", "impact", "heal", "correct", "defeat"]
const BURST_LAYER_TOP_RATIO := 0.245
const BURST_LAYER_SIDE_RATIO := 0.018
const BURST_LAYER_BOTTOM_RATIO := 0.02

var _spark_texture: Texture2D
var _soft_texture: Texture2D
var _burst_layer: Control


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_burst_layer = Control.new()
	_burst_layer.name = "ClippedBurstLayer"
	_burst_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_burst_layer.clip_contents = true
	add_child(_burst_layer)
	resized.connect(_sync_burst_layer)
	_sync_burst_layer()
	_spark_texture = VFXTexturesLib.star()
	_soft_texture = VFXTexturesLib.soft_dot()


func _sync_burst_layer() -> void:
	if _burst_layer == null:
		return
	var bounds := get_viewport_rect().size
	var side := minf(bounds.x * BURST_LAYER_SIDE_RATIO, 30.0)
	var top := minf(bounds.y * BURST_LAYER_TOP_RATIO, 220.0)
	var bottom := minf(bounds.y * BURST_LAYER_BOTTOM_RATIO, 28.0)
	_burst_layer.position = Vector2(side, top)
	_burst_layer.size = Vector2(maxf(0.0, bounds.x - side * 2.0), maxf(0.0, bounds.y - top - bottom))


func _safe_burst_center(center: Vector2, cfg: Dictionary) -> Vector2:
	var clip_rect := Rect2(_burst_layer.position, _burst_layer.size)
	var reach := float(cfg["speed_max"]) * float(cfg["life"])
	var inset_x := clampf(reach * 0.30, 32.0, 86.0)
	var inset_y := clampf(reach * 0.14, 18.0, 42.0)
	var min_x := clip_rect.position.x + inset_x
	var max_x := maxf(min_x, clip_rect.end.x - inset_x)
	var min_y := clip_rect.position.y + inset_y
	var max_y := maxf(min_y, clip_rect.end.y - inset_y)
	return Vector2(clampf(center.x, min_x, max_x), clampf(center.y, min_y, max_y))


func burst(center: Vector2, effect_id: String, intensity: float = 1.0, aim: Vector2 = Vector2.ZERO) -> void:
	if bool(Game.settings.get("reduced_motion", false)):
		return
	_spawn_burst(center, effect_id, intensity, false, aim)
	if effect_id in SOFT_BURSTS:
		_spawn_burst(center, effect_id, intensity * 0.82, true, aim)


func _spawn_burst(center: Vector2, effect_id: String, intensity: float, soft: bool, aim: Vector2) -> void:
	var cfg := _burst_config(effect_id)
	var safe_center := _safe_burst_center(center, cfg)
	var was_clamped := center.distance_squared_to(safe_center) > 1.0
	var emitter := GPUParticles2D.new()
	emitter.position = safe_center - _burst_layer.position
	emitter.texture = _soft_texture if soft else _spark_texture
	emitter.one_shot = true
	emitter.explosiveness = 1.0
	emitter.local_coords = true
	emitter.z_index = 0 if soft else 1
	emitter.visibility_rect = Rect2(Vector2(-520, -520), Vector2(1040, 1040))
	var canvas_material := CanvasItemMaterial.new()
	canvas_material.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	emitter.material = canvas_material

	var amount_scale := 0.5 if soft else 1.0
	emitter.amount = maxi(8, int(round(float(cfg["amount"]) * intensity * amount_scale)))
	emitter.lifetime = float(cfg["life"]) * (1.12 if soft else 1.0)
	emitter.preprocess = 0.0

	var direction: Vector3 = cfg["direction"]
	var spread := float(cfg["spread"])
	if aim.length_squared() > 0.001:
		var normalized_aim := aim.normalized()
		direction = Vector3(normalized_aim.x, normalized_aim.y, 0.0)
	if was_clamped:
		var inward := (get_viewport_rect().size * 0.5 - safe_center).normalized()
		var current_direction := Vector2(direction.x, direction.y).normalized()
		if inward.length_squared() > 0.001 and current_direction.length_squared() > 0.001:
			var biased_direction := current_direction.lerp(inward, 0.62).normalized()
			direction = Vector3(biased_direction.x, biased_direction.y, 0.0)
		spread = minf(spread, 120.0)
	var gravity: Vector3 = cfg["gravity"]
	var hot: Color = cfg["hot"]
	var tail: Color = cfg["tail"]
	var process := ParticleProcessMaterial.new()
	process.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	process.emission_sphere_radius = float(cfg["radius"]) * (0.7 if soft else 1.0)
	process.direction = direction
	process.spread = spread
	process.initial_velocity_min = float(cfg["speed_min"]) * (0.32 if soft else 1.0)
	process.initial_velocity_max = float(cfg["speed_max"]) * (0.52 if soft else 1.0)
	process.gravity = gravity * (0.22 if soft else 1.0)
	process.damping_min = 18.0 if not soft else 8.0
	process.damping_max = 54.0 if not soft else 26.0
	process.scale_min = float(cfg["scale_min"]) * (1.8 if soft else 1.0)
	process.scale_max = float(cfg["scale_max"]) * (2.2 if soft else 1.0)
	process.angle_min = -180.0
	process.angle_max = 180.0
	process.angular_velocity_min = -180.0
	process.angular_velocity_max = 180.0
	process.color = Color.WHITE
	process.color_ramp = _make_ramp(hot, tail)
	emitter.process_material = process

	_burst_layer.add_child(emitter)
	emitter.emitting = true
	emitter.finished.connect(_free_emitter.bind(emitter))
	# Red de seguridad por si el renderer headless no emite `finished`.
	get_tree().create_timer(emitter.lifetime + 0.8).timeout.connect(_free_emitter.bind(emitter))


func pop_number(center: Vector2, text: String, color: Color, font_size: int = 28, drift: Vector2 = Vector2.ZERO) -> void:
	var label := Label.new()
	label.text = text
	label.custom_minimum_size = Vector2(150, 46)
	label.size = Vector2(150, 46)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	var bounds := get_viewport_rect().size
	var safe_top := maxf(bounds.y * 0.25, _burst_layer.position.y + 12.0)
	var safe_position := center - Vector2(75, 23) + drift
	var safe_left := _burst_layer.position.x + 8.0
	var safe_right := maxf(safe_left, bounds.x - _burst_layer.position.x - 154.0)
	safe_position.x = clampf(safe_position.x, safe_left, safe_right)
	safe_position.y = clampf(safe_position.y, safe_top, maxf(safe_top, bounds.y - 56.0))
	label.position = safe_position
	label.pivot_offset = Vector2(75, 23)
	label.scale = Vector2(0.78, 0.78)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.z_index = 2
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_outline_color", Color(0.02, 0.02, 0.03, 0.95))
	label.add_theme_constant_override("outline_size", 5)
	add_child(label)
	var tween := create_tween()
	tween.set_parallel(true)
	var float_target := maxf(safe_position.y - 48.0, safe_top + 2.0)
	tween.tween_property(label, "position:y", float_target, 0.78).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "scale", Vector2.ONE, 0.24).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "modulate:a", 0.0, 0.78).set_delay(0.12)
	tween.chain().tween_callback(label.queue_free)


func _burst_config(effect_id: String) -> Dictionary:
	match effect_id:
		"slash", "attack":
			return {
				"amount": 28, "life": 0.58, "radius": 12.0,
				"direction": Vector3(0.72, -0.62, 0.0), "spread": 42.0,
				"speed_min": 120.0, "speed_max": 280.0,
				"gravity": Vector3(0.0, 120.0, 0.0),
				"scale_min": 0.05, "scale_max": 0.15,
				"hot": Color("#fff1bc"), "tail": Color("#b84358"),
			}
		"arcane":
			return {
				"amount": 38, "life": 0.84, "radius": 18.0,
				"direction": Vector3(0.0, -1.0, 0.0), "spread": 180.0,
				"speed_min": 32.0, "speed_max": 115.0,
				"gravity": Vector3(0.0, -18.0, 0.0),
				"scale_min": 0.04, "scale_max": 0.13,
				"hot": Color("#eadcff"), "tail": Color("#7654c8"),
			}
		"critical":
			return {
				"amount": 52, "life": 0.74, "radius": 22.0,
				"direction": Vector3(0.0, -1.0, 0.0), "spread": 180.0,
				"speed_min": 110.0, "speed_max": 330.0,
				"gravity": Vector3(0.0, 90.0, 0.0),
				"scale_min": 0.06, "scale_max": 0.18,
				"hot": Color("#fff4c2"), "tail": Color("#e95335"),
			}
		"impact", "hit":
			return {
				"amount": 38, "life": 0.62, "radius": 16.0,
				"direction": Vector3(0.0, -1.0, 0.0), "spread": 160.0,
				"speed_min": 80.0, "speed_max": 230.0,
				"gravity": Vector3(0.0, 150.0, 0.0),
				"scale_min": 0.05, "scale_max": 0.16,
				"hot": Color("#ffd0b0"), "tail": Color("#a92f48"),
			}
		"heal", "correct":
			return {
				"amount": 30, "life": 0.92, "radius": 20.0,
				"direction": Vector3(0.0, -1.0, 0.0), "spread": 52.0,
				"speed_min": 28.0, "speed_max": 95.0,
				"gravity": Vector3(0.0, -55.0, 0.0),
				"scale_min": 0.04, "scale_max": 0.12,
				"hot": Color("#f7ffd3"), "tail": Color("#54b98b"),
			}
		"incorrect":
			return {
				"amount": 24, "life": 0.72, "radius": 15.0,
				"direction": Vector3(0.0, 1.0, 0.0), "spread": 78.0,
				"speed_min": 55.0, "speed_max": 165.0,
				"gravity": Vector3(0.0, 165.0, 0.0),
				"scale_min": 0.04, "scale_max": 0.13,
				"hot": Color("#ffe0c8"), "tail": Color("#8f273c"),
			}
		"defeat":
			return {
				"amount": 38, "life": 1.25, "radius": 24.0,
				"direction": Vector3(0.0, -1.0, 0.0), "spread": 180.0,
				"speed_min": 18.0, "speed_max": 72.0,
				"gravity": Vector3(0.0, -12.0, 0.0),
				"scale_min": 0.035, "scale_max": 0.12,
				"hot": Color("#d8c7ec"), "tail": Color("#57445f"),
			}
		"spark", "forge_spark":
			return {
				"amount": 36, "life": 0.72, "radius": 10.0,
				"direction": Vector3(0.0, -1.0, 0.0), "spread": 82.0,
				"speed_min": 100.0, "speed_max": 235.0,
				"gravity": Vector3(0.0, 180.0, 0.0),
				"scale_min": 0.05, "scale_max": 0.14,
				"hot": Color("#fff0ad"), "tail": Color("#da542d"),
			}
		_:
			return {
				"amount": 28, "life": 0.65, "radius": 14.0,
				"direction": Vector3(0.0, -1.0, 0.0), "spread": 140.0,
				"speed_min": 60.0, "speed_max": 180.0,
				"gravity": Vector3(0.0, 80.0, 0.0),
				"scale_min": 0.05, "scale_max": 0.15,
				"hot": Color("#fff1bc"), "tail": Color("#b84358"),
			}


func _make_ramp(hot: Color, tail: Color) -> GradientTexture1D:
	var gradient := Gradient.new()
	gradient.offsets = PackedFloat32Array([0.0, 0.18, 0.68, 1.0])
	gradient.colors = PackedColorArray([
		Color.WHITE,
		hot,
		Color(tail.r, tail.g, tail.b, 0.82),
		Color(tail.r, tail.g, tail.b, 0.0),
	])
	var texture := GradientTexture1D.new()
	texture.gradient = gradient
	return texture


func _free_emitter(emitter: GPUParticles2D) -> void:
	if is_instance_valid(emitter):
		emitter.queue_free()
