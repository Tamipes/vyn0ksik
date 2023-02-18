precision mediump float;

#define PI 3.14159265358979
#define TWO_PI 6.28318530717958

uniform vec2 uResolution;
uniform float uTime;

float map(float value, float imin, float imax, float omin, float omax)
{
    return omin + (value - imin) / (imax - imin) * (omax - omin);
}

void main()
{
    vec2 uv = gl_FragCoord.xy/uResolution.xy;

    vec3 c1 = vec3(uv.xy, 0.0);
    vec3 c2 = vec3(0.0, uv.xy);

    float t = map(sin(uTime * TWO_PI * 0.4), -1.0, 1.0, 0.0, 1.0);
    gl_FragColor = vec4((1.0 - t) * c1 + t * c2, 1.0);
    //gl_FragColor = vec4(uv.x, uv.y, 0.0, 1.0);
}