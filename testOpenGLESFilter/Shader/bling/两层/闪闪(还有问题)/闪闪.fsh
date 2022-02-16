precision highp float;

varying vec2 uv0;
varying vec2 uv1;

uniform sampler2D inputImageTexture;
uniform sampler2D inputImageTexture2;
uniform sampler2D maskTexture;
uniform sampler2D _MainTex;

const float starThreshold = 10.0;
const float edgerange = 5.0;
const float maskThreshold = 0.1;
const int baseTexHeight = 300;
const int baseTexWidth = 300;
const float brightness = 0.5;

float blendScreen(float base,float blend){
    return 1.-((1.-base)*(1.-blend));
}

vec3 blendScreen(vec3 base,vec3 blend){
    return vec3(blendScreen(base.r,blend.r),blendScreen(base.g,blend.g),blendScreen(base.b,blend.b));
}

vec3 blendMultiply(vec3 base,vec3 blend){
    return base*blend;
}

// lighten
float blendLighten(float base, float blend) {
    return max(blend,base);
}

vec3 blendLighten(vec3 base, vec3 blend) {
    return vec3(blendLighten(base.r,blend.r),blendLighten(base.g,blend.g),blendLighten(base.b,blend.b));
}

vec3 blendFunc(vec3 base, vec3 blend, float opacity){
    return (blendLighten(base, blend) * opacity + base * (1.0 - opacity));
}

void main() 
{
    vec4 inputImageColor = texture2D(_MainTex, uv1);
    vec4 mainColor = texture2D(inputImageTexture2, uv0);
    vec4 grayColor = texture2D(inputImageTexture, uv0);
    vec4 maskColor = texture2D(maskTexture, vec2(uv0.x, 1.0-uv0.y));

    vec4 resColor;
    float grayValue = dot(grayColor.rgb, vec3(0.3, 0.59, 0.11));

    float range = 0.5;
    float threshold = 0.1;
    grayValue = smoothstep(range, threshold, grayValue);

    // float flag = step(maskColor.x, maskThreshold);

    // if(maskColor.x > maskThreshold)
    // {
    vec4 resColor0 = vec4(mainColor.rgb, 1.0);
    // }
    // else
    // {
    vec4 resColor1 = vec4(blendFunc(mainColor.rgb, inputImageColor.rgb, inputImageColor.a), 1.0);
    vec4 resColor2 = vec4(mainColor.rgb, 1.0);
    vec4 resColor3 = mix(resColor2, resColor1, smoothstep(threshold , threshold + range, grayValue));
    // }
    resColor = mix(resColor3, resColor0, step(maskThreshold, maskColor));
    gl_FragColor = resColor;
}
