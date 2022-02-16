precision highp float;
varying vec2 textureCoordinate;
uniform sampler2D inputImageTexture;
uniform vec2 resolution;
uniform vec2 center;
uniform int num;
uniform bool rotate;
#define samples 5

const float PI = 3.141592653589793;

/* random number between 0 and 1 */
float random(in vec3 scale, in float seed) {
    /* use the fragment position for randomness */
    return fract(sin(dot(gl_FragCoord.xyz + seed, scale)) * 43758.5453 + seed);
}

vec4 crossFade(in vec2 uv, in float dissolve) {
    return texture2D(inputImageTexture, uv).rgba;
}

void main() {

    float ratio = resolution.x / resolution.y;
    vec2 uv = vec4((textureCoordinate.x * 2.0 - 1.0) * ratio, textureCoordinate.y * 2.0 - 1.0, 0.0, 1.0).xy;

    uv.x = (uv.x / ratio + 1.0) / 2.0;
    uv.y = (uv.y + 1.0) / 2.0;

    vec4 color = vec4(0.0);
    float total = 0.0;
    vec2 toCenter = center - uv;
    float dissolve = 0.5;
    float blurStep = 0.05;

    /* randomize the lookup values to hide the fixed number of samples */
    float offset = random(vec3(12.9898, 78.233, 151.7182), 0.0);

    for (int t = 0; t <= samples; t++) {
        float percent = (float(t) + offset) / float(samples);
        percent = 2.0 * percent - 1.0;
        //float weight = 4.0 * (percent - percent * percent);
        float weight = 4.0 * (0.5*(percent + 1.0) - pow(0.5 * (percent + 1.0), 2.0));
        vec2 curUV = vec2(0.0);
        if(rotate) {
            //float theta = 0.037 * PI * percent;
            float theta = float(num) / 350.0 * PI * percent;
            vec2 diff = (uv - center) * resolution;
            vec2 rotateDir = vec2(diff.x * cos(theta) - diff.y * sin(theta), diff.x * sin(theta) + diff.y * cos(theta));
            curUV = center + (rotateDir / resolution);
        }else {
            curUV = uv + (toCenter * percent * float(num) / 350.0);
        }
        vec2 uvT = vec2(1.0 - abs(abs(curUV.x) - 1.0), 1.0 - abs(abs(curUV.y) - 1.0));
        color += crossFade(uvT, dissolve) * weight;
        total += weight;
    }
    vec4 result = color / total * step(uv.x, 2.0) * step(uv.y, 2.0) * step(-1.0, uv.x) * step(-1.0, uv.y);
    gl_FragColor = result*1.0;
}


