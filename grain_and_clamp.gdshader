shader_type canvas_item;

// Uniforms for the grain effect
uniform sampler2D screen_texture : hint_screen_texture;
uniform float grain_amount : hint_range(0.0, 1.0) = 0.05; // Adjust the amount of grain
uniform float grain_size : hint_range(0.1, 10.0) = 1.0; // Adjust the size of the grain

// Uniforms for the dithering effect
uniform float colors : hint_range(1.0, 128.0) = 16.0;
uniform float dither : hint_range(0.0, 10.0) = 1.0;

void fragment() {
    // Sample the original screen texture
    vec4 original_color = texture(screen_texture, SCREEN_UV);

    // Generate random noise for grain
    float noise = (fract(sin(dot(UV, vec2(12.9898, 78.233))) * 43758.5453) - 0.5) * 2.0;

    // Add noise to the original color (grain effect)
    vec3 grainy_color = original_color.rgb + noise * grain_amount * grain_size;

    // Apply color quantization (reduce color range)
    vec3 quantized_color;
    quantized_color.r = round(grainy_color.r * colors) / colors;
    quantized_color.g = round(grainy_color.g * colors) / colors;
    quantized_color.b = round(grainy_color.b * colors) / colors;

    // Apply dithering effect
    float a = floor(mod(UV.x / TEXTURE_PIXEL_SIZE.x, 2.0));
    float b = floor(mod(UV.y / TEXTURE_PIXEL_SIZE.y, 2.0));
    float c = mod(a + b, 2.0);

    vec3 dithered_color;
    dithered_color.r = (quantized_color.r + (dither * c) / colors);
    dithered_color.g = (quantized_color.g + (dither * c) / colors);
    dithered_color.b = (quantized_color.b + (dither * c) / colors);

    // Clamp the final color to avoid overflows
    COLOR = vec4(clamp(dithered_color, 0.0, 1.0), original_color.a);
}
