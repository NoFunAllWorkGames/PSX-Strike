shader_type spatial;
render_mode unshaded, blend_mix, depth_draw_never;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear;

void fragment() {
	ALBEDO = texture(SCREEN_TEXTURE, SCREEN_UV + NORMAL.xy).rgb * 2.0;
	ALPHA = dot(NORMAL, VIEW) * 0.2;
}
