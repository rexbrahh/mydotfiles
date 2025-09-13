#version 330 core

/*
  Ghostty/Kitty-style postprocessing shader: "Comet Cursor"

  Intent: Add a comet-like trail that follows the terminal cursor while
  keeping the background transparent and avoiding ugly deformation of the
  cursor itself. The effect is additive and subtle by default.

  Notes:
  - This shader is written to be tolerant of differing terminal shader APIs.
    It expects the terminal content as `tex` and optionally a `previous`
    texture containing the previous frame (or an accumulation buffer). If
    `previous` isn't provided by your host, the trail will degrade gracefully
    to a soft halo around the cursor without persistence.
  - Cursor position is expected in pixels via `cursor_pos`. If your host uses
    a different name for the cursor uniform, adjust below.
  - Alpha is preserved from the input so transparent backgrounds stay
    transparent.
*/

// Current terminal frame (RGBA)
uniform sampler2D tex;

// Optional accumulation/previous frame for feedback (RGBA)
// If your host does not provide it, leave bound to 0 or comment usages below.
uniform sampler2D previous;

// Viewport resolution in pixels (width, height)
uniform vec2 resolution;

// Time in seconds (monotonic)
uniform float time;

// Cursor position in pixels (x, y) relative to top-left of the viewport
// If your host uses a different uniform name, rename here.
uniform vec2 cursor_pos;

in vec2 v_texcoord;         // Provided by host: UV for tex sampling
out vec4 frag_color;        // Final color

// Tunables
const float TRAIL_DECAY = 0.86;      // 0..1 decay per frame of the trail
const float TRAIL_INTENSITY = 0.75;  // Additive strength of new deposits
const float TRAIL_SIGMA = 8.0;       // Pixel radius for deposit falloff
const float TRAIL_SPREAD = 1.65;     // How wide the trail diffuses
const float CURSOR_PROTECT = 2.0;    // Inner px radius to avoid overbrightening cursor core

// Trail color (soft bluish-cyan). Tweak to taste.
const vec3 COMET_COLOR = vec3(0.40, 0.85, 1.00);

// Small noise to avoid banding
float hash21(vec2 p) {
    p = fract(p * vec2(123.34, 345.45));
    p += dot(p, p + 34.345);
    return fract(p.x * p.y);
}

void main() {
    // Base terminal color (preserve exactly, including alpha for transparency)
    vec4 base = texture(tex, v_texcoord);

    // Convert to pixel space
    vec2 uv = v_texcoord;
    vec2 p = uv * resolution; // pixel coords

    // Distance from cursor, in pixels
    vec2 d = p - cursor_pos;
    float dist = length(d);

    // Soft Gaussian deposit around cursor to seed/boost the trail
    float deposit = exp(-0.5 * (dist * dist) / (TRAIL_SIGMA * TRAIL_SIGMA));

    // Protect the core of the cursor from getting blown out: reduce deposit very close in
    float protect = smoothstep(CURSOR_PROTECT, 0.0, dist);
    deposit *= protect;

    // Read previous trail value if available (fall back to zero if not bound)
    vec4 prevCol = vec4(0.0);
    // Attempt to sample previous frame using the same UVs
    // Some hosts will bind this to black if unavailable, which is fine.
    prevCol = texture(previous, uv);

    // Compute a diffused trail: decay previous, add new deposit
    // Store trail in the alpha channel of the accumulation to avoid color bleeding
    float prevTrail = prevCol.a;
    float trail = prevTrail * TRAIL_DECAY + deposit * TRAIL_INTENSITY;

    // Slight diffusion to make it comet-like (sample neighbors)
    // Use a kernel based on the direction of motion if previous is available; otherwise isotropic
    vec2 dir = normalize(d + 1e-5);
    vec2 n1 = dir.yx * vec2(1.0, -1.0); // perpendicular for a small cross blur
    float spread = TRAIL_SPREAD / max(resolution.x, resolution.y);
    float s = 0.0;
    s += texture(previous, uv + dir * spread).a * 0.40;
    s += texture(previous, uv - dir * spread).a * 0.20;
    s += texture(previous, uv + n1 * spread).a * 0.20;
    s += texture(previous, uv - n1 * spread).a * 0.20;
    trail = max(trail, s);

    // Add a touch of noise modulation to avoid banding
    float n = hash21(p + time);
    trail *= mix(0.98, 1.02, n * 0.06);

    // Compose: additive glow over the base, preserving base alpha (transparency)
    vec3 glow = COMET_COLOR * trail;
    vec3 color = base.rgb + glow;

    frag_color = vec4(color, base.a);
}
