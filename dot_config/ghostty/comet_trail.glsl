/* Ghostty Comet Cursor — ONLY affects cursor area
 *
 * Works with cursor uniforms:
 *   iCurrentCursor, iPreviousCursor, iTimeCursorChange
 * Leaves the rest of the framebuffer (background & text) untouched.
 */

const float TRAIL_LIFE_SEC   = 0.60;
const float TRAIL_WIDTH_MULT = 0.60;
const float TAIL_SHARPNESS   = 2.20;
const float HEAD_GLOW_MULT   = 1.20;
const float HEAD_GLOW_SOFT   = 1.50;
const float MAX_ADD          = 0.85;

const vec3 TAIL_BASE   = vec3(1.00, 0.78, 0.32);
const vec3 TAIL_ACCENT = vec3(1.00, 0.45, 0.10);

vec2 N(vec2 value, float isPosition) {
    return (value * 2.0 - (iResolution.xy * isPosition)) / iResolution.y;
}

float sdCapsule(vec2 p, vec2 a, vec2 b, float r, out float t01) {
    vec2 pa = p - a, ba = b - a;
    float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
    t01 = h;
    return length(pa - ba * h) - r;
}

vec3 addGlow(vec3 base, vec3 add, float amt) {
    return clamp(base + add * amt, 0.0, 1.0);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    // 1) Start from the unmodified framebuffer
    fragColor = texture(iChannel0, fragCoord / iResolution.xy);

    // 2) Cursor rectangle (in screen space)
    vec2 uv = fragCoord;
    vec2 curPos = iCurrentCursor.xy;
    vec2 curSize = iCurrentCursor.zw;
    vec2 prvPos = iPreviousCursor.xy;
    vec2 prvSize = iPreviousCursor.zw;

    // Only shade inside the cursor bounding box (expand a little for glow)
    if (uv.x < min(curPos.x, prvPos.x) - curSize.x ||
        uv.y < min(curPos.y, prvPos.y) - curSize.y ||
        uv.x > max(curPos.x + curSize.x, prvPos.x + prvSize.x) + curSize.x ||
        uv.y > max(curPos.y + curSize.y, prvPos.y + prvSize.y) + curSize.y) {
        return; // leave fragColor as-is (transparent regions untouched)
    }

    // 3) Convert into normalized aspect space
    vec2 p = N(fragCoord, 1.0);
    vec4 cur = vec4(N(curPos, 1.0), N(curSize, 0.0));
    vec4 prv = vec4(N(prvPos, 1.0), N(prvSize, 0.0));
    vec2 curC = vec2(cur.x + cur.z * 0.5, cur.y - cur.w * 0.5);
    vec2 prvC = vec2(prv.x + prv.z * 0.5, prv.y - prv.w * 0.5);

    float dt = max(0.0, iTime - iTimeCursorChange);
    float trailAlive = 1.0 - clamp(dt / TRAIL_LIFE_SEC, 0.0, 1.0);

    float t01;
    float trailRadius = (cur.w * 0.5) * TRAIL_WIDTH_MULT;
    float dTrail = sdCapsule(p, prvC, curC, trailRadius, t01);

    float radial = 1.0 - smoothstep(0.0, trailRadius * 1.25, max(0.0, dTrail + trailRadius));
    float axial = pow(t01, TAIL_SHARPNESS);
    float trailIntensity = radial * axial * trailAlive;

    float headRadius = cur.w * HEAD_GLOW_SOFT;
    float dHead = length(p - curC) / headRadius;
    float headGlow = exp(-dHead * 3.0) * HEAD_GLOW_MULT;

    vec3 trailCol = mix(TAIL_BASE, TAIL_ACCENT, clamp(t01, 0.0, 1.0));

    vec3 color = fragColor.rgb;
    color = addGlow(color, trailCol, clamp(trailIntensity, 0.0, MAX_ADD));
    color = addGlow(color, trailCol, clamp(headGlow, 0.0, MAX_ADD));

    fragColor = vec4(color, fragColor.a); // preserve alpha!
}

