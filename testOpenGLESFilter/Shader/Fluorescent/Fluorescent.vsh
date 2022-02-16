attribute vec3 position;
attribute vec2 inputTextureCoordinate;
varying vec2 textureCoordinate;

void main()
{
//    gl_Position = transform * vec4(position.x * scale + translate.x,
//                                   position.y * scale - translate.y,
//                                   position.z, 1.0);
    gl_Position = vec4(position, 1.0);
    textureCoordinate = inputTextureCoordinate;
}




