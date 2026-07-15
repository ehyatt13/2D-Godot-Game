shader_type canvas_item;

// The progress bar tracker sliding smoothly from 0.0 (Wide Open) to 1.0 (Fully Black)
uniform float progress : hint_range(0.0, 1.0) = 0.0;
uniform float feather : hint_range(0.0, 0.1) = 0.005;

// Captures the dynamic 0.0-1.0 screen-space coordinate of the player
uniform vec2 player_screen_pos = vec2(0.5, 0.5);
// Captures the live viewport dimensions to wipe out stretching distortion
uniform vec2 screen_size = vec2(1920.0, 1080.0);

//void vertex() {
	//// Called for every vertex the material is visible on.
//}

void fragment() {
	float aspect_ratio = screen_size.x / screen_size.y;
	vec2 uv_corrected = UV;
	uv_corrected.x *= aspect_ratio;
	vec2 player_target = player_screen_pos;
	player_target.x *= aspect_ratio;
	float dist = length(uv_corrected - player_target);
	float radius = (0.75 * aspect_ratio) * (1.0 - progress);
	
	float circle_mask = smoothstep(radius, radius + feather, dist);
	COLOR = vec4(0.0, 0.0, 0.0, circle_mask);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
