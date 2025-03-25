shader_type spatial;
render_mode unshaded;

uniform sampler2D alpha_texture;
uniform vec4 color: source_color;

uniform float scale_factor = 0.5;
uniform float min_depth = 0.02;
uniform float max_depth = 1.0;
uniform float depth;

void vertex() {
	// Called for every vertex the material is visible on.
	// Clamp the depth
	float clamped_depth = clamp(depth, min_depth, max_depth);
	// Calculate the scale
	float distance_scale = 1.0 / clamped_depth;
	// Apply scaling
	MODELVIEW_MATRIX[3].xyz *= scale_factor * distance_scale;
}

void fragment() {
	// Calculate transparency
	float alpha = textureLod(alpha_texture, UV, 0.0).a;
	// Set the color
	ALBEDO = color.rgb;
	ALPHA = alpha * color.a;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
