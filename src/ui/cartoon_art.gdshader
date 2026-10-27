shader_type canvas_item;
// Tratamiento ilustrado sutil para el arte raster de Limits Breaker.
// No se aplica al texto ni a los controles: solo a fondos, retratos e iconos.

uniform float levels : hint_range(2.0, 16.0) = 10.0;
uniform float posterize_mix : hint_range(0.0, 1.0) = 0.55;
uniform float saturation : hint_range(0.0, 1.5) = 1.06;
uniform float edge_strength : hint_range(0.0, 1.0) = 0.22;
uniform float edge_threshold : hint_range(0.0, 0.5) = 0.075;
uniform float ink_width : hint_range(0.5, 8.0) = 3.0;
uniform vec4 ink_color : source_color = vec4(0.015, 0.02, 0.035, 1.0);
uniform float brightness : hint_range(0.5, 1.8) = 1.0;
uniform float shadow_lift : hint_range(0.0, 0.12) = 0.0;
uniform vec4 rim_color : source_color = vec4(0.72, 0.78, 0.92, 1.0);
uniform float rim_strength : hint_range(0.0, 1.0) = 0.0;

float luma(vec3 color) {
	return dot(color, vec3(0.299, 0.587, 0.114));
}

void fragment() {
	vec4 tint = COLOR;
	vec4 tex = texture(TEXTURE, UV);
	if (tex.a > 0.001) {
		vec3 color = tex.rgb;
		float gray = luma(color);
		color = mix(vec3(gray), color, saturation);

		vec3 posterized = floor(color * levels + 0.5) / levels;
		color = mix(color, posterized, posterize_mix);
		color = clamp(color * brightness + vec3(shadow_lift), 0.0, 1.0);

		// Los contornos se calculan en espacio de textura y se escalan con el raster.
		vec2 texel = vec2(ink_width) / vec2(textureSize(TEXTURE, 0));
		float lx = luma(texture(TEXTURE, UV + vec2(texel.x, 0.0)).rgb)
			- luma(texture(TEXTURE, UV - vec2(texel.x, 0.0)).rgb);
		float ly = luma(texture(TEXTURE, UV + vec2(0.0, texel.y)).rgb)
			- luma(texture(TEXTURE, UV - vec2(0.0, texel.y)).rgb);
		float ax = texture(TEXTURE, UV + vec2(texel.x, 0.0)).a
			- texture(TEXTURE, UV - vec2(texel.x, 0.0)).a;
		float ay = texture(TEXTURE, UV + vec2(0.0, texel.y)).a
			- texture(TEXTURE, UV - vec2(0.0, texel.y)).a;

		float edge = smoothstep(edge_threshold, edge_threshold * 2.2, length(vec2(lx, ly)));
		float alpha_edge = smoothstep(0.04, 0.16, length(vec2(ax, ay)));
		edge = max(edge, alpha_edge);
		color = mix(color, ink_color.rgb, edge * edge_strength);
		color = mix(color, rim_color.rgb, alpha_edge * rim_strength);

		COLOR = vec4(color, tex.a) * tint;
	} else {
		COLOR = tex * tint;
	}
}
