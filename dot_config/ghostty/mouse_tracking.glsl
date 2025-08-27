// Simple mouse glow test - minimal dependencies
// This uses only basic operations that translate well to MSL

uniform vec3 iResolution;
uniform float iTime;
uniform vec4 iMouse;
uniform sampler2D iChannel0;

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord / iResolution.xy;
    vec4 tex = texture(iChannel0, uv);
    
    // Simple test: make the entire screen pulse to verify shader works
    float pulse = 0.5 + 0.5 * sin(iTime);
    
    // If mouse tracking works, this will create a simple distance-based effect
    vec2 mouse = iMouse.xy / iResolution.xy;  // Normalize mouse coords
    float dist = length(uv - mouse);
    float glow = 1.0 - smoothstep(0.0, 0.3, dist);
    
    // Combine effects: base texture + time pulse + mouse glow
    vec3 color = tex.rgb;
    color += vec3(0.1, 0.05, 0.0) * pulse;  // Subtle amber pulse
    color += vec3(1.0, 0.6, 0.2) * glow * 0.5;  // Amber mouse glow
    
    fragColor = vec4(color, tex.a);
}
