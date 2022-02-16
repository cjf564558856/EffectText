
precision highp float;
uniform sampler2D inputImageTexture;
uniform sampler2D inputImageTexture2;
uniform vec2 resolution;
varying vec2 textureCoordinate;

uniform float time;

void main (void) {

    gl_FragColor = texture2D(inputImageTexture, textureCoordinate);

}
