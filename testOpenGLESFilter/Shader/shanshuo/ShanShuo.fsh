precision highp float;

uniform sampler2D inputImageTexture;
varying vec2 textureCoordinate;

uniform float time;

float sigmoid(float x, float k){
    return (x - k*x)/(k - 2.*k*abs(x) + 1.);
}

vec4 twinkleStar(vec2 uv, vec2 offset, float scale, float timeOffset){
    uv += offset;
    
    uv -= 0.5;
    uv *= 2.;
    uv *= scale;
    
    vec2 normalUV  = uv;
    
    uv.x = abs(uv.x);
    uv.y = abs(uv.y);
    
    float limit = step(1.0, step(1.0, uv.x) + step(1.0, uv.y));
    
    limit = 1. - limit;
    
    uv.x = 1.-uv.x;
    
    float currentTime = time + timeOffset;
    float animTime = sin(currentTime * 3.14 * 2.)*0.5 + 0.5;
    float value = 1. - step(sigmoid(uv.x - 0.005, 0.9 + animTime*0.1) - 0.005, uv.y);
    
    float animTime2 = sin(currentTime * 5.)*0.5 + 0.5;
    float ring = sigmoid(1.-length(normalUV), 0.8);
    value *= sigmoid(1.-length(normalUV), 0.1) * 1.5;
    value = min(1., value);
    
    return vec4(1.,1.,1.,1.0)*value*limit;
}

void main()
{
    vec2 uv = textureCoordinate;
    
    gl_FragColor = twinkleStar(uv, vec2(-0.5,-0.5), 3.0, 1.0) +
    twinkleStar(uv, vec2(-1.2,-0.8), 2.0, 0.25) +
    twinkleStar(uv, vec2(-1.5,0.3), 1.5, 0.4) +
    twinkleStar(uv, vec2(-2.1,-0.5), 1.75, 0.15);
}
