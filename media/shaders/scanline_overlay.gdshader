shader_type canvas_item;
// Multiplicative blend: colour underneath is multiplied by the scanline mask.
// Values of 1.0 leave underlying pixels unchanged; dark bands slightly dim them.
// Use this for the full-screen effects pass so it works over UI panels.
render_mode blend_mul;

uniform float scanline_count     : hint_range(0.0, 1080.0) = 480.0;
uniform float scanline_intensity : hint_range(0.0, 0.5)    = 0.055;
uniform float scanline_speed     : hint_range(0.0, 10.0)   = 0.5;

void fragment() {
    float scanline = sin(
        (UV.y + TIME * scanline_speed * 0.01) * scanline_count * 3.14159
    ) * 0.5 + 0.5;
    float brightness = 1.0 - scanline * scanline_intensity;
    COLOR = vec4(brightness, brightness, brightness, 1.0);
}
