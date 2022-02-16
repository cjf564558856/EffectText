precision highp float;
uniform sampler2D inputImageTexture;
varying vec2 textureCoordinate;
uniform float time;
#define PI 3.14159265359

float rand(float n) {
    return fract(sin(n) * 43758.5453123);
}

vec4 tyndall_rays(vec2 texCoords, vec2 pos) {
    float decay = 0.82;
    float density = 1.0;
    float weight = 0.37767;
    int num_samples = 8;
    vec2 tc = texCoords.xy;
    //vec2 delta = abs(pos.xy - tc);
    vec2 delta = tc - pos.xy;
    delta *= (1.0 / float(num_samples) * density);
    float illuminationDecay = 0.92;
    vec4 color = texture2D(inputImageTexture, tc.xy) * vec4(0.55);
    tc += delta * fract( sin(dot(texCoords.xy, vec2(12.9898, 78.233))) * 43758.5453 );
    //tc += delta * fract( sin(dot(texCoords.xy, vec2(8.9898, 78.233))) * 43.5453 );
    for (int i = 0; i < num_samples; i++) {
        tc -= delta;
        vec4 sampleTex  = texture2D(inputImageTexture, tc.xy) * vec4(0.55);
        sampleTex *= illuminationDecay * weight;
        color += sampleTex;
        illuminationDecay *= decay;
    }
    return color;
}

void main (void) {
    vec3 pos = vec3(0.65, 1.2, 1.0);
    vec2 cen = vec2(0.70, 1.28);
    float theta = 2.0 * PI * (mod(time, 6.0) / 6.0);
    pos.x= (pos.x - cen.x)*cos(theta) - (pos.y - cen.y)*sin(theta) + cen.x;
    pos.y= (pos.x - cen.x)*sin(theta) + (pos.y - cen.y)*cos(theta) + cen.y;

    float exposure = 0.95;
    vec4 effect = tyndall_rays(textureCoordinate, pos.xy);
    gl_FragColor = vec4(effect.rgb * exposure, 1.0);
}


