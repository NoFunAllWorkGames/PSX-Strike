shader_type spatial;

// Render modes change how Godot draws this material:
// - unshaded: Ignore scene lights. Output color comes only from this shader
// - blend_mix: allow transparency by blending with whatever was drawn behind this pixel
// - depth_draw_never: Not write depth. Keep the see-through refraction look from fighting the depth buffer
render_mode unshaded, blend_mix, depth_draw_never;

// Copy current view texture
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

// How strong the screen warp is
uniform float distortion_intensity : hint_range(0.0, 0.1) = 0.020;

// "Varying" values are computed once per vertex, then interpolated across each triangle
// and delivered to every pixel inside that triangle
varying vec3 v_normal_view; // surface normal, in view/camera space
varying vec3 v_view_dir;    // direction from this point toward the camera, in view space

// Runs for each vertex (duh)
// Prepare data the fragment shader needs for every pixel
void vertex() {
	// Convert the mesh normal from object space into camera/view space
	v_normal_view = normalize(mat3(MODELVIEW_MATRIX) * NORMAL);

	// Convert vertex position into view space 
	// Position relative to the camera
	v_view_dir = (MODELVIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

// Runs once per pixel
void fragment() {
	// Fresnel
	// surfaces facing the camera stay, edges distort more
	// dot(a, b) measures how aligned two directions are
	// 1 = same direction, 0 = perpendicular
	float facing_ratio = clamp(dot(v_normal_view, -normalize(v_view_dir)), 0.0, 1.0);

	// Use the normals screen-space direction as the warp direction
	vec2 pull_direction = normalize(v_normal_view.xy);

	// Start from the screen UV for this pixel, then offset it to pull the background image
	// Stronger at the edges because of facing_ratio
	vec2 warped_screen_uv = SCREEN_UV - (pull_direction * facing_ratio * distortion_intensity);

	// apply the distortion
	ALBEDO = texture(SCREEN_TEXTURE, warped_screen_uv).rgb;

	ALPHA = 1.0;
}
