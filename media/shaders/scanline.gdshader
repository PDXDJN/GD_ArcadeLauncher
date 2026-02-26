shader_type canvas_item;

uniform float scanline_count : hint_range(0.0, 1080.0) = 500.0;
uniform float scanline_intensity : hint_range(0.0, 1.0) = 0.15;
uniform float scanline_speed : hint_range(0.0, 10.0) = 1.0;

void fragment() {
    vec4 color = texture(TEXTURE, UV);

    // Scanline effect
    float scanline = sin((UV.y + TIME * scanline_speed * 0.01) * scanline_count * 3.14159) * 0.5 + 0.5;
    color.rgb -= scanline * scanline_intensity;

    COLOR = color;
}
