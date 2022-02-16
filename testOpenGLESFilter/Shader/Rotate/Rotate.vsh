attribute vec3 position;
attribute vec2 inputTextureCoordinate;

varying vec2 textureCoordinate;

uniform mat4 transform;
uniform vec2 translate;
uniform float scale;
void main()
{
    gl_Position = transform * vec4(position.x * scale - translate.x,
                                   position.y * scale - translate.y,
                                   position.z, 1.0);
    textureCoordinate = inputTextureCoordinate;
}


