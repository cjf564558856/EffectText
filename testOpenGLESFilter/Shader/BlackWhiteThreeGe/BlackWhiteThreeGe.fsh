precision highp float;

uniform sampler2D inputImageTexture;
uniform sampler2D inputImageTexture2;

varying vec2 textureCoordinate;

void main() {
    
    
    vec4 clearColor = clamp(texture2D(inputImageTexture, textureCoordinate), 0.0, 1.0);
    vec4 blurColor = clamp(texture2D(inputImageTexture2, textureCoordinate.xy), 0.0, 1.0);
    //front filter
    highp float blueColor = clearColor.b * 63.0;
    highp vec2 quad1;
    quad1.y = floor(floor(blueColor) / 8.0);
    quad1.x = floor(blueColor) - (quad1.y * 8.0);
    highp vec2 texPos1;
    texPos1.x = (quad1.x * 0.125) + 0.5/512.0 + ((0.125 - 1.0/512.0) * clearColor.r);
    texPos1.y = (quad1.y * 0.125) + 0.5/512.0 + ((0.125 - 1.0/512.0) * clearColor.g);
    lowp vec4 newColorFront = texture2D(inputImageTexture, textureCoordinate);

    newColorFront.a = clearColor.a;

    if(textureCoordinate.y > 0.5 - 0.33 / 2.0 && textureCoordinate.y < 0.5 + 0.33 / 2.0){
        gl_FragColor = newColorFront;
    }
    else{
        float luminance = dot(clearColor.rgb, vec3(0.2125, 0.7154, 0.0721));
        
        gl_FragColor = vec4(vec3(luminance), clearColor.a);
    }
//
//    vec4 clearColor = texture2D(inputImageTexture, textureCoordinate);
//    //front filter
//    highp float blueColor = clearColor.b * 63.0;
//    highp vec2 quad1;
//    quad1.y = floor(floor(blueColor) / 8.0);
//    quad1.x = floor(blueColor) - (quad1.y * 8.0);
//    highp vec2 texPos1;
//    texPos1.x = (quad1.x * 0.125) + 0.5/512.0 + ((0.125 - 1.0/512.0) * clearColor.r);
//    texPos1.y = (quad1.y * 0.125) + 0.5/512.0 + ((0.125 - 1.0/512.0) * clearColor.g);
//    lowp vec4 newColor= texture2D(inputImageTexture, texPos1);
//
//    newColor.a = clearColor.a;
//    gl_FragColor = newColor;
}
