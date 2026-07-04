shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform float blur_amount : hint_range(0.0, 10.0) = 2.0;

void fragment() {
    vec4 blurred_color = texture(screen_texture, SCREEN_UV, blur_amount);
    
    // Output the RGB values, setting alpha to 1.0 (fully opaque)
    // or mix with a tint color if desired.
    COLOR = vec4(blurred_color.rgb, 1.0);
}   