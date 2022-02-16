precision highp float;
varying vec2 textureCoordinate;
uniform sampler2D inputImageTexture;
uniform sampler2D inputImageTexture2;
uniform vec2 resolution;
uniform float time;

float alpha = 0.0;
float blurStep = 0.0;
const float duration = 3.5;
const vec2 blurDirection = vec2(1.0, 1.0);
#define num 10

const float PI = 3.141592653589793;

/* random number between 0 and 1 */
float random(in vec3 scale, in float seed) {
    /* use the fragment position for randomness */
    return fract(sin(dot(gl_FragCoord.xyz + seed, scale)) * 43758.5453 + seed);
}

vec4 crossFade(in vec2 uv, in float dissolve) {
    return texture2D(inputImageTexture, uv).rgba;
}

vec4 directionBlur(sampler2D tex, vec2 r, vec2 uv, vec2 directionOfBlur, float intensity)
{
    vec2 pixelStep = 1.0/r * intensity;
    float dircLength = length(directionOfBlur);
    pixelStep.x = directionOfBlur.x * 1.0 / dircLength * pixelStep.x;
    pixelStep.y = directionOfBlur.y * 1.0 / dircLength * pixelStep.y;

    vec4 color = vec4(0);
    for(int i = -num; i <= num; i++)
    {
       vec2 blurCoord = uv + pixelStep * float(i);
       vec2 uvT = vec2(1.0 - abs(abs(blurCoord.x) - 1.0), 1.0 - abs(abs(blurCoord.y) - 1.0));
       color += texture2D(tex, uvT);
    }
    color /= float(2 * num + 1);
    return color;
}

vec3 refract0(vec3 i, vec3 n, float eta) {
    float cosi = dot(-i, n);
    float cost2 = 1.0 - eta * eta * (1.0 - cosi * cosi);
    vec3 t = eta * i + ((eta * cosi - sqrt(abs(cost2))) * n);
    return t;
}

void main() {

    float ratio = resolution.x / resolution.y;
    vec2 uv = (vec4((textureCoordinate.x * 2.0 - 1.0) * ratio, textureCoordinate.y * 2.0 - 1.0, 0.0, 1.0)).xy;

    uv.x = (uv.x / ratio + 1.0) / 2.0;
    uv.y = (uv.y + 1.0) / 2.0;
    
    float prog = mod(time, duration) / duration;
    float d = 0.7;
    alpha = (prog <= 0.15) ? (prog / 0.15) : 1.0;
    blurStep = 1.2 * sin(PI * prog / d);
    vec4 resultColor = vec4(0.0);
    if(prog <= d) {
        float stime = sin(prog / d * 0.2 * PI);
        float phase = prog / d * PI * 2.0;
        vec2 s_uv = uv / (0.05 * (abs(sin(phase)) * (1.0 - stime)) + 1.0);
        resultColor = directionBlur(inputImageTexture,resolution,s_uv,blurDirection,blurStep);
    }else{
        resultColor = texture2D(inputImageTexture, uv);
    }
    vec4 effect = texture2D(inputImageTexture2, uv);
    vec4 result = mix(vec4(resultColor.rgb, resultColor.a) * step(uv.x, 2.0) * step(uv.y, 2.0) * step(-1.0, uv.x) * step(-1.0, uv.y), effect, effect.r);
    gl_FragColor = result*alpha;
}


