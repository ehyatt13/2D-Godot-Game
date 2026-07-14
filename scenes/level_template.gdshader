shader_type canvas_item;

// Allows you to change the fog color and speed right in the Inspector box!
uniform vec4 fog_color : source_color = vec4(0.8, 0.8, 0.85, 0.3);
uniform float speed = 10.0;
uniform float fog_density = 0.02;

// Lightweight algorithm that generates pseudo-random cloud patterns
float noise(vec2 coord) {
    return fract(sin(dot(coord.xy, vec2(12.9898, 78.233))) * 43758.5453);
}

void vertex() {
	// Called for every vertex the material is visible on.
	UV = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

void fragment() {
	vec2 world_uv = UV * fog_density;
    // Generate a moving UV coordinate grid based on game time
    //vec2 moving_uv = UV + vec2(TIME * speed, TIME * speed * 0.2);
	vec2 moving_uv = world_uv + vec2(TIME * speed * 0.01, TIME * speed * 0.002);
    
    // Create an organic cloud density layer
    float cloud_density = noise(floor(moving_uv * 5.0));
    
    // Mix the fog color with the underlying game world pixels
    //vec4 pixel_color = texture(TEXTURE, UV);
    //COLOR = mix(pixel_color, fog_color, cloud_density * fog_color.a);
	COLOR = mix(COLOR, fog_color, cloud_density * fog_color.a);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}