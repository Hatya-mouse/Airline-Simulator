shader_type spatial;

uniform sampler2D albedo_noise;
uniform sampler2D alpha_noise;
uniform float fac;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	ALBEDO = textureLod(albedo_noise, UV, 0.0).rgb + 0.7;
	ALPHA = clamp(textureLod(alpha_noise, UV, 0.0).r - fac, 0.0, 1.0);
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
