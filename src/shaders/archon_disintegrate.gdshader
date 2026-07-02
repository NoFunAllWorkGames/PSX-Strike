shader_type spatial;
render_mode depth_draw_always, cull_disabled;

uniform sampler2D albedo_texture : source_color, filter_nearest, repeat_enable;
uniform sampler3D noise_texture; 
uniform float tear_progress : hint_range(0.0, 1.0) = 0.0;
uniform float explosion_force = 2.0;
uniform vec3 random_seed;

varying vec3 original_local_pos;

void vertex() {
    // Save the original position of the vertex
    original_local_pos = VERTEX;

    // Use the normal as the displacement direction
    vec3 displacement_dir = normalize(NORMAL);

    // Displace using the static direction
    VERTEX += displacement_dir * tear_progress * explosion_force;
}

void fragment() {
    vec4 tex_color = texture(albedo_texture, UV);
    ALBEDO = tex_color.rgb;

    vec3 noise_coord = (original_local_pos * 2.0) + random_seed;

    float noise_val = texture(noise_texture, noise_coord).r;

    if (noise_val < tear_progress) {
        discard;
    }
}