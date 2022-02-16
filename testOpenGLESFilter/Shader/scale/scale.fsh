precision highp float;

uniform sampler2D inputImageTexture;
varying vec2 textureCoordinate;

void main (void) {
    gl_FragColor = texture2D(inputImageTexture, textureCoordinate);
}

