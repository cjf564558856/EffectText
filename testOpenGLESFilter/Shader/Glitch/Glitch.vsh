attribute vec4 position;
attribute vec2 inputTextureCoordinate;
varying vec2 textureCoordinate;

void main (void) {
    gl_Position = position;
    textureCoordinate = inputTextureCoordinate;
}
