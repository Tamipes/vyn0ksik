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

float noise(in vec2 x) {
    vec2 p = floor(x);
    vec2 f = fract(x);
    f = f * f * (3.0 - 2.0 * f);

    float a = hash(p + vec2(0, 0), 2018.2023);
    float b = hash(p + vec2(1, 0), 2018.2023);
    float c = hash(p + vec2(0, 1), 2018.2023);
    float d = hash(p + vec2(1, 1), 2018.2023);
    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

const mat2 mtx = mat2(0.80, 0.60, -0.60, 0.80);
float complex_noise(in vec2 p) {
    float f = 0.0;

    f += 0.5000 * noise(p);
    p = mtx * p * 2.0;
    f += 0.2500 * noise(p);
    p = mtx * p * 2.0;
    f += 0.1250 * noise(p);
    p = mtx * p * 2.0;
    f += 0.0625 * noise(p);

    return f / 0.9375;
}

float pattern(in vec2 p, out vec2 q, out vec2 r) {
    q.x = complex_noise(p + vec2(-0.31415, 0.0));
    q.y = complex_noise(p + vec2(7.2, -7.4));

    r.x = complex_noise(p + 4.0 * q + vec2(10.95, 4.14));
    r.y = complex_noise(p + 4.0 * q + vec2(-E, -PHI));

    return complex_noise(p + 4.0 * r);
}

void main() {
    vec2 uv = gl_FragCoord.xy / uResolution.xy;

    // vec3 c1 = vec3(uv.xy, 0.0);
    // vec3 c2 = vec3(0.0, uv.xy);

    // float t = map(sin(uTime * TWO_PI * 0.4), -1.0, 1.0, 0.0, 1.0);
    // gl_FragColor = vec4((1.0 - t) * c1 + t * c2, 1.0);
    // //gl_FragColor = vec4(uv.x, uv.y, 0.0, 1.0);

    const vec3 c1 = vec3(0.831, 0.686, 0.216);
    const vec3 c2 = vec3(0.753, 0.753, 0.753);

    vec2 q, r;
    float p = pattern((gl_FragCoord.xy * 0.035) + vec2(2018.0, 2023.0), q, r);
    float n = complex_noise(gl_FragCoord.xy * 0.035 + vec2(2018.0, 2023.0));

    gl_FragColor = vec4(mix(mix(c1, c2, n) * p, c1, (q.x + r.y + n) * 0.333), 1.0);
}