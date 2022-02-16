precision highp float;

uniform sampler2D inputImageTexture;
varying vec2 textureCoordinate;

uniform float time;

const float PI = 3.1415926;

float rand(float n) {
    return fract(sin(n) * 43758.5453123);
}

void main (void) {
    float maxJitter = 0.06;
    float duration = 0.3;
    float colorROffset = 0.01;
    float colorBOffset = -0.025;
    
    float progress = mod(time, duration * 2.0);
    float amplitude = max(sin(progress * (PI / duration)), 0.0);
    
    float jitter = rand(textureCoordinate.y) * 2.0 - 1.0; // -1~1
    bool needOffset = abs(jitter) < maxJitter * amplitude;
    
    float textureX = textureCoordinate.x + (needOffset ? jitter : (jitter * amplitude * 0.006));
    vec2 textureCoords = vec2(textureX, textureCoordinate.y);
    
    vec4 mask = texture2D(inputImageTexture, textureCoords);
    vec4 maskR = texture2D(inputImageTexture, textureCoords + vec2(colorROffset * amplitude, 0.0));
    vec4 maskB = texture2D(inputImageTexture, textureCoords + vec2(colorBOffset * amplitude, 0.0));
    
    gl_FragColor = vec4(maskR.r, mask.g, maskB.b, mask.a);
}
