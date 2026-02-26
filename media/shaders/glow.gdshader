shader_type canvas_item;

uniform vec4 glow_color : source_color = vec4(0.0, 0.8, 1.0, 1.0);
uniform float glow_intensity : hint_range(0.0, 2.0) = 1.0;
uniform float pulse_speed : hint_range(0.0, 10.0) = 2.0;

void fragment() {
    vec4 color = texture(TEXTURE, UV);

    // Pulsing glow effect
    float pulse = (sin(TIME * pulse_speed) * 0.5 + 0.5) * 0.3 + 0.7;
    vec4 glow = glow_color * glow_intensity * pulse;

    // Add glow to original color
    COLOR = color + glow * color.a;
}
