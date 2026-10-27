class_name VFXTextures
extends RefCounted
## Texturas ligeras para el sistema de partículas. La estrella aporta chispas
## nítidas; el punto radial aporta brasas y halos suaves sin cargar otro PNG.

const STAR_PATH := "res://assets/art/effects/particle.png"


static func star() -> Texture2D:
	if ResourceLoader.exists(STAR_PATH):
		return load(STAR_PATH) as Texture2D
	return soft_dot()


static func soft_dot() -> GradientTexture2D:
	var gradient := Gradient.new()
	gradient.offsets = PackedFloat32Array([0.0, 0.28, 0.72, 1.0])
	gradient.colors = PackedColorArray([
		Color(1, 1, 1, 1),
		Color(1, 1, 1, 0.72),
		Color(1, 1, 1, 0.18),
		Color(1, 1, 1, 0),
	])
	var texture := GradientTexture2D.new()
	texture.gradient = gradient
	texture.width = 64
	texture.height = 64
	texture.fill = GradientTexture2D.FILL_RADIAL
	texture.fill_from = Vector2(0.5, 0.5)
	texture.fill_to = Vector2(1.0, 0.5)
	return texture
