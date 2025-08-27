/* Ghostty — Comet Cursor (STRICT, cursor-rect only, pixel-space)
   Requires Shadertoy-style Ghostty uniforms:
     iResolution (vec3), iTime (float), iChannel0 (sampler2D), iCurrentCursor (vec4)
   Optional (for trail): iPreviousCursor (vec4), iTimeCursorChange (float)
   If the optional uniforms are missing, you’ll still get a nice head glow.
*/

////////////////////////////////////////////////////////////
// Tunables
////////////////////////////////////////////////////////////
const float TRAIL_LIFE_SEC   = 0.55;  // how long the tail lingers after a move
const float TRAIL_WIDTH_MULT = 0.55;  // tail thickness relative to cursor height
const float TAIL_SHARPNESS   = 2.2;   // brighter near the head
const float HEAD_SOFT_PIX    = 0.9;   // head glow radius in cursor-heights
const float MAX_ADD          = 0.9;   // clamp additive brighten

const vec3 COL_HEAD   = vec3(1.00, 0.78, 0.32);
const vec3 COL_TAIL   = vec3(1.00, 0.50, 0.12);

////////////////////////////////////////////////////////////
// Helpers (pixel-space)
////////////////////////////////////////////////////////////
float saturate(float x){ return clamp(x, 0.0, 1.0); }
vec3  addGlow(vec3 base, vec3 add, float amt){ return clamp(base + add * amt, 0.0, 1.0); }

// Signed distance to a capsule (line segment with radius) in pixel space
float sdCapsulePx(vec2 p, vec2 a, vec2 b, float r, out float t01){
    vec2 pa = p - a, ba = b - a;
    float denom = max(dot(ba, ba), 1e-6);
    float h = clamp(dot(pa, ba) / denom, 0.0, 1.0);
    t01 = h;
    return length(pa - ba * h) - r;
}

////////////////////////////////////////////////////////////
// Main
////////////////////////////////////////////////////////////
void mainImage(out vec4 fragColor, in vec2 fragCoord){
    vec2 screen = iResolution.xy;
    vec2 uv = fragCoord / screen;

    // Start with the terminal framebuffer
    vec4 base = texture(iChannel0, uv);

    // Current cursor in pixels
    vec2 curPos  = iCurrentCursor.xy;
    vec2 curSize = max(iCurrentCursor.zw, vec2(1.0)); // avoid zero size
    vec2 curMin  = curPos;
    vec2 curMax  = curPos + curSize;

    // HARD CLIP: do not touch anything outside the current cursor rectangle
    if (fragCoord.x < curMin.x || fragCoord.y < curMin.y ||
        fragCoord.x >= curMax.x || fragCoord.y >= curMax.y){
        fragColor = base;
        return;
    }

    // Pixel-space centers
    vec2 curC = curPos + vec2(curSize.x * 0.5, curSize.y * 0.5);

    // Defaults for “no trail” case
    float alive = 0.0;
    vec2  prvC  = curC;
    float dt    = 0.0;

    // Try to use previous-cursor/time uniforms if they exist.
    // If your Ghostty build lacks them, the compiler will optimize
    // this block away because 'alive' stays 0.
    #ifdef iPreviousCursor
    #ifdef iTimeCursorChange
        vec2 prvPos  = iPreviousCursor.xy;
        vec2 prvSize = max(iPreviousCursor.zw, vec2(1.0));
        prvC = prvPos + vec2(prvSize.x * 0.5, prvSize.y * 0.5);
        dt = max(0.0, iTime - iTimeCursorChange);
        alive = 1.0 - saturate(dt / TRAIL_LIFE_SEC);
    #endif
    #endif

    // Head glow (always inside the rect)
    float headR = curSize.y * HEAD_SOFT_PIX;
    float dHead = length(fragCoord - curC) / max(headR, 1e-6);
    float headI = exp(-dHead * 3.0) * max(0.4, alive + 0.6); // glow even when idle

    vec3 rgb = base.rgb;
    rgb = addGlow(rgb, mix(COL_HEAD, COL_TAIL, 0.35), min(headI, MAX_ADD));

    // Trail (only if we have previous/time and alive > 0)
    if (alive > 0.0 && any(greaterThan(abs(prvC - curC), vec2(0.5)))) {
        float t01;
        float trailR = (curSize.y * 0.5) * TRAIL_WIDTH_MULT;
        float d = sdCapsulePx(fragCoord, prvC, curC, max(trailR, 0.5), t01);

        float radial = 1.0 - smoothstep(0.0, trailR * 1.25, max(0.0, d + trailR));
        float axial  = pow(saturate(t01), TAIL_SHARPNESS);
        float tailI  = radial * axial * alive;

        vec3 tailCol = mix(COL_HEAD, COL_TAIL, saturate(t01 * 1.1));
        rgb = addGlow(rgb, tailCol, min(tailI, MAX_ADD));
    }

    fragColor = vec4(rgb, base.a); // never touch alpha — transparency preserved
}

