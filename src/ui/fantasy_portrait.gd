class_name FantasyPortrait
extends Control
## Retrato raster, con reserva de dibujo y efectos animados de pantalla.

const MediaManifest = preload("res://src/core/asset_manifest.gd")
const ToonArt = preload("res://src/ui/toon_art.gd")

const INK := Color("#111319")
const INK_HI := Color("#1c2028")
const STEEL := Color("#687382")
const STEEL_HI := Color("#aeb6bf")
const GOLD := Color("#d9ab52")
const GOLD_DARK := Color("#765b31")
const VIOLET := Color("#9575eb")
const BURGUNDY := Color("#8f3446")
const CLOTH := Color("#34303b")
const SKIN := Color("#b98267")
const OUTLINE := Color("#090a0d")

var portrait_id := "player"
var free_standing := false
var effect_id := ""
var effect_time := 0.0
var attack_tween: Tween
var portrait_texture: Texture2D
var effect_texture: Texture2D
var particle_emitter: CPUParticles2D
const EFFECT_DURATION := 0.48


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	ToonArt.apply(self, 10.0, 0.20, 4.0, 1.05)
	_setup_particles()
	resized.connect(_sync_particle_layout)
	_sync_particle_layout()
	_load_portrait()
	queue_redraw()


func configure(value: String) -> void:
	portrait_id = value.to_lower()
	_load_portrait()
	queue_redraw()


func set_free_standing(value: bool) -> void:
	free_standing = value
	queue_redraw()


func set_battle_readability(accent: Color) -> void:
	var portrait_shader := material as ShaderMaterial
	if portrait_shader == null:
		return
	portrait_shader.set_shader_parameter("brightness", 1.18)
	portrait_shader.set_shader_parameter("shadow_lift", 0.025)
	portrait_shader.set_shader_parameter("saturation", 1.14)
	portrait_shader.set_shader_parameter("rim_color", accent)
	portrait_shader.set_shader_parameter("rim_strength", 0.42)


func play_effect(value: String) -> void:
	effect_id = value.to_lower()
	var path := MediaManifest.effect_art(effect_id)
	effect_texture = load(path) as Texture2D if path != "" and ResourceLoader.exists(path) else null
	if bool(Game.settings.get("reduced_motion", false)):
		effect_time = 0.0
		if particle_emitter != null:
			particle_emitter.emitting = false
		queue_redraw()
		return
	effect_time = EFFECT_DURATION
	_configure_particles(effect_id)
	if particle_emitter != null:
		particle_emitter.restart()
	queue_redraw()


func play_lunge() -> void:
	if bool(Game.settings.get("reduced_motion", false)):
		return
	pivot_offset = size * 0.5
	if attack_tween != null and attack_tween.is_valid():
		attack_tween.kill()
	rotation = 0.0
	scale = Vector2.ONE
	attack_tween = create_tween()
	attack_tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	attack_tween.tween_property(self, "scale", Vector2(1.07, 0.94), 0.08)
	attack_tween.parallel().tween_property(self, "rotation", -0.045, 0.08)
	attack_tween.tween_property(self, "scale", Vector2.ONE, 0.18)
	attack_tween.parallel().tween_property(self, "rotation", 0.0, 0.18)


func _load_portrait() -> void:
	var path := MediaManifest.character_art(portrait_id)
	portrait_texture = load(path) as Texture2D if path != "" and ResourceLoader.exists(path) else null


func _setup_particles() -> void:
	var path := MediaManifest.effect_art("particle")
	if path == "" or not ResourceLoader.exists(path):
		return
	particle_emitter = CPUParticles2D.new()
	particle_emitter.name = "CombatParticles"
	particle_emitter.texture = load(path) as Texture2D
	particle_emitter.emitting = false
	particle_emitter.amount = 28
	particle_emitter.lifetime = 0.62
	particle_emitter.one_shot = true
	particle_emitter.explosiveness = 0.9
	particle_emitter.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	particle_emitter.emission_sphere_radius = 16.0
	particle_emitter.initial_velocity_min = 70.0
	particle_emitter.initial_velocity_max = 150.0
	particle_emitter.scale_amount_min = 0.16
	particle_emitter.scale_amount_max = 0.36
	particle_emitter.angular_velocity_min = -240.0
	particle_emitter.angular_velocity_max = 240.0
	particle_emitter.color = Color.WHITE
	particle_emitter.z_index = 4
	particle_emitter.local_coords = true
	add_child(particle_emitter)


func _sync_particle_layout() -> void:
	pivot_offset = size * 0.5
	if particle_emitter == null:
		return
	var side := minf(size.x, size.y)
	particle_emitter.position = size * 0.5
	particle_emitter.scale = Vector2.ONE * side / 128.0


func _configure_particles(value: String) -> void:
	if particle_emitter == null:
		return
	var primary := Color("#ffe9a8")
	var tail := Color("#a83f54")
	particle_emitter.amount = 22
	particle_emitter.lifetime = 0.48
	particle_emitter.emission_sphere_radius = 9.0
	particle_emitter.direction = Vector2(0.0, -1.0)
	particle_emitter.spread = 55.0
	particle_emitter.gravity = Vector2(0.0, 18.0)
	particle_emitter.initial_velocity_min = 65.0
	particle_emitter.initial_velocity_max = 145.0
	particle_emitter.scale_amount_min = 0.16
	particle_emitter.scale_amount_max = 0.34
	match value:
		"slash", "attack":
			primary = Color("#fff0ba")
			tail = Color("#b84358")
			particle_emitter.direction = Vector2(0.78, -0.55).normalized()
			particle_emitter.spread = 42.0
			particle_emitter.initial_velocity_min = 115.0
			particle_emitter.initial_velocity_max = 230.0
			particle_emitter.gravity = Vector2(0.0, 30.0)
		"arcane":
			primary = Color("#eadcff")
			tail = Color("#7654c8")
			particle_emitter.amount = 30
			particle_emitter.lifetime = 0.72
			particle_emitter.emission_sphere_radius = 14.0
			particle_emitter.spread = 180.0
			particle_emitter.initial_velocity_min = 38.0
			particle_emitter.initial_velocity_max = 118.0
			particle_emitter.gravity = Vector2(0.0, -8.0)
		"hit":
			primary = Color("#ffd3b8")
			tail = Color("#9a273c")
			particle_emitter.spread = 150.0
			particle_emitter.initial_velocity_min = 75.0
			particle_emitter.initial_velocity_max = 190.0
			particle_emitter.gravity = Vector2(0.0, 104.0)
		"heal":
			primary = Color("#f7ffd2")
			tail = Color("#75bb83")
			particle_emitter.amount = 26
			particle_emitter.lifetime = 0.76
			particle_emitter.emission_sphere_radius = 20.0
			particle_emitter.spread = 30.0
			particle_emitter.initial_velocity_min = 30.0
			particle_emitter.initial_velocity_max = 88.0
			particle_emitter.gravity = Vector2(0.0, -42.0)
		"spark":
			primary = Color("#fff0ad")
			tail = Color("#da542d")
			particle_emitter.amount = 34
			particle_emitter.emission_sphere_radius = 7.0
			particle_emitter.spread = 76.0
			particle_emitter.initial_velocity_min = 105.0
			particle_emitter.initial_velocity_max = 245.0
			particle_emitter.gravity = Vector2(0.0, 172.0)
		"correct":
			primary = Color("#f7ffda")
			tail = Color("#51b98b")
			particle_emitter.spread = 110.0
			particle_emitter.gravity = Vector2(0.0, 28.0)
		"incorrect":
			primary = Color("#ffe0c8")
			tail = Color("#a92f48")
			particle_emitter.direction = Vector2(0.0, 1.0)
			particle_emitter.spread = 72.0
			particle_emitter.gravity = Vector2(0.0, 112.0)
		"critical":
			primary = Color("#fff3bc")
			tail = Color("#f05b37")
			particle_emitter.amount = 38
			particle_emitter.spread = 180.0
			particle_emitter.initial_velocity_min = 120.0
			particle_emitter.initial_velocity_max = 250.0
		"defeat":
			primary = Color("#d8c7ec")
			tail = Color("#57445f")
			particle_emitter.amount = 18
			particle_emitter.lifetime = 0.9
			particle_emitter.spread = 180.0
			particle_emitter.initial_velocity_min = 15.0
			particle_emitter.initial_velocity_max = 48.0
			particle_emitter.gravity = Vector2(0.0, -12.0)
	_set_particle_ramp(primary, tail)


func _set_particle_ramp(primary: Color, tail: Color) -> void:
	var gradient := Gradient.new()
	gradient.offsets = PackedFloat32Array([0.0, 0.24, 0.66, 1.0])
	gradient.colors = PackedColorArray([
		Color.WHITE,
		primary,
		Color(tail.r, tail.g, tail.b, 0.78),
		Color(tail.r, tail.g, tail.b, 0.0),
	])
	particle_emitter.color_ramp = gradient


func _process(delta: float) -> void:
	if effect_time <= 0.0:
		return
	effect_time = maxf(0.0, effect_time - delta)
	if effect_time == 0.0:
		effect_id = ""
	queue_redraw()


func _draw() -> void:
	if size.x <= 0.0 or size.y <= 0.0:
		return
	var side := minf(size.x, size.y)
	var scale_factor := side / 128.0
	draw_set_transform(Vector2((size.x - side) * 0.5, (size.y - side) * 0.5), 0.0, Vector2.ONE * scale_factor)
	if portrait_texture != null:
		if MediaManifest.is_cutout_character_art(portrait_id):
			if free_standing:
				draw_texture_rect(portrait_texture, Rect2(Vector2.ZERO, Vector2(128, 128)), false)
			else:
				_draw_medallion()
				draw_texture_rect(portrait_texture, Rect2(Vector2(5, 5), Vector2(118, 118)), false)
		else:
			draw_texture_rect(portrait_texture, Rect2(Vector2.ZERO, Vector2(128, 128)), false)
	else:
		_draw_medallion()
		match portrait_id:
			"player":
				_draw_player()
			"skeleton":
				_draw_skeleton()
			"brigand":
				_draw_brigand()
			"warden":
				_draw_warden()
			"cultist":
				_draw_cultist()
			"colossus":
				_draw_colossus()
			"limitless":
				_draw_limitless()
			"blacksmith":
				_draw_blacksmith()
			"angel":
				_draw_angel()
			_:
				_draw_player()
	if effect_time > 0.0:
		_draw_effect()
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _draw_medallion() -> void:
	draw_circle(Vector2(64, 64), 57, Color("#08090c"))
	draw_circle(Vector2(64, 64), 53, Color("#20232b"))
	draw_circle(Vector2(64, 64), 49, Color("#15171d"))
	var accent := GOLD_DARK
	if portrait_id in ["cultist", "brigand"]:
		accent = BURGUNDY
	elif portrait_id in ["angel", "blacksmith"]:
		accent = GOLD
	elif portrait_id in ["limitless"]:
		accent = VIOLET
	draw_arc(Vector2(64, 64), 51, deg_to_rad(205.0), deg_to_rad(335.0), 32, accent, 2.0, true)
	draw_arc(Vector2(64, 64), 51, deg_to_rad(25.0), deg_to_rad(155.0), 32, Color("#414752"), 1.4, true)
	draw_circle(Vector2(64, 16), 2.2, GOLD if accent == GOLD else STEEL)
	draw_circle(Vector2(64, 112), 2.2, GOLD if accent == GOLD else STEEL)
	for x in [22.0, 106.0]:
		draw_circle(Vector2(x, 64), 1.6, Color("#68717e"))


func _draw_player() -> void:
	_draw_poly([Vector2(30, 118), Vector2(35, 83), Vector2(47, 72), Vector2(81, 72), Vector2(95, 84), Vector2(101, 118), Vector2(64, 126)], Color("#30343d"))
	_draw_poly([Vector2(42, 78), Vector2(52, 68), Vector2(76, 68), Vector2(88, 79), Vector2(81, 110), Vector2(64, 119), Vector2(47, 108)], Color("#4b3037"))
	_draw_poly([Vector2(25, 113), Vector2(35, 80), Vector2(48, 75), Vector2(53, 113), Vector2(44, 122)], Color("#242932"))
	_draw_poly([Vector2(103, 113), Vector2(94, 80), Vector2(81, 75), Vector2(76, 113), Vector2(85, 122)], Color("#242932"))
	_draw_poly([Vector2(40, 31), Vector2(50, 20), Vector2(68, 17), Vector2(86, 27), Vector2(94, 49), Vector2(87, 72), Vector2(77, 61), Vector2(48, 64), Vector2(37, 52)], Color("#171b22"))
	_draw_poly([Vector2(44, 42), Vector2(52, 31), Vector2(70, 30), Vector2(82, 39), Vector2(84, 57), Vector2(73, 68), Vector2(53, 66), Vector2(45, 57)], SKIN)
	_draw_poly([Vector2(43, 47), Vector2(53, 40), Vector2(71, 38), Vector2(83, 43), Vector2(82, 49), Vector2(62, 46), Vector2(47, 53)], Color("#191b21"), Color.TRANSPARENT)
	draw_line(Vector2(52, 53), Vector2(58, 53), GOLD, 2.2, true)
	draw_line(Vector2(70, 52), Vector2(76, 52), GOLD, 2.2, true)
	_draw_poly([Vector2(48, 73), Vector2(64, 82), Vector2(80, 73), Vector2(76, 95), Vector2(64, 104), Vector2(52, 94)], Color("#a8a08e"))
	_draw_poly([Vector2(56, 89), Vector2(64, 95), Vector2(72, 89), Vector2(69, 107), Vector2(64, 112), Vector2(59, 107)], GOLD_DARK)
	# Hoja corta junto al hombro, con una guarda de latón.
	_draw_poly([Vector2(25, 54), Vector2(31, 48), Vector2(40, 74), Vector2(35, 79)], Color("#bac0c7"))
	draw_line(Vector2(29, 69), Vector2(39, 66), GOLD, 3.0, true)
	draw_line(Vector2(30, 72), Vector2(25, 84), Color("#7b4d37"), 4.0, true)
	_draw_poly([Vector2(41, 78), Vector2(52, 73), Vector2(56, 88), Vector2(47, 94)], Color("#5b6470"))
	_draw_poly([Vector2(87, 78), Vector2(76, 73), Vector2(72, 88), Vector2(81, 94)], Color("#5b6470"))
	_draw_poly([Vector2(58, 115), Vector2(64, 108), Vector2(70, 115), Vector2(64, 121)], GOLD)


func _draw_skeleton() -> void:
	_draw_poly([Vector2(27, 119), Vector2(36, 83), Vector2(49, 72), Vector2(79, 72), Vector2(94, 84), Vector2(102, 119), Vector2(64, 125)], Color("#34363a"))
	draw_line(Vector2(43, 82), Vector2(84, 82), Color("#c7b997"), 5.0, true)
	draw_line(Vector2(47, 91), Vector2(80, 91), Color("#b7a886"), 4.0, true)
	draw_line(Vector2(50, 100), Vector2(77, 100), Color("#d0c3a5"), 4.0, true)
	draw_line(Vector2(54, 109), Vector2(73, 109), Color("#b7a886"), 4.0, true)
	for x in [53.0, 63.0, 73.0]:
		draw_line(Vector2(x, 84), Vector2(x - 3.0, 113), Color("#c8ba99"), 3.0, true)
	_draw_poly([Vector2(42, 37), Vector2(48, 25), Vector2(62, 20), Vector2(77, 24), Vector2(86, 35), Vector2(84, 58), Vector2(74, 72), Vector2(52, 70), Vector2(43, 58)], Color("#d2c7aa"))
	_draw_poly([Vector2(47, 47), Vector2(59, 43), Vector2(56, 54), Vector2(47, 56)], Color("#17171a"), Color.TRANSPARENT)
	_draw_poly([Vector2(69, 43), Vector2(82, 47), Vector2(80, 57), Vector2(70, 54)], Color("#17171a"), Color.TRANSPARENT)
	draw_circle(Vector2(52, 50), 2.2, BURGUNDY)
	draw_circle(Vector2(76, 50), 2.2, BURGUNDY)
	_draw_poly([Vector2(52, 61), Vector2(64, 66), Vector2(77, 60), Vector2(73, 72), Vector2(57, 72)], Color("#aaa083"))
	for x in [56.0, 64.0, 72.0]:
		draw_line(Vector2(x, 62), Vector2(x, 68), OUTLINE, 1.2, true)
	_draw_poly([Vector2(31, 82), Vector2(43, 73), Vector2(48, 85), Vector2(42, 96)], Color("#77704f"))
	_draw_poly([Vector2(96, 82), Vector2(84, 73), Vector2(80, 85), Vector2(87, 96)], Color("#77704f"))


func _draw_brigand() -> void:
	_draw_poly([Vector2(25, 119), Vector2(33, 86), Vector2(50, 73), Vector2(79, 74), Vector2(97, 87), Vector2(103, 119), Vector2(64, 126)], Color("#342a2c"))
	_draw_poly([Vector2(37, 83), Vector2(47, 73), Vector2(58, 81), Vector2(53, 111), Vector2(41, 119), Vector2(31, 108)], Color("#53403a"))
	_draw_poly([Vector2(92, 82), Vector2(81, 72), Vector2(70, 82), Vector2(75, 110), Vector2(89, 118), Vector2(100, 106)], Color("#45352f"))
	_draw_poly([Vector2(39, 31), Vector2(50, 20), Vector2(77, 20), Vector2(92, 34), Vector2(90, 56), Vector2(81, 68), Vector2(46, 67), Vector2(36, 52)], Color("#281f24"))
	_draw_poly([Vector2(45, 41), Vector2(55, 35), Vector2(75, 36), Vector2(84, 44), Vector2(80, 60), Vector2(69, 68), Vector2(53, 64), Vector2(45, 56)], SKIN.darkened(0.15))
	_draw_poly([Vector2(44, 48), Vector2(84, 45), Vector2(81, 59), Vector2(68, 65), Vector2(49, 60)], Color("#76313a"))
	draw_line(Vector2(52, 43), Vector2(59, 43), Color("#e6c786"), 2.0, true)
	draw_line(Vector2(72, 42), Vector2(79, 43), Color("#e6c786"), 2.0, true)
	_draw_poly([Vector2(33, 36), Vector2(42, 24), Vector2(57, 20), Vector2(78, 23), Vector2(92, 34), Vector2(79, 38), Vector2(60, 34), Vector2(43, 43)], Color("#51323b"))
	draw_line(Vector2(63, 51), Vector2(58, 58), Color("#2e2424"), 1.6, true)
	_draw_poly([Vector2(46, 75), Vector2(61, 71), Vector2(64, 82), Vector2(55, 91), Vector2(44, 86)], Color("#9b7948"))
	_draw_poly([Vector2(81, 77), Vector2(72, 73), Vector2(76, 94), Vector2(89, 103), Vector2(94, 92)], Color("#68707a"))
	draw_line(Vector2(84, 91), Vector2(99, 107), Color("#bec2c6"), 3.0, true)
	draw_line(Vector2(93, 102), Vector2(101, 99), GOLD, 3.0, true)


func _draw_warden() -> void:
	_draw_poly([Vector2(18, 120), Vector2(27, 82), Vector2(43, 71), Vector2(84, 71), Vector2(101, 83), Vector2(110, 120), Vector2(64, 127)], Color("#37404b"))
	_draw_poly([Vector2(26, 88), Vector2(45, 74), Vector2(52, 96), Vector2(42, 113), Vector2(24, 109)], Color("#737b83"))
	_draw_poly([Vector2(102, 88), Vector2(84, 74), Vector2(77, 96), Vector2(87, 113), Vector2(104, 109)], Color("#626d78"))
	_draw_poly([Vector2(41, 75), Vector2(50, 68), Vector2(78, 68), Vector2(88, 77), Vector2(82, 116), Vector2(64, 124), Vector2(46, 115)], Color("#78818a"))
	_draw_poly([Vector2(48, 84), Vector2(64, 77), Vector2(80, 84), Vector2(77, 107), Vector2(64, 114), Vector2(51, 107)], Color("#49545f"))
	_draw_poly([Vector2(40, 31), Vector2(48, 21), Vector2(78, 20), Vector2(88, 32), Vector2(87, 55), Vector2(78, 69), Vector2(50, 69), Vector2(41, 57)], Color("#87919a"))
	_draw_poly([Vector2(43, 38), Vector2(64, 24), Vector2(85, 37), Vector2(79, 53), Vector2(48, 54)], Color("#606a73"))
	_draw_poly([Vector2(46, 46), Vector2(82, 46), Vector2(77, 61), Vector2(64, 68), Vector2(51, 61)], Color("#242930"))
	draw_line(Vector2(50, 51), Vector2(78, 51), Color("#e4b457"), 2.0, true)
	_draw_poly([Vector2(60, 55), Vector2(68, 55), Vector2(65, 66)], Color("#969fa6"), Color.TRANSPARENT)
	draw_line(Vector2(64, 83), Vector2(64, 111), Color("#a6aeb4"), 2.0, true)
	_draw_poly([Vector2(56, 87), Vector2(64, 82), Vector2(72, 87), Vector2(64, 97)], GOLD_DARK)
	for x in [31.0, 97.0]:
		draw_circle(Vector2(x, 94), 2.0, GOLD)


func _draw_cultist() -> void:
	_draw_poly([Vector2(23, 121), Vector2(34, 82), Vector2(48, 73), Vector2(81, 73), Vector2(96, 83), Vector2(105, 121), Vector2(64, 127)], Color("#43242d"))
	_draw_poly([Vector2(36, 81), Vector2(49, 71), Vector2(55, 87), Vector2(48, 115), Vector2(35, 122), Vector2(28, 105)], Color("#612d3b"))
	_draw_poly([Vector2(92, 81), Vector2(79, 71), Vector2(73, 87), Vector2(81, 115), Vector2(94, 122), Vector2(101, 105)], Color("#4f2633"))
	_draw_poly([Vector2(37, 45), Vector2(46, 24), Vector2(64, 15), Vector2(83, 24), Vector2(92, 46), Vector2(84, 70), Vector2(64, 77), Vector2(43, 69)], Color("#301d28"))
	_draw_poly([Vector2(45, 40), Vector2(62, 34), Vector2(81, 41), Vector2(78, 61), Vector2(64, 70), Vector2(49, 61)], Color("#7d3445"))
	_draw_poly([Vector2(52, 43), Vector2(62, 47), Vector2(56, 53)], Color("#f0cf7a"), Color.TRANSPARENT)
	_draw_poly([Vector2(76, 43), Vector2(65, 47), Vector2(72, 54)], Color("#f0cf7a"), Color.TRANSPARENT)
	draw_line(Vector2(64, 50), Vector2(64, 63), Color("#391b28"), 2.0, true)
	_draw_poly([Vector2(57, 66), Vector2(64, 60), Vector2(71, 66), Vector2(67, 76), Vector2(61, 76)], GOLD_DARK)
	_draw_poly([Vector2(41, 31), Vector2(35, 45), Vector2(29, 38), Vector2(33, 27)], Color("#622b39"))
	_draw_poly([Vector2(86, 31), Vector2(94, 45), Vector2(100, 38), Vector2(95, 27)], Color("#622b39"))
	draw_line(Vector2(47, 89), Vector2(81, 89), Color("#a44854"), 1.5, true)
	draw_line(Vector2(50, 96), Vector2(77, 96), Color("#a44854"), 1.5, true)
	draw_circle(Vector2(64, 97), 3.0, VIOLET)


func _draw_colossus() -> void:
	_draw_poly([Vector2(8, 121), Vector2(17, 79), Vector2(37, 67), Vector2(90, 67), Vector2(111, 80), Vector2(121, 121), Vector2(64, 128)], Color("#46413c"))
	_draw_poly([Vector2(12, 87), Vector2(28, 69), Vector2(47, 79), Vector2(39, 109), Vector2(19, 113)], Color("#777068"))
	_draw_poly([Vector2(116, 87), Vector2(99, 69), Vector2(81, 79), Vector2(89, 109), Vector2(109, 113)], Color("#625e58"))
	_draw_poly([Vector2(41, 77), Vector2(64, 69), Vector2(86, 79), Vector2(91, 113), Vector2(64, 126), Vector2(36, 112)], Color("#514d4b"))
	_draw_poly([Vector2(41, 30), Vector2(49, 20), Vector2(65, 17), Vector2(80, 23), Vector2(88, 38), Vector2(84, 58), Vector2(70, 70), Vector2(49, 62), Vector2(39, 46)], Color("#c4b89b"))
	_draw_poly([Vector2(49, 42), Vector2(59, 40), Vector2(57, 52), Vector2(48, 54)], Color("#17191d"), Color.TRANSPARENT)
	_draw_poly([Vector2(68, 40), Vector2(80, 43), Vector2(78, 54), Vector2(68, 52)], Color("#17191d"), Color.TRANSPARENT)
	draw_circle(Vector2(53, 48), 2.4, BURGUNDY)
	draw_circle(Vector2(74, 48), 2.4, BURGUNDY)
	_draw_poly([Vector2(50, 58), Vector2(64, 64), Vector2(77, 58), Vector2(73, 68), Vector2(57, 69)], Color("#786f5c"))
	_draw_poly([Vector2(44, 33), Vector2(27, 20), Vector2(32, 42), Vector2(43, 49)], Color("#807462"))
	_draw_poly([Vector2(82, 33), Vector2(101, 18), Vector2(95, 43), Vector2(84, 50)], Color("#6f6659"))
	_draw_poly([Vector2(52, 83), Vector2(64, 76), Vector2(77, 84), Vector2(72, 102), Vector2(64, 108), Vector2(55, 101)], Color("#28282b"))
	_draw_poly([Vector2(60, 83), Vector2(64, 78), Vector2(68, 83), Vector2(64, 100)], GOLD_DARK)
	_draw_poly([Vector2(18, 76), Vector2(29, 67), Vector2(37, 83), Vector2(29, 96)], Color("#8d8068"))
	_draw_poly([Vector2(110, 76), Vector2(99, 67), Vector2(91, 83), Vector2(99, 96)], Color("#756d60"))


func _draw_limitless() -> void:
	_draw_poly([Vector2(18, 122), Vector2(28, 80), Vector2(43, 70), Vector2(84, 70), Vector2(101, 83), Vector2(110, 122), Vector2(64, 128)], Color("#24212f"))
	_draw_poly([Vector2(34, 35), Vector2(48, 17), Vector2(72, 15), Vector2(94, 35), Vector2(88, 61), Vector2(73, 77), Vector2(48, 68), Vector2(34, 55)], Color("#100f18"))
	_draw_poly([Vector2(44, 35), Vector2(63, 27), Vector2(81, 38), Vector2(79, 59), Vector2(63, 69), Vector2(47, 60)], Color("#d5d0c2"))
	_draw_poly([Vector2(45, 38), Vector2(63, 31), Vector2(63, 67), Vector2(47, 60)], Color("#8d8990"), Color.TRANSPARENT)
	_draw_poly([Vector2(48, 44), Vector2(58, 40), Vector2(56, 49), Vector2(47, 51)], VIOLET, Color.TRANSPARENT)
	_draw_poly([Vector2(68, 41), Vector2(79, 45), Vector2(76, 52), Vector2(68, 50)], Color("#bd4766"), Color.TRANSPARENT)
	draw_line(Vector2(63, 29), Vector2(59, 48), Color("#312838"), 2.0, true)
	draw_line(Vector2(60, 51), Vector2(69, 58), Color("#312838"), 1.7, true)
	_draw_poly([Vector2(35, 25), Vector2(25, 13), Vector2(30, 37), Vector2(40, 42)], Color("#252037"))
	_draw_poly([Vector2(89, 24), Vector2(103, 9), Vector2(96, 38), Vector2(86, 43)], Color("#221e33"))
	_draw_poly([Vector2(43, 78), Vector2(60, 72), Vector2(65, 84), Vector2(57, 99), Vector2(42, 91)], Color("#45384d"))
	_draw_poly([Vector2(84, 76), Vector2(69, 73), Vector2(65, 90), Vector2(79, 101), Vector2(91, 88)], Color("#312a43"))
	draw_arc(Vector2(64, 58), 48, deg_to_rad(210), deg_to_rad(325), 28, Color(0.58, 0.38, 0.92, 0.8), 2.2, true)


func _draw_blacksmith() -> void:
	_draw_poly([Vector2(24, 120), Vector2(33, 84), Vector2(47, 73), Vector2(81, 73), Vector2(96, 84), Vector2(105, 120), Vector2(64, 127)], Color("#4d4037"))
	_draw_poly([Vector2(38, 82), Vector2(48, 73), Vector2(56, 87), Vector2(50, 113), Vector2(35, 119)], Color("#755438"))
	_draw_poly([Vector2(90, 82), Vector2(80, 73), Vector2(72, 87), Vector2(78, 113), Vector2(93, 119)], Color("#654a35"))
	_draw_poly([Vector2(40, 36), Vector2(48, 23), Vector2(64, 18), Vector2(80, 24), Vector2(88, 40), Vector2(83, 59), Vector2(74, 69), Vector2(51, 68), Vector2(42, 57)], SKIN)
	_draw_poly([Vector2(38, 39), Vector2(44, 25), Vector2(60, 17), Vector2(80, 24), Vector2(91, 40), Vector2(84, 44), Vector2(77, 34), Vector2(54, 34), Vector2(44, 47)], Color("#c1a174"))
	_draw_poly([Vector2(46, 54), Vector2(54, 61), Vector2(64, 58), Vector2(75, 61), Vector2(81, 53), Vector2(77, 71), Vector2(64, 81), Vector2(51, 72)], Color("#564037"))
	draw_line(Vector2(51, 47), Vector2(58, 47), OUTLINE, 2.0, true)
	draw_line(Vector2(70, 47), Vector2(77, 47), OUTLINE, 2.0, true)
	draw_circle(Vector2(55, 49), 1.6, GOLD)
	draw_circle(Vector2(73, 49), 1.6, GOLD)
	_draw_poly([Vector2(45, 78), Vector2(64, 83), Vector2(83, 78), Vector2(89, 118), Vector2(39, 118)], Color("#64402e"))
	_draw_poly([Vector2(57, 87), Vector2(72, 87), Vector2(78, 118), Vector2(51, 118)], Color("#72543a"))
	_draw_poly([Vector2(28, 69), Vector2(35, 64), Vector2(48, 70), Vector2(44, 77), Vector2(32, 77)], Color("#7c858d"))
	draw_line(Vector2(31, 67), Vector2(23, 51), Color("#725139"), 4.0, true)
	_draw_poly([Vector2(14, 45), Vector2(33, 43), Vector2(31, 53), Vector2(11, 54)], STEEL_HI)
	draw_line(Vector2(48, 94), Vector2(80, 94), GOLD_DARK, 2.0, true)
	draw_circle(Vector2(64, 102), 4.0, Color("#b54c36"))


func _draw_angel() -> void:
	draw_arc(Vector2(64, 30), 23, deg_to_rad(202), deg_to_rad(338), 32, GOLD, 3.2, true)
	draw_arc(Vector2(64, 30), 23, deg_to_rad(22), deg_to_rad(158), 32, Color("#f6dfaa"), 2.0, true)
	_draw_poly([Vector2(25, 81), Vector2(12, 64), Vector2(19, 43), Vector2(34, 54), Vector2(44, 78)], Color("#ddd6c9"))
	_draw_poly([Vector2(103, 81), Vector2(116, 64), Vector2(109, 43), Vector2(94, 54), Vector2(84, 78)], Color("#bdb6aa"))
	for i in range(3):
		draw_line(Vector2(18 + i * 5, 54 + i * 4), Vector2(37 + i * 2, 75 + i * 2), Color("#f0e8d4"), 1.5, true)
		draw_line(Vector2(110 - i * 5, 54 + i * 4), Vector2(91 - i * 2, 75 + i * 2), Color("#e9e0cd"), 1.5, true)
	_draw_poly([Vector2(30, 119), Vector2(42, 76), Vector2(54, 67), Vector2(74, 67), Vector2(87, 76), Vector2(98, 119), Vector2(64, 126)], Color("#e4ded3"))
	_draw_poly([Vector2(46, 79), Vector2(64, 86), Vector2(82, 79), Vector2(77, 119), Vector2(64, 126), Vector2(51, 119)], Color("#b9b5b3"))
	_draw_poly([Vector2(41, 37), Vector2(49, 24), Vector2(64, 20), Vector2(79, 24), Vector2(87, 37), Vector2(84, 56), Vector2(73, 68), Vector2(55, 68), Vector2(44, 57)], Color("#d6a77f"))
	_draw_poly([Vector2(44, 38), Vector2(50, 25), Vector2(64, 21), Vector2(79, 27), Vector2(85, 43), Vector2(77, 38), Vector2(68, 41), Vector2(51, 37)], Color("#e0c38a"))
	draw_line(Vector2(51, 48), Vector2(58, 48), Color("#745948"), 1.8, true)
	draw_line(Vector2(70, 48), Vector2(77, 48), Color("#745948"), 1.8, true)
	draw_circle(Vector2(55, 49), 1.2, Color("#fff1c9"))
	draw_circle(Vector2(73, 49), 1.2, Color("#fff1c9"))
	_draw_poly([Vector2(57, 77), Vector2(64, 70), Vector2(71, 77), Vector2(67, 94), Vector2(64, 99), Vector2(60, 94)], GOLD)
	_draw_poly([Vector2(57, 99), Vector2(64, 93), Vector2(71, 99), Vector2(64, 109)], Color("#f5e3b2"))


func _draw_effect() -> void:
	var progress := 1.0 - effect_time / EFFECT_DURATION
	var alpha := clampf(1.0 - progress, 0.0, 1.0)
	if effect_texture != null:
		var effect_scale := lerpf(0.68, 1.18, progress)
		var effect_size := Vector2.ONE * 128.0 * effect_scale
		var effect_rect := Rect2((Vector2.ONE * 128.0 - effect_size) * 0.5, effect_size)
		draw_texture_rect(effect_texture, effect_rect, false, Color(1, 1, 1, alpha))
		return
	match effect_id:
		"slash", "attack":
			draw_line(Vector2(30, 91), Vector2(100, 31), Color(0.96, 0.87, 0.64, alpha), 5.0 * (1.0 - progress * 0.45), true)
			draw_line(Vector2(35, 98), Vector2(106, 38), Color(0.78, 0.34, 0.42, alpha * 0.75), 2.0, true)
		"arcane":
			draw_arc(Vector2(64, 63), lerpf(20.0, 58.0, progress), 0.0, TAU, 48, Color(VIOLET, alpha), 4.0 * (1.0 - progress * 0.55), true)
			draw_circle(Vector2(64, 63), lerpf(9.0, 26.0, progress), Color(VIOLET.r, VIOLET.g, VIOLET.b, alpha * 0.11))
		"hit":
			draw_arc(Vector2(64, 63), lerpf(23.0, 53.0, progress), 0.0, TAU, 40, Color(0.88, 0.28, 0.32, alpha), 4.0, true)
			draw_line(Vector2(40, 42), Vector2(86, 84), Color(1.0, 0.6, 0.54, alpha), 2.0, true)
		"heal":
			draw_arc(Vector2(64, 63), lerpf(19.0, 54.0, progress), 0.0, TAU, 40, Color(GOLD, alpha), 3.0, true)
			draw_rect(Rect2(60, 39, 8, 48), Color(1.0, 0.88, 0.59, alpha))
			draw_rect(Rect2(40, 59, 48, 8), Color(1.0, 0.88, 0.59, alpha))
		"spark":
			for i in range(7):
				var angle := TAU * float(i) / 7.0 + progress * 0.4
				var center := Vector2(64, 70) + Vector2(cos(angle), sin(angle)) * lerpf(14.0, 48.0, progress)
				draw_circle(center, lerpf(3.0, 1.0, progress), Color(1.0, 0.68, 0.3, alpha))


func _draw_poly(points: Array, fill: Color, stroke: Color = OUTLINE, width: float = 2.0) -> void:
	if points.size() < 3:
		return
	var shape := PackedVector2Array()
	for point in points:
		shape.append(point)
	draw_colored_polygon(shape, fill)
	if stroke.a > 0.0:
		shape.append(points[0])
		draw_polyline(shape, stroke, width, true)
