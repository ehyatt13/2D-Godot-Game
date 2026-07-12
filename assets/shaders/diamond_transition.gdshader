shader_type canvas_item;

// Progression tracker: 0.0 = completely clear screen, 1.0 = completely black diamond screen
uniform float progress : hint_range(0.0, 1.0) = 0.0;

// How many pixel diamond chunks are drawn horizontally across your monitor viewport
uniform float diamond_pixel_size = 32.0;

//void vertex() {
	//// Called for every vertex the material is visible on.
//}

vec2 fraction_box(vec2 value) {
    return value - floor(value);
}

// Helper calculation to map out non-blurry, perfectly uniform coordinate grids
vec2 uv_to_pixelated_grid(vec2 original_uv, float aspect) {
    vec2 uv = original_uv;
    uv.x /= aspect; // Apply aspect multiplier to prevent squishing on widescreen panels
    uv = fraction_box(uv * diamond_pixel_size);
    return uv;
}

void fragment() {
	// A. Grab the raw screen resolution ratio
    float aspect_ratio = SCREEN_PIXEL_SIZE.y / SCREEN_PIXEL_SIZE.x;
	
	// B. Calculate a sharp pixelated coordinate grid cell mapping box
    vec2 pixelated_uv = uv_to_pixelated_grid(UV, aspect_ratio);
	
	// C. Mathematical Diamond Equation
    // Calculates the absolute distance to the center point of each pixel chunk cell
    float diamond_shape = abs(pixelated_uv.x - 0.5) + abs(pixelated_uv.y - 0.5);
	
	// D. THE SHADER GATE CUT: 
    // If the diamond value falls beneath our progress slider bar, draw solid black color channels!
    if (diamond_shape < progress * 1.5) {
        COLOR = vec4(0.0, 0.0, 0.0, 1.0); // Solid black pixel block
    } else {
        COLOR = vec4(0.0, 0.0, 0.0, 0.0); // Completely transparent see-through glass
    }
}


//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
