attribute vec3 position;
attribute vec2 inputTextureCoordinate;

varying vec2 textureCoordinate;
uniform mat4 transform;
uniform vec2 translate;
uniform float scale;
void main()
{
    gl_Position = vec4(position, 1.0);
    textureCoordinate = inputTextureCoordinate;
}
