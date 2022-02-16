
precision highp float;

attribute vec2 position;
attribute vec2 inputTextureCoordinate;

varying vec2 uv1;
varying vec2 uv0;

const int flag = 2;
const float sizeRatio = 2.0;

void main() {
    gl_Position = vec4(position, 0.0, 1.0);
    uv0 = inputTextureCoordinate.xy;
    uv1 = inputTextureCoordinate.xy;
    uv1 = vec2(uv0.x - 0.5, uv0.y - 0.5);
    if(flag > 1){
        uv1.y = uv1.y * sizeRatio * 1.0;
        uv1.x = uv1.x * 1.0;
    }else{
        uv1.x = uv1.x * sizeRatio * 1.0;
        uv1.y = uv1.y * 1.0;
    }
    uv1 = vec2(uv1.x + 0.5, uv1.y + 0.5);
}
