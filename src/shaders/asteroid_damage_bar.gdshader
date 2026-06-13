shader_type spatial;

// Render modes change how Godot draws this material:
// - unshaded: ignore scene lights; bar colors stay flat and consistent
// - cull_disabled: draw both front and back faces (safe for a camera-facing quad)
// - depth_draw_opaque: write depth so the bar sorts correctly against nearby geometry
// - blend_mix: allow transparent pixels (used for the empty part of the bar)
render_mode unshaded, cull_disabled, depth_draw_opaque, blend_mix;

// Per-asteroid value, set from GDScript via set_instance_shader_parameter().
// "instance uniform" means every bar shares this shader, but each can have its own health value.
// 0.0 = empty, 1.0 = full.
instance uniform float health_percentage : hint_range(0.0, 1.0) = 1.0;

// Shared colors for all asteroid bars (same material resource on every instance).
uniform vec4 fill_color : source_color = vec4(0.0, 1.0, 0.0, 1.0);   // remaining health
uniform vec4 bg_color : source_color = vec4(0.0, 0.0, 0.0, 0.0);      // lost health (transparent)
uniform vec4 border_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);  // frame around the bar
uniform vec2 border_size = vec2(0.02, 0.08); // border thickness in UV space (0-1 across the quad)

// Vertex shader: runs for each corner of the quad mesh.
// Makes the bar always face the camera (billboarding) without GDScript _process().
void vertex() {
	// MODEL_MATRIX  = where this quad is in the world (parent asteroid position + local offset + scale)
	// VIEW_MATRIX   = camera orientation/position
	// MODELVIEW_MATRIX = combined transform Godot uses to place vertices on screen
	MODELVIEW_MATRIX = VIEW_MATRIX * MODEL_MATRIX;

	// A transform matrix has 4 columns:
	//   [0] local X axis (width direction + width scale)
	//   [1] local Y axis (height direction + height scale)
	//   [2] local Z axis (depth/thickness direction)
	//   [3] world position (dont change)

	// The asteroid may rotate in space, dont rorate the bar
	// Throw away the bars rotation and rebuild only the scale + camera-facing alignment:
	// - read each axis length from MODEL_MATRIX to keep the quad size 
	// - write those lengths into view-space axes (screen-right, screen-up, screen-forward)
	// Bar stays the same size, stays at the same world spot and faces the player.
	MODELVIEW_MATRIX[0] = vec4(length(MODEL_MATRIX[0].xyz), 0.0, 0.0, 0.0);
	MODELVIEW_MATRIX[1] = vec4(0.0, length(MODEL_MATRIX[1].xyz), 0.0, 0.0);
	MODELVIEW_MATRIX[2] = vec4(0.0, 0.0, length(MODEL_MATRIX[2].xyz), 0.0);
}

// Fragment shader: runs once per pixel on the quad.
// Builds a simple horizontal progress bar from left (0.0) to right (1.0).
void fragment() {
	// UV goes from (0,0) bottom-left to (1,1) top-right across the quad.
	vec2 uv = UV;
	vec2 border = border_size;

	// Outer frame: pixels near any edge become border color.
	bool on_border = uv.x < border.x || uv.x > 1.0 - border.x
		|| uv.y < border.y || uv.y > 1.0 - border.y;

	if (on_border) {
		ALBEDO = border_color.rgb;
		ALPHA = border_color.a;
	// Fill: left side up to health_percentage is green (remaining health).
	} else if (uv.x <= health_percentage) {
		ALBEDO = fill_color.rgb;
		ALPHA = fill_color.a;
	// Background: right side beyond current health (usually transparent).
	} else {
		ALBEDO = bg_color.rgb;
		ALPHA = bg_color.a;
	}
}
