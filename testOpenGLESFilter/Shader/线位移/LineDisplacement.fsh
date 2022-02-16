
precision highp float;
uniform sampler2D inputImageTexture;
uniform sampler2D inputImageTexture2;
uniform vec2 resolution;
varying vec2 textureCoordinate;

uniform float time;

const float PI = 3.141592653;
float rand(float n) {
    return fract(sin(n) * 43758.5453123);
}

void main (void) {
    float duration = 2.0;
    float maxJitter = 0.3;
    float maxBorder = 10.0;
    float progress = mod(time, duration * 2.0);
    float amplitude = max(abs(sin(progress * (2.0 * PI / duration))), 0.1);
    float border = max(abs(maxBorder * sin(progress * (PI / duration))), 1.0);
    float jitter = rand(textureCoordinate.y) * 2.0 - 1.0; // -1~1
    bool needOffset = abs(jitter) < maxJitter * amplitude;
    
    float textureX = textureCoordinate.x + (needOffset ? -1.0 * jitter : (jitter * amplitude * 0.02));
    float margin = ceil(textureCoordinate.y * resolution.y / border) / (resolution.y / border);
    vec2 textureCoords = vec2(textureX, margin);
    
    vec4 img = texture2D(inputImageTexture, textureCoordinate);
    vec4 mask = texture2D(inputImageTexture, textureCoords);
    vec4 mask2 = texture2D(inputImageTexture2, textureCoordinate);

    gl_FragColor = mix(img, mask, mask2.r);
}

