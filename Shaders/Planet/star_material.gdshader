shader_type sky;

uniform vec2 resolution = vec2(600.0, 400.0);
uniform sampler2D noise_texture : filter_nearest, repeat_enable;
uniform float density : hint_range(1.0, 100.0, 0.1) = 20.0;

void sky() {
	vec2 uv = SKY_COORDS;
	uv.x *= resolution.x / resolution.y;
	float stars = 0.0;
	stars += step(0.2, pow(textureLod(noise_texture, uv, 0.0).r, density));
	COLOR = vec3(stars);
}
