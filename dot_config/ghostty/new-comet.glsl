/* Ghostty Comet Cursor — STRICT (only the current cursor rect is touched)
   Requires cursor uniforms: iCurrentCursor, iPreviousCursor, iTimeCursorChange
   Leaves background, transparency, and everything outside the cursor 100% untouched.
*/

const float TRAIL_LIFE_SEC   = 0.55;  // how long after a move the tail hangs around
const float TRAIL_WIDTH_MULT = 0.55;  // thickness of the tail inside the rect
const float TAIL_SHARPNESS   = 2.2;   // brighter near the head
const float HEAD_GLOW_SOFT   = 0.9;   // soft radius inside rect (in cursor-heights)
const float MAX_ADD          = 0.9;   // clamp additive brighten

// warm “comet” colors
const vec3 TAIL_BASE   = vec3(1.00, 0.78, 0.32);
const vec3 TAIL_ACCENT = vec3(1.00, 0.50, 0.12);

vec2 N_pos(vec2 px) {                    // normalize a pixel position to aspect-correct space
    return (px * 2.0 - iResolution.xy) / iResolution.y;
}
vec2 N_size(vec2 px) {                   // normalize a pixel size to aspect-correct space
    return (px * 2.0) / iResolution.y;
}

float sdCapsule(vec2 p, vec2 a, vec2 b, float r, out float t01) {
    vec2 pa = p - a, ba = b - a;
    float h = clamp(dot(pa, ba) / max(dot(ba, ba), 1e-6), 0.0, 1.0);
    t01 = h;
    return length(pa - ba * h) - r;
}

vec3 addGlow(vec3 base, vec3 add, float amt) {
    return clamp(base + add * amt, 0.0, 1.0);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    // Always start from the original terminal framebuffer
    vec4 base = texture(iChannel0, fragCoord / iResolution.xy);

    // Current cursor rect in pixel space
    vec2 curPos  = iCurrentCursor.xy;
    vec2 curSize = iCurrentCursor.zw;

    // HARD CLIP: only shade inside current cursor rect
    if (fragCoord.x < curPos.x || fragCoord.y < curPos.y ||
        fragCoord.x >= curPos.x + curSize.x || fragCoord.y >= curPos.y + curSize.y) {
        fragColor = base;                // absolutely no change outside the cursor
        return;
    }

    // Normalized (aspect-correct) coordinates
    vec2 p = N_pos(fragCoord);
    vec2 curPosN  = N_pos(curPos);
    vec2 curSizeN = N_size(curSize);
    vec2 prvPosN  = N_pos(iPreviousCursor.xy);
    vec2 prvSizeN = N_size(iPreviousCursor.zw);

    // Centers (note Y is already aspect-normalized)
    vec2 curC = curPosN + vec2(curSizeN.x * 0.5, -curSizeN.y * 0.5);
    vec2 prvC = prvPosN + vec2(prvSizeN.x * 0.5, -prvSizeN.y * 0.5);

    // Lifetime of trail since last move
    float dt = max(0.0, iTime - iTimeCursorChange);
    float alive = 1.0 - clamp(dt / TRAIL_LIFE_SEC, 0.0, 1.0);

    // If idle, just a soft head glow INSIDE the rect
    if (alive <= 0.0) {
        float headR = curSizeN.y * HEAD_GLOW_SOFT;
        float dHead = length(p - curC) / max(headR, 1e-6);
        float headI = exp(-dHead * 3.0);
        vec3 glowCol = mix(TAIL_BASE, TAIL_ACCENT, 0.35);
        vec3 rgb = addGlow(base.rgb, glowCol, clamp(headI, 0.0, MAX_ADD));
        fragColor = vec4(rgb, base.a);   // keep alpha exactly
        return;
    }

    // Trail: a capsule from previous center to current center
    float t01;
    float trailR = (curSizeN.y * 0.5) * TRAIL_WIDTH_MULT;
    float d = sdCapsule(p, prvC, curC, trailR, t01);

    // Radial fade from the segment axis + axial emphasis toward the head
    float radial = 1.0 - smoothstep(0.0, trailR * 1.25, max(0.0, d + trailR));
    float axial  = pow(t01, TAIL_SHARPNESS);
    float trailI = radial * axial * alive;

    // Head glow inside the rect
    float headR = curSizeN.y * HEAD_GLOW_SOFT;
    float dHead = length(p - curC) / max(headR, 1e-6);
