precision highp float;

attribute vec3 position;
attribute vec2 inputTextureCoordinate;
varying vec2 textureCoordinate;


void main() {
    gl_Position = vec4(position, 1.0);
    textureCoordinate.xy = inputTextureCoordinate.xy;
//    gl_Position = vec4(position, 1.);
//    textureCoordinate = (inputTextureCoordinate - 0.5) / 1.0 + 0.5;
    
}
