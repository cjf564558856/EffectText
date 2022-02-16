precision highp float;
varying vec2 textureCoordinate;
uniform sampler2D inputImageTexture;
uniform sampler2D inputImageTexture2;
uniform vec2 resolution;

void main() {
    vec2 delta = 1.0/resolution;
    vec4 maxColor = vec4(-1.0);
    int ksize = 3;
    for (int i = -1 * ksize; i <= ksize ; i++) {
        for (int j = -1 * ksize; j <= ksize; j++) {
            float x = textureCoordinate.x + float(i) * delta.x;
            float y = textureCoordinate.y + float(i) * delta.y;
            maxColor = max(texture2D(inputImageTexture2, vec2(x, y)), maxColor);
        }
    }
    vec4 color = texture2D(inputImageTexture, textureCoordinate);
    gl_FragColor = vec4(maxColor.rgb + color.rgb, color.a);
}

