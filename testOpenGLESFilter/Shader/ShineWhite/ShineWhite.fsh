precision highp float;

uniform sampler2D inputTextureCoordinate;
varying vec2 textureCoordinate;

uniform float time;

const float PI = 3.1415926;

void main (void) {
    float duration = 0.6;
    
    float progress = mod(time, duration);
    
    vec4 whiteMask = vec4(1.0, 1.0, 1.0, 1.0);
    float amplitude = abs(sin(progress * (PI / duration)));
    
    vec4 mask = texture2D(inputTextureCoordinate, textureCoordinate);
    
    gl_FragColor = mix(mask,whiteMask,amplitude);
}
