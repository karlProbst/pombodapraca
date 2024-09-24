shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_nearest, repeat_disable;
uniform float colors : hint_range(1.0, 128.0);
uniform float dither : hint_range(0.0, 10);

void fragment() {
    vec4 color = texture(SCREEN_TEXTURE, UV);  // Use SCREEN_TEXTURE instead of TEXTURE

    float a = floor(mod(UV.x / TEXTURE_PIXEL_SIZE.x, 2.0));
    float b = floor(mod(UV.y / TEXTURE_PIXEL_SIZE.y, 2.0));
    float c = mod(a + b, 2.0);

    COLOR.r = (round(color.r * colors + dither) / colors) * c;
    COLOR.g = (round(color.g * colors + dither) / colors) * c;
    COLOR.b = (round(color.b * colors + dither) / colors) * c;
    c = 1.0 - c;
    COLOR.r += (round(color.r * colors - dither) / colors) * c;
    COLOR.g += (round(color.g * colors - dither) / colors) * c;
    COLOR.b += (round(color.b * colors - dither) / colors) * c;
}
