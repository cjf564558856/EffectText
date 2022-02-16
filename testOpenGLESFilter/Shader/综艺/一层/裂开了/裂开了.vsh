precision highp float;

attribute vec4 position;
attribute vec2 inputTextureCoordinate;
varying vec2 textureCoordinate;

void main() 
{ 
    // mat2 ratio = mat2(inputWidth, 0.0, 0.0, inputHeight);
    // mat2 ratio_inv = mat2(1.0/inputWidth, 0.0, 0.0, 1.0/inputHeight);
    // float theta = ori * 3.14/180.;
    // mat2 rotation = mat2(cos(theta), -sin(theta), sin(theta), cos(theta));
    // vec2 pos = position.xy ;
    // pos = ratio_inv * rotation * ratio * pos;
    
    // gl_Position = vec4(pos.xy,0.0,1.0);
    gl_Position = vec4(position.xyz,1.0);
    textureCoordinate = inputTextureCoordinate;
    

}
