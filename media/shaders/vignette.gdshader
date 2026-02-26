shader_type canvas_item;

// Corner-darkening overlay for CRT vignette effect.
// Applied on a full-screen ColorRect at a high CanvasLayer layer so it
// composites over all UI panels (not just the grid background).

uniform float strength : hint_range(0.0, 3.0) = 1.15;
uniform float softness : hint_range(0.01, 1.0) = 0.45;
uniform vec4 edge_color : source_color = vec4(0.0, 0.0, 0.04, 1.0);

void fragment() {
    // Remap UV from [0,1] to [-1,1]; centre is (0,0).
    vec2 uv = UV * 2.0 - 1.0;
    // Slightly taller ellipse so it matches a widescreen monitor.
    uv.y *= 0.85;
    float d = dot(uv, uv);
    float vignette = smoothstep(1.0 - softness, 1.0, d * strength);
    // Alpha drives the blend: 0 at centre (transparent), rises at edges.
    COLOR = vec4(edge_color.rgb, vignette * edge_color.a);
}
