shader_type canvas_item;

uniform sampler2D background_texture;
uniform sampler2D window_texture;

uniform vec2 window_size = vec2(50.0, 50.0);  // Size of each window
uniform vec2 window_spacing = vec2(10.0, 10.0);  // Spacing between windows
uniform vec2 n_windows = vec2(5.0, 3.0);  // Number of windows on X and Y axis

void fragment() {
    // Use UV coordinates directly
    vec2 uv = UV;

    // Sample the background texture
    vec4 background_color = texture(background_texture, UV);

    // Calculate total grid size
    vec2 grid_size = vec2(n_windows.x * (window_size.x + window_spacing.x), 
                          n_windows.y * (window_size.y + window_spacing.y));

    // Calculate the position within the grid (looping for window tiles)
    vec2 grid_uv = mod(uv * grid_size, window_size + window_spacing);

    // Check if the current pixel is within the window bounds
    if (grid_uv.x < window_size.x && grid_uv.y < window_size.y) {
        // Sample the window texture within its bounds
        vec4 window_color = texture(window_texture, grid_uv / window_size);
        COLOR = mix(background_color, window_color, window_color.a);  // Blend window with background
    } else {
        COLOR = background_color;  // Outside window bounds, show background
    }
}
