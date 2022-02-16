precision highp float;
varying vec2 textureCoordinate;
uniform sampler2D inputImageTexture;
uniform vec2 resolution;
uniform float sharpness;

void main() {
    float w = 1.0 / resolution.x;
    float h = 1.0 / resolution.y;
    vec4 texLeftColor = texture2D(inputImageTexture, textureCoordinate + vec2(-w, 0.0));
    vec4 texRightColor = texture2D(inputImageTexture, textureCoordinate + vec2(w, 0.0));
    vec4 texTopColor = texture2D(inputImageTexture, textureCoordinate + vec2(0.0, h));
    vec4 texBottomColor = texture2D(inputImageTexture, textureCoordinate + vec2(0.0, -h));
    vec4 texColor = texture2D(inputImageTexture, textureCoordinate);
    float centerMultiplier = 1.0 + 4.0 * sharpness / 100.0;
    vec4 z = sharpness * (texLeftColor + texRightColor + texTopColor + texBottomColor) / 100.0;
    gl_FragColor = (texColor * centerMultiplier) - z;
}



