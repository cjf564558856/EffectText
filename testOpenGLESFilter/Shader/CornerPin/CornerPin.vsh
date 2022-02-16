attribute vec3 position;
attribute vec2 inputTextureCoordinate;
varying vec2 textureCoordinate;

uniform mat4 viewProjectionMatrix;

void main()
{
    gl_Position = viewProjectionMatrix * vec4(position, 1.0);
    //gl_Position = vec4(position, 1.0);
    textureCoordinate = inputTextureCoordinate;
}

