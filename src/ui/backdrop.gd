class_name Backdrop
extends Control
## Fondo atmosférico dibujado por código: piedra, arcos y resplandor arcano.

const MediaManifest = preload("res://src/core/asset_manifest.gd")
const VFXTexturesLib = preload("res://src/ui/vfx_textures.gd")

var glow := 0.55
var accent := UIKit.VIOLET
var world_id := "menu"
var _t := 0.0
var _dust: Array = []
var _embers: GPUParticles2D
var artwork: TextureRect


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	artwork = TextureRect.new()
	artwork.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	artwork.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	artwork.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	artwork.mouse_filter = Control.MOUSE_FILTER_IGNORE
	artwork.modulate = Color(1, 1, 1, 0.42)
	add_child(artwork)
	_setup_embers()
	resized.connect(_sync_embers)
	var rng := RandomNumberGenerator.new()
	rng.seed = 4242
	for i in range(46):
		_dust.append({
			"x": rng.randf(),
			"y": rng.randf(),
			"r": rng.randf_range(0.6, 2.2),
			"v": rng.randf_range(0.004, 0.018),
			"a": rng.randf_range(0.08, 0.35),
		})
	set_environment("menu")


func _setup_embers() -> void:
	_embers = GPUParticles2D.new()
	_embers.texture = VFXTexturesLib.soft_dot()
	_embers.amount = 30
	_embers.lifetime = 8.5
	_embers.preprocess = 4.0
	_embers.local_coords = false
	_embers.z_index = 1
	_embers.visibility_rect = Rect2(Vector2(-900, -900), Vector2(1800, 1800))
	var material := CanvasItemMaterial.new()
	material.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	_embers.material = material
	var process := ParticleProcessMaterial.new()
	process.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	process.emission_box_extents = Vector3(650, 12, 1)
	process.direction = Vector3(0, -1, 0)
	process.spread = 24.0
	process.initial_velocity_min = 7.0
	process.initial_velocity_max = 24.0
	process.gravity = Vector3(0, -5, 0)
	process.scale_min = 0.035
	process.scale_max = 0.13
	process.angle_min = -180.0
	process.angle_max = 180.0
	process.angular_velocity_min = -35.0
	process.angular_velocity_max = 35.0
	process.color = Color.WHITE
	_embers.process_material = process
	add_child(_embers)
	_sync_embers()


func _sync_embers() -> void:
	if _embers == null:
		return
	var w := maxf(size.x, 1280.0)
	var h := maxf(size.y, 720.0)
	_embers.position = Vector2(w * 0.5, h + 16.0)
	_embers.visibility_rect = Rect2(Vector2(-w * 0.7, -h * 1.25), Vector2(w * 1.4, h * 1.4))
	var process := _embers.process_material as ParticleProcessMaterial
	if process != null:
		process.emission_box_extents = Vector3(w * 0.52, 12, 1)
	_embers.modulate = Color(1, 1, 1, 0.0 if bool(Game.settings.get("reduced_motion", false)) else 0.62)


func _ember_ramp(color: Color) -> GradientTexture1D:
	var hot := color.lightened(0.35)
	var gradient := Gradient.new()
	gradient.offsets = PackedFloat32Array([0.0, 0.16, 0.72, 1.0])
	gradient.colors = PackedColorArray([
		Color(color.r, color.g, color.b, 0.0),
		Color(hot.r, hot.g, hot.b, color.a * 0.9),
		Color(color.r, color.g, color.b, color.a * 0.72),
		Color(color.r, color.g, color.b, 0.0),
	])
	var texture := GradientTexture1D.new()
	texture.gradient = gradient
	return texture


func set_environment(scene_id: String) -> void:
	if artwork == null:
		return
	world_id = scene_id
	var path := MediaManifest.environment(scene_id)
	if path != "" and ResourceLoader.exists(path):
		artwork.texture = load(path) as Texture2D
		artwork.visible = artwork.texture != null
	else:
		artwork.texture = null
		artwork.visible = false
	artwork.modulate = Color(1, 1, 1, 0.42)
	accent = UIKit.VIOLET
	if scene_id in ["forge", "angel"]:
		accent = UIKit.GOLD
	elif scene_id == "death":
		accent = UIKit.BURGUNDY_HI
	glow = 0.48 if scene_id == "death" else 0.58
	_refresh_embers()
	queue_redraw()


func set_world(world: Dictionary) -> void:
	if artwork == null:
		return
	set_environment(String(world.get("environment", "dungeon")))
	world_id = String(world.get("id", world_id))
	var tint := Color(String(world.get("tint", "#ffffff")))
	artwork.modulate = Color(tint.r, tint.g, tint.b, 0.42)
	accent = Color(String(world.get("accent", UIKit.VIOLET)))
	glow = float(world.get("glow", 0.58))
	_refresh_embers()
	queue_redraw()


func set_artwork_opacity(value: float) -> void:
	if artwork == null:
		return
	var tint := artwork.modulate
	tint.a = clampf(value, 0.0, 1.0)
	artwork.modulate = tint


func set_artwork_readability(brightness: float = 1.18, shadow_lift: float = 0.025, saturation: float = 1.08) -> void:
	if artwork == null:
		return
	var art_shader := artwork.material as ShaderMaterial
	if art_shader == null:
		return
	art_shader.set_shader_parameter("brightness", clampf(brightness, 0.5, 1.8))
	art_shader.set_shader_parameter("shadow_lift", clampf(shadow_lift, 0.0, 0.12))
	art_shader.set_shader_parameter("saturation", clampf(saturation, 0.0, 1.5))


func _refresh_embers() -> void:
	if _embers == null:
		return
	var process := _embers.process_material as ParticleProcessMaterial
	if process != null:
		process.color_ramp = _ember_ramp(accent)


func _process(delta: float) -> void:
	var reduced := bool(Game.settings.get("reduced_motion", false))
	if _embers != null:
		_embers.visible = not reduced
		_embers.emitting = not reduced
	if reduced:
		return
	_t += delta
	for d in _dust:
		d["y"] = fmod(float(d["y"]) + float(d["v"]) * delta, 1.0)
	queue_redraw()


func _draw() -> void:
	var w := size.x
	var h := size.y
	# gradiente vertical
	var steps := 24
	for i in range(steps):
		var k := float(i) / float(steps - 1)
		var col := UIKit.BG_DEEP.lerp(UIKit.BG, k)
		draw_rect(Rect2(0, h * k, w, h / float(steps) + 2.0), col)
	# resplandor central
	var center := Vector2(w * 0.5, h * 0.52)
	var glow_col := accent
	for i in range(10):
		var r := (0.10 + float(i) * 0.055) * minf(w, h)
		var a := glow * 0.035 * (1.0 - float(i) / 10.0)
		draw_circle(center, r, Color(glow_col.r, glow_col.g, glow_col.b, a))
	# pilares y arcos
	var pillar_w := w * 0.075
	var y_base := h * 0.98
	for side in [-1, 1]:
		var x := w * 0.5 + float(side) * w * 0.40
		draw_rect(Rect2(x - pillar_w * 0.5, h * 0.06, pillar_w, h * 0.92), Color(0.035, 0.04, 0.05, 0.95))
		draw_rect(Rect2(x - pillar_w * 0.5, h * 0.06, pillar_w * 0.18, h * 0.92), Color(0.06, 0.065, 0.08, 0.9))
	# arco superior
	var arc_col := Color(0.05, 0.055, 0.07, 0.95)
	draw_rect(Rect2(w * 0.10, 0, w * 0.80, h * 0.055), arc_col)
	# suelo
	draw_rect(Rect2(0, y_base - h * 0.06, w, h * 0.06), Color(0.03, 0.033, 0.04, 1.0))
	# polvo
	for d in _dust:
		var p := Vector2(float(d["x"]) * w, float(d["y"]) * h)
		draw_circle(p, float(d["r"]), Color(accent.r, accent.g, accent.b, float(d["a"]) * 0.42))
