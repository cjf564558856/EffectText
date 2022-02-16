
precision highp float;
varying vec2 textureCoordinate;
uniform sampler2D inputImageTexture;
uniform sampler2D inputImageTexture2;
uniform vec2 resolution;


uniform float time;

float rand(float n) {
    return fract(cos(n) * 43758.5453123);
}

void main() {
    
    float alpha = rand(time/10.0);
    
    vec4 texColor = texture2D(inputImageTexture2, textureCoordinate);
    vec4 color = texture2D(inputImageTexture, textureCoordinate);

    bvec3 com = greaterThan(texColor.rgb, vec3(0.07));
    if(any(com)) {
        texColor = vec4(alpha,alpha,alpha,1.0);
    }
    gl_FragColor = clamp(texColor + color, vec4(0.0), vec4(1.0));
}

