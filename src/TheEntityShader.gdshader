// spatial is for 3D objects
shader_type spatial;
// unshaded means no lighting
// blend_mix means use alpha blending with the background
// depth_draw_never means don't draw in the depth buffer, needed for alpha blending
render_mode unshaded, blend_mix, depth_draw_never;

// hint_screen_texture means use the backbufer
// filter_linear_mipmap means use linear filtering for the screen texture
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
// increased distortion, more makes it easier to see
uniform float distortion_intensity : hint_range(0.0, 0.1) = 0.020;

// varying means the variable is passed from the vertex shader to the fragment shader
varying vec3 v_normal_view;
varying vec3 v_view_dir;

// act on verticies
void vertex() {
	v_normal_view = normalize(mat3(MODELVIEW_MATRIX) * NORMAL);
	v_view_dir = (MODELVIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

// act on pixels
void fragment() {
	// fresnel effect
	float facing_ratio = clamp(dot(v_normal_view, -normalize(v_view_dir)), 0.0, 1.0);
	vec2 pull_direction = normalize(v_normal_view.xy);

	vec2 warped_screen_uv = SCREEN_UV - (pull_direction * facing_ratio * distortion_intensity);

	// get the color from the screen texture at the warped uv
	ALBEDO = texture(SCREEN_TEXTURE, warped_screen_uv).rgb;
	// set the alpha to 1.0, fully opaque
	ALPHA = 1.0;
}