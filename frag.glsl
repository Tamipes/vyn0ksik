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

float hash2(vec2 v, in float seed) {
  const vec2 k = vec2(0.3183099, 0.3678794);
  float h = dot(v, k);
  h = fract(sin(h) * 43758.5453123);
  return h;
}

float noise(in vec2 x) {
    vec2 p = floor(x);
    vec2 f = fract(x);
    f = f * f * (3.0 - 2.0 * f);

    float a = hash2(p + vec2(0, 0), 2018.2023);
    float b = hash2(p + vec2(1, 0), 2018.2023);
    float c = hash2(p + vec2(0, 1), 2018.2023);
    float d = hash2(p + vec2(1, 1), 2018.2023);
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
    q.x = complex_noise(p + vec2(-0.31415, 0.0) * uTime * 0.3);
    q.y = complex_noise(p + vec2(7.2, -7.4) * -uTime * 0.03);

    r.x = complex_noise(p + 4.0 * q + vec2(10.95, 4.14) * uTime * 0.03);
    r.y = complex_noise(p + 4.0 * q + vec2(-E, -PHI) * -uTime * 0.1);

    return complex_noise(p + 4.0 * r);
}

#define COLOR_COUNT 2
vec3 COLORS[COLOR_COUNT]; // WebGL officially sucks and should be very much ashamed of itself

vec3 color_interpolation(float t) {
    int index1 = int(floor(t * float(COLOR_COUNT - 1)));
    int index2 = index1 + 1;
    
    float weight = fract(t * float(COLOR_COUNT - 1));
    vec3 c1;
    vec3 c2;

    for (int k = 0; k < COLOR_COUNT; ++k)
    {
        if (index1 == k)
        {
            c1 = COLORS[k];
        }
        else if (index2 == k)
        {
            c2 = COLORS[k];
        }
    }

    return mix(c1, c2, weight);
}

void main() {
    COLORS[0] = vec3(.831, .686, .216);
    COLORS[1] = vec3(.753, .753, .753);    

    vec2 uv = gl_FragCoord.xy / uResolution.xy;

    vec2 q, r;
    float p = pattern((gl_FragCoord.xy * 0.035) + vec2(2018.0, 2023.0), q, r);
    float n = complex_noise(gl_FragCoord.xy * 0.035 + vec2(2018.0, 2023.0));

    gl_FragColor = vec4(mix(color_interpolation(n) * p, color_interpolation(mod(n * 515.412, 1.0)), (q.x + r.y + n) * 0.333), 1.0);
}