float ease(float x) {
    // Smoother, more comet-like decay
    return pow(1.0 - x, 3.0);
}

float sdBox(in vec2 p, in vec2 xy, in vec2 b)
{
    vec2 d = abs(p - xy) - b;
    return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
}

float getSdfRectangle(in vec2 p, in vec2 xy, in vec2 b)
{
    vec2 d = abs(p - xy) - b;
    return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
}

// Based on Inigo Quilez's 2D distance functions article: https://iquilezles.org/articles/distfunctions2d/
float seg(in vec2 p, in vec2 a, in vec2 b, inout float s, float d) {
    vec2 e = b - a;
    vec2 w = p - a;
    vec2 proj = a + e * clamp(dot(w, e) / dot(e, e), 0.0, 1.0);
    float segd = dot(p - proj, p - proj);
    d = min(d, segd);

    float c0 = step(0.0, p.y - a.y);
    float c1 = 1.0 - step(0.0, p.y - b.y);
    float c2 = 1.0 - step(0.0, e.x * w.y - e.y * w.x);
    float allCond = c0 * c1 * c2;
    float noneCond = (1.0 - c0) * (1.0 - c1) * (1.0 - c2);
    float flip = mix(1.0, -1.0, step(0.5, allCond + noneCond));
    s *= flip;
    return d;
}

float getSdfParallelogram(in vec2 p, in vec2 v0, in vec2 v1, in vec2 v2, in vec2 v3) {
    float s = 1.0;
    float d = dot(p - v0, p - v0);

    d = seg(p, v0, v3, s, d);
    d = seg(p, v1, v0, s, d);
    d = seg(p, v2, v1, s, d);
    d = seg(p, v3, v2, s, d);

    return s * sqrt(d);
}

vec2 normalize(vec2 value, float isPosition) {
    return (value * 2.0 - (iResolution.xy * isPosition)) / iResolution.y;
}

float blend(float t)
{
    float sqr = t * t;
    return sqr / (2.0 * (sqr - t) + 1.0);
}

float antialising(float distance) {
    return 1. - smoothstep(0., normalize(vec2(2., 2.), 0.).x, distance);
}

// Comet glow function
float cometGlow(float distance, float radius) {
    return exp(-distance * distance / (radius * radius));
}

float determineStartVertexFactor(vec2 a, vec2 b) {
    float condition1 = step(b.x, a.x) * step(a.y, b.y);
    float condition2 = step(a.x, b.x) * step(b.y, a.y);
    return 1.0 - max(condition1, condition2);
}

vec2 getRectangleCenter(vec4 rectangle) {
    return vec2(rectangle.x + (rectangle.z / 2.), rectangle.y - (rectangle.w / 2.));
}

// Amber comet color palette
const vec4 AMBER_CORE = vec4(1.0, 0.749, 0.0, 1.0);        // Pure amber
const vec4 AMBER_GLOW = vec4(1.0, 0.6, 0.1, 1.0);          // Warmer amber glow
const vec4 AMBER_TAIL = vec4(1.0, 0.4, 0.0, 1.0);          // Deeper amber for tail
const vec4 AMBER_ACCENT = vec4(1.0, 0.85, 0.4, 1.0);       // Light amber accent

const float DURATION = 0.7;          // Longer trail persistence
const float TRAIL_OPACITY = 0.35;    // Subtle base opacity
const float GLOW_RADIUS = 0.015;     // Soft glow radius
const float TAIL_TAPER = 0.25;       // How much the tail narrows (smaller = thinner tail)
const float TRAIL_CURVE = 0.3;       // How much the trail curves

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    #if !defined(WEB)
    fragColor = texture(iChannel0, fragCoord.xy / iResolution.xy);
    #endif
    
    // Preserve original color for alpha channel
    vec4 originalColor = fragColor;
    
    // Normalized coordinates
    vec2 vu = normalize(fragCoord, 1.);
    vec2 offsetFactor = vec2(-.5, 0.5);

    // Cursor positions and sizes
    vec4 currentCursor = vec4(normalize(iCurrentCursor.xy, 1.), normalize(iCurrentCursor.zw, 0.));
    vec4 previousCursor = vec4(normalize(iPreviousCursor.xy, 1.), normalize(iPreviousCursor.zw, 0.));

    // Vertex calculation for trail shape
    float vertexFactor = determineStartVertexFactor(currentCursor.xy, previousCursor.xy);
    float invertedVertexFactor = 1.0 - vertexFactor;

    // Calculate cursor centers
    vec2 centerCC = getRectangleCenter(currentCursor);
    vec2 centerCP = getRectangleCenter(previousCursor);
    
    // Distance and time-based fade
    float progress = clamp((iTime - iTimeCursorChange) / DURATION, 0.0, 1.0);
    float easedProgress = ease(progress);
    
    // Early exit if trail has fully faded
    if (progress >= 1.0) {
        fragColor = originalColor;
        return;
    }
    
    // Trail tapering based on distance from head
    float lineLength = distance(centerCC, centerCP);
    float distanceToHead = distance(vu.xy, centerCC);
    float distanceToTail = distance(vu.xy, centerCP);
    float alongTrail = clamp(distanceToHead / (lineLength + 0.001), 0.0, 1.0);
    
    // Smoother taper with exponential curve for more natural comet shape
    float taperFactor = mix(1.0, TAIL_TAPER, pow(alongTrail, 1.5));
    
    // Add curve to the trail - creates a subtle arc
    vec2 trailDir = normalize(centerCP - centerCC);
    vec2 trailPerp = vec2(-trailDir.y, trailDir.x); // Perpendicular to trail direction
    
    // Curve amount varies along the trail (more curve in the middle)
    float curveAmount = sin(alongTrail * 3.14159) * TRAIL_CURVE * currentCursor.z;
    vec2 curveOffset = trailPerp * curveAmount * (1.0 - alongTrail * 0.5);
    
    // Calculate interpolated position along trail with curve
    vec2 trailPos = mix(centerCC, centerCP, alongTrail) + curveOffset;
    
    // Build curved vertices - use bezier-like interpolation
    vec2 v0 = vec2(currentCursor.x + currentCursor.z * vertexFactor, currentCursor.y - currentCursor.w);
    vec2 v1 = vec2(currentCursor.x + currentCursor.z * invertedVertexFactor, currentCursor.y);
    
    // Add curve to tail vertices with enhanced tapering
    vec2 tailCurve = trailPerp * curveAmount * 0.7;
    vec2 v2 = vec2(previousCursor.x + currentCursor.z * invertedVertexFactor * taperFactor, previousCursor.y) + tailCurve;
    vec2 v3 = vec2(previousCursor.x + currentCursor.z * vertexFactor * taperFactor, previousCursor.y - previousCursor.w * taperFactor) + tailCurve;

    // Calculate SDFs
    float sdfCursor = getSdfRectangle(vu, currentCursor.xy - (currentCursor.zw * offsetFactor), currentCursor.zw * 0.5);
    float sdfTrail = getSdfParallelogram(vu, v0, v1, v2, v3);
    
    // Comet glow effect
    float glowIntensity = cometGlow(abs(sdfTrail), GLOW_RADIUS);
    float headGlow = cometGlow(distanceToHead, GLOW_RADIUS * 2.0);
    
    // Alpha modulation for fade - make it actually disappear
    float fadeAlpha = 1.0 - easedProgress;
    float distanceFade = 1.0 - smoothstep(0.0, 1.0, alongTrail * 0.7);
    float combinedAlpha = fadeAlpha * distanceFade * TRAIL_OPACITY;
    
    // Cut off rendering when alpha is too low
    if (combinedAlpha < 0.01) {
        fragColor = originalColor;
        return;
    }
    
    // Layer the effects
    vec4 newColor = fragColor;
    
    // Outer glow (subtle amber halo)
    vec4 glowColor = mix(AMBER_TAIL, AMBER_GLOW, 1.0 - alongTrail);
    newColor = mix(newColor, glowColor, glowIntensity * combinedAlpha * 0.3);
    
    // Trail core (solid amber)
    float trailCore = antialising(sdfTrail);
    vec4 trailColor = mix(AMBER_TAIL, AMBER_CORE, 1.0 - alongTrail * 0.5);
    newColor = mix(newColor, trailColor, trailCore * combinedAlpha);
    
    // Head accent (bright spot at cursor)
    newColor = mix(newColor, AMBER_ACCENT, headGlow * fadeAlpha * 0.4);
    
    // Preserve cursor interior (don't draw over the actual cursor)
    fragColor = mix(newColor, originalColor, step(sdfCursor, 0));
    
    // Ensure we preserve the original alpha channel for transparency
    fragColor.a = originalColor.a;
}
