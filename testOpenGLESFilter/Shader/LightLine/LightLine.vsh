
attribute vec3 position;
attribute vec2 inputTextureCoordinate;
varying vec2 textureCoordinate;
uniform mat4 transform;

void main()
{
    gl_Position = transform * vec4(position,1.0);
    textureCoordinate = inputTextureCoordinate;
}
