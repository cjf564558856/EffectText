precision highp float;
uniform sampler2D inputImageTexture;
uniform vec2 resolution;
varying vec2 textureCoordinate;

uniform bool horizontal;
uniform float level;

const float PI = 3.141592653589793;
float caculateWeight(float radius){
    float delta = level;
    float e_factor = (-1.0 * pow(radius,2.0)) / (2.0 * delta);
    return (1.0 / (sqrt(delta) * sqrt(2.0 * PI))) * exp(e_factor);
}

void main (void) {
    vec2 tex_offset = 1.0 / resolution;
    float weight0 = caculateWeight(0.0);
    vec3 result = texture2D(inputImageTexture, textureCoordinate).rgb * weight0;
    float factor = weight0;
    int blur_radius = int(level);
    if(horizontal) {
        for(int i = 1; i < blur_radius; ++i) {
            float weight_r= caculateWeight(float(i));
            float weight_l= caculateWeight(float(-1 * i));
            factor += (weight_r + weight_l);
            result += texture2D(inputImageTexture, textureCoordinate + vec2(tex_offset.x * float(i), 0.0)).rgb * weight_r;
            result += texture2D(inputImageTexture, textureCoordinate - vec2(tex_offset.x *
                float(i), 0.0)).rgb * weight_l;
        }
    }else{
        for(int i = 1; i < blur_radius; ++i) {
            float weight_r= caculateWeight(float(i));
            float weight_l= caculateWeight(float(-1 * i));
            factor += (weight_r + weight_l);
            result += texture2D(inputImageTexture, textureCoordinate + vec2(0.0, tex_offset.y * float(i))).rgb * weight_r;
            result += texture2D(inputImageTexture, textureCoordinate - vec2(0.0, tex_offset.y * float(i))).rgb * weight_l;
        }
    }
    gl_FragColor = vec4(result/factor, 1.0);
}
