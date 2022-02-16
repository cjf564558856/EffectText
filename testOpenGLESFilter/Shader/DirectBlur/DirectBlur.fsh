precision highp float;
varying vec2 textureCoordinate;
uniform sampler2D inputImageTexture;
uniform vec2 resolution;
uniform float blurStep;
uniform float angle;
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
    vec2 uv = vec4((textureCoordinate.x * 2.0 - 1.0) * ratio, textureCoordinate.y * 2.0 - 1.0, 0.0, 1.0).xy;
    uv.x = (uv.x / ratio + 1.0) / 2.0;
    uv.y = (uv.y + 1.0) / 2.0;
    float theta = (angle / 360.0) * PI * 2.0;
    vec2 diff = vec2(0.5, 0.5) - vec2(0.5, 1.0);
    vec2 dir = normalize(diff);
    float c = cos(theta);
    float s = sin(theta);
    vec2 blurDirection = vec2(dir.x * c - dir.y * s, dir.x * s + dir.y * c);
    //vec2 blurDirection = normalize(dir);
    vec4 resultColor = directionBlur(inputImageTexture,resolution,uv,blurDirection, blurStep/10.0);
    vec4 result = vec4(resultColor.rgb, resultColor.a) * step(uv.x, 2.0) * step(uv.y, 2.0) * step(-1.0, uv.x) * step(-1.0, uv.y);
    gl_FragColor = result*1.0;
}


