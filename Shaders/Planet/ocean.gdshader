shader_type spatial;

uniform sampler2D noise1;
uniform sampler2D noise2;
uniform vec3 oceanColor1: source_color;
uniform vec3 oceanColor2: source_color;

void vertex() {
	// Called for every vertex the material is visible on.
	//vec3 blend = mix(texture(noise2, UV).rgb, texture(noise2, UV).rgb, 0.5);
	//VERTEX.y += pow(blend.r, 2) * 10.0;
}

void fragment() {
	// Called for every pixel the material is visible on.
	vec3 blend = mix(texture(noise2, UV).rgb, texture(noise2, UV).rgb, 0.5);
	ALBEDO = oceanColor1;
	METALLIC = 0.0;
	ROUGHNESS = 0.02;
	NORMAL_MAP = blend;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
