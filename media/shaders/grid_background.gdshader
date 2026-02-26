shader_type canvas_item;

uniform vec4 grid_color : source_color = vec4(0.0, 0.6, 0.8, 0.3);
uniform vec4 background_color : source_color = vec4(0.02, 0.02, 0.08, 1.0);
uniform float grid_size : hint_range(10.0, 200.0) = 50.0;
uniform float grid_thickness : hint_range(0.5, 5.0) = 1.5;
uniform float scroll_speed : hint_range(0.0, 100.0) = 20.0;

void fragment() {
    vec2 uv = UV * vec2(1920.0, 1080.0) / grid_size;
    uv.y += TIME * scroll_speed / grid_size;

    // Create grid lines
    vec2 grid = abs(fract(uv - 0.5) - 0.5) / fwidth(uv);
    float line = min(grid.x, grid.y);
    float grid_pattern = 1.0 - min(line / grid_thickness, 1.0);

    // Mix background and grid
    COLOR = mix(background_color, grid_color, grid_pattern);
}
