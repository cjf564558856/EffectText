precision highp float;
varying vec2 textureCoordinate;
uniform sampler2D inputImageTexture;
uniform sampler2D inputImageTexture2;
uniform vec2 resolution;


vec4 returnLineColor(sampler2D tex,vec2 uv){
    
    vec2 delta = 1.0/resolution;
    vec4 maxColor = vec4(-1.0);
    int ksize = 2;
    for (int i = -1 * ksize; i <= ksize ; i++) {
        for (int j = -1 * ksize; j <= ksize; j++) {
            float x = uv.x + float(i) * delta.x;
            float y = uv.y + float(i) * delta.y;
            maxColor = clamp(max(texture2D(tex, vec2(x, y)), maxColor) - vec4(0.0,1.0,0.0,0.0), vec4(0.0), vec4(1.0));
        }
    }

    return maxColor;
}

void main() {
    
    vec4 texColor = returnLineColor(inputImageTexture2,vec2(textureCoordinate.x - 0.2,textureCoordinate.y));
    vec4 texColor1 = returnLineColor(inputImageTexture2,vec2(textureCoordinate.x + 0.2,textureCoordinate.y));


    vec4 color = texture2D(inputImageTexture, textureCoordinate);
    
    vec4 orgMask = texture2D(inputImageTexture2, textureCoordinate);

    bvec3 com = greaterThan(orgMask.rgb,vec3(0.1));

    if(any(com)){
        texColor = vec4(0.0);
        texColor1 = vec4(0.0);
    }
    
    gl_FragColor = clamp(texColor + texColor1 + orgMask,vec4(0.0),vec4(1.0));

}

//void main() {
//
//    vec4 texColor = texture2D(inputImageTexture, textureCoordinate);
//
//    vec2 delta = 1.0/resolution;
//    vec4 maxColor = vec4(-1.0);
//    int ksize = 4;
//    for (int i = -1 * ksize; i <= ksize ; i++) {
//        for (int j = -1 * ksize; j <= ksize; j++) {
//            float x = textureCoordinate.x + float(i) * delta.x;
//            float y = textureCoordinate.y + float(i) * delta.y;
//            maxColor = clamp(max(texture2D(inputImageTexture2, vec2(x, y)), maxColor) - vec4(0.0,1.0,0.0,0.0), vec4(0.0), vec4(1.0));
//
//        }
//    }
//    bvec3 com = greaterThanEqual(maxColor.rgb,vec3(0.1));
//
//    if (any(com)) {
//        texColor = vec4(0.0);
//    }
//
//    gl_FragColor =  clamp(texColor + maxColor , vec4(0.0), vec4(1.0));
//}

//void main() {
//    vec2 delta = 1.0/resolution;
//    vec4 maxColor = vec4(-1.0);
//    int ksize = 5;
//    vec4 texColor = texture2D(inputImageTexture2, textureCoordinate);
//    for (int i = -1 * ksize; i <= ksize ; i++) {
//        for (int j = -1 * ksize; j <= ksize; j++) {
//            float x = textureCoordinate.x + float(i) * delta.x;
//            float y = textureCoordinate.y + float(i) * delta.y;
//            maxColor = max(texture2D(inputImageTexture2, vec2(x, y)), maxColor);
//        }
//    }
//
//    bvec3 com = greaterThan(texColor.rgb, vec3(0.5));
//    vec4 color = texture2D(inputImageTexture, textureCoordinate);
//    if(any(com)) {
//        texColor = vec4(1.0);
//    }
//    gl_FragColor = clamp(maxColor + texColor + color, vec4(0.0), vec4(1.0));
//}




