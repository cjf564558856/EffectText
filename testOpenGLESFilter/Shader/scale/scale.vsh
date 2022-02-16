attribute vec4 position;
attribute vec2 inputTextureCoordinate;
varying vec2 textureCoordinate;

uniform float time;

const float PI = 3.1415926;

void main (void) {
    float duration = 0.6;
    float maxAmplitude = 0.3;
    
    float _time = mod(time, duration);
    float amplitude = 1.0 + maxAmplitude * abs(sin(_time * (PI / duration)));
    
    gl_Position = vec4(position.x * amplitude, position.y * amplitude, position.zw);
    textureCoordinate = inputTextureCoordinate;
}


