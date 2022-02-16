
precision highp float;
varying vec2 textureCoordinate;
uniform sampler2D inputImageTexture;
uniform sampler2D inputImageTexture2;
uniform vec2 resolution;

void main() {

    gl_FragColor = texture2D(inputImageTexture2, textureCoordinate);
}
