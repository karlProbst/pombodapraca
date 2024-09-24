shader_type canvas_item;

uniform sampler2D noise_texture;
uniform vec2 offset = vec2(0.0, 0.0);

void fragment() {
    vec2 uv = (FRAGCOORD.xy / SCREEN_PIXEL_SIZE) + offset;
    vec4 noise_color = texture(noise_texture, uv);
    COLOR = noise_color;
}
