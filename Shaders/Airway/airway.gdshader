shader_type spatial;
render_mode unshaded, cull_disabled;

uniform sampler2D line_texture;
uniform sampler2D arrow_texture;
uniform vec4 color: source_color;
uniform float alpha = 1.0;
uniform vec2 move_direction;
uniform float scale_factor = 1.0;
uniform float arrow_density = 0.1;
uniform float arrow_show_distance = 0.5;
uniform float line_width_decay = 8.0;

uniform bool is_preview = false;

uniform float depth;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	// Adjust the size of the line in order to make the line width same wherever looking from, depending on the distance to the camera
	// (scale_factor / depth): Scale UV using inverse proportion.
	float uv_multiply = scale_factor / depth + line_width_decay;
	float centerer = (uv_multiply / 2.0) - 0.5;

	vec2 line_uv = UV;
	line_uv.x = UV.x * uv_multiply - centerer;
	line_uv = clamp(line_uv, 0.0, 1.0);

	vec2 arrow_uv = UV;
	float arrow_uv_x = clamp(arrow_uv.x * uv_multiply - centerer, 0.0, 1.0);

	// Change the number of arrows depending on the distance to the camera
	float arrow_show_factor = arrow_show_distance;
	if (is_preview) arrow_show_factor *= 2.0;
	float arrow_number = round(uv_multiply * arrow_density * arrow_show_factor);

	// Calculate the arrow UV
	float arrow_uv_y = mod(arrow_uv.y * arrow_number, 1.0);
	arrow_uv = vec2(arrow_uv_x, arrow_uv_y);

	// Animate the arrow if there's arrow
	if (abs(arrow_number) > 0.0) arrow_uv = arrow_uv - move_direction * TIME;

	float line_alpha = textureLod(line_texture, line_uv, 0.0).a;
	float arrow_alpha = textureLod(arrow_texture, arrow_uv, 0.0).a;
	ALBEDO = color.rgb;
	ALPHA = clamp(line_alpha + arrow_alpha, 0.0, 1.0) * alpha;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
