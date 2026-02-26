shader_type canvas_item;

uniform vec4 glow_color : source_color = vec4(0.0, 0.8, 1.0, 1.0);
uniform float glow_strength : hint_range(0.0, 5.0) = 2.0;
uniform float pulse_speed : hint_range(0.0, 10.0) = 3.0;
uniform float bloom_radius : hint_range(0.0, 20.0) = 8.0;

void fragment() {
    vec4 color = texture(TEXTURE, UV);

    // Calculate brightness
    float brightness = (color.r + color.g + color.b) / 3.0;

    // Pulsing glow
    float pulse = (sin(TIME * pulse_speed) * 0.2 + 0.8);

    // Add bloom effect
    vec4 bloom = vec4(0.0);
    float samples = 8.0;
    for (float i = 0.0; i < samples; i++) {
        float angle = (i / samples) * 6.28318;
        vec2 offset = vec2(cos(angle), sin(angle)) * (bloom_radius / 1000.0);
        bloom += texture(TEXTURE, UV + offset);
    }
    bloom /= samples;

    // Combine original color with glow
    vec4 glow = glow_color * brightness * glow_strength * pulse;
    COLOR = color + glow * 0.5 + bloom * 0.3;
}
