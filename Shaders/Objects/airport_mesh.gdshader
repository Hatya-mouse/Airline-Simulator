shader_type spatial;
render_mode unshaded;

uniform sampler2D normal_texture;
uniform sampler2D selected_texture;
uniform int selected_index;

// Transform of the main camera.
uniform mat4 camera_transform;

varying flat int instance_idx;

void vertex() {
    mat3 billboard_rotation = mat3(camera_transform);
    VERTEX = billboard_rotation * VERTEX;

    // Get the instance index of multimesh.
    instance_idx = int(INSTANCE_CUSTOM.x);
}

void fragment() {
    vec4 tex_color = texture(normal_texture, UV);
    if (instance_idx == selected_index) {
        tex_color = texture(selected_texture, UV);
    }
    ALBEDO = tex_color.rgb;
    ALPHA = tex_color.a;
}
