precision mediump float;

#define PI 3.14159265358979
#define TWO_PI 6.28318530717958
#define E 2.7182818284
#define PHI 1.6180339887

uniform vec2 uResolution;
uniform float uTime;

float map(float value, float imin, float imax, float omin, float omax) {
    return omin + (value - imin) / (imax - imin) * (omax - omin);
}

float distSq2(vec2 a, vec2 b) {
    return (a.x - b.x) * (a.x - b.x) + (a.y - b.y) * (a.y - b.y);
}

float hash(in vec2 xy, in float seed) {
    return clamp(fract(tan(distance(xy * PHI, xy) * mod(seed, 1000.0)) * xy.x) * 1.003921568627, 0.0, 1.0);
}

void main() {
    vec2 uv = gl_FragCoord.xy / uResolution.xy;

    // vec3 c1 = vec3(uv.xy, 0.0);
    // vec3 c2 = vec3(0.0, uv.xy);

    // float t = map(sin(uTime * TWO_PI * 0.4), -1.0, 1.0, 0.0, 1.0);
    // gl_FragColor = vec4((1.0 - t) * c1 + t * c2, 1.0);
    // //gl_FragColor = vec4(uv.x, uv.y, 0.0, 1.0);

    vec4 h;
    for(int i = 0; i < 32; i++) {
        h = vec4(vec3(hash(gl_FragCoord.xy, uTime)), 1.0);
    }

    gl_FragColor = h;
}