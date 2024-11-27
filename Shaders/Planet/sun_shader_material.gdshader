shader_type spatial;

uniform sampler2D sun_surface;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec3 albedo = textureLod(sun_surface, UV, 0.0).rgb;
	ALBEDO = albedo;
	EMISSION = albedo * 10.0;
	// Called for every pixel the material is visible on.
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
