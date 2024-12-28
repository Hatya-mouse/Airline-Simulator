shader_type spatial;

uniform sampler2D heightmap_texture;
uniform float displacement_factor;

uniform vec3 sun_position;

uniform sampler2D color_texture;
uniform sampler2D specular_texture;
uniform sampler2D nightlight_texture;
uniform vec3 nightlight_color : source_color;

void vertex() {
	// Called for every vertex the material is visible on.
	vec3 height = textureLod(heightmap_texture, UV, 0.0).rgb;
	VERTEX += height * NORMAL * displacement_factor;
}

void fragment() {
	// Called for every pixel the material is visible on.
	vec3 color = textureLod(color_texture, UV, 0.0).rgb;
	vec3 adjusted_color = vec3((color.r + color.g + color.b) / 3.0);

	float roughness = 1.0 - textureLod(specular_texture, UV, 0.0).r;
	ROUGHNESS = roughness;

	vec3 sun_direction = normalize(NODE_POSITION_WORLD - sun_position);
	vec3 world_normal = (INV_VIEW_MATRIX * vec4(NORMAL, 0.0)).xyz;
	float dot_product = dot(sun_direction, world_normal);
	float angle = acos(dot_product) * 180.0 / PI;
	float nightlight_factor = (clamp(angle, 83.0, 91.0) - 83.0) / 8.0;
	nightlight_factor = 1.0 - nightlight_factor;
	vec3 nightlight = nightlight_color * textureLod(nightlight_texture, UV, 0.0).r;

	color = mix(color, adjusted_color, clamp(1.0 - roughness, 0.0, 0.2));
	ALBEDO = color;
	EMISSION = nightlight * nightlight_factor;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
