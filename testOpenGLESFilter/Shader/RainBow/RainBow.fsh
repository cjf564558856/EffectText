precision highp float;
uniform sampler2D inputImageTexture;
uniform sampler2D inputImageTexture2;
uniform vec2 resolution;
varying vec2 textureCoordinate;

uniform float time;


vec4 returnColor(vec2 uv){

    vec4 color = texture2D(inputImageTexture,uv);
    vec4 color1 = texture2D(inputImageTexture2,uv);

//    bvec3 com = equal(color1.rgb,vec3(1.0));
//        if (any(com)){
//        color1 = mix(vec4(0.0),color,1.0);
//
//    }
    return color1;
}

void main(){
    vec2 uv = textureCoordinate;

    vec4 color = returnColor(vec2(uv.x + 0.2,uv.y));
    vec4 color1 = returnColor(vec2(uv.x + 0.4,uv.y));
    vec4 color2 = returnColor(vec2(uv.x - 0.2,uv.y));
    vec4 color3 = returnColor(vec2(uv.x - 0.4,uv.y));

    vec4 org = texture2D(inputImageTexture,uv);

    bvec3 com = greaterThan(color.rgb,vec3(0.1));
    bvec3 com1 = greaterThan(color1.rgb,vec3(0.1));

    if(any(com)){
        org = vec4(0.0);
    }
    if(any(com1)){
        org = vec4(0.0);
    }

    gl_FragColor = vec4(clamp(color.rgb + color1.rgb + color2.rgb + color3.rgb,vec3(0.0),vec3(1.0)),0.5);
}

//# 左大右小
//void main(){
//    vec2 uv = textureCoordinate;
//
//
//    vec2 ScaleTextureCoords = vec2(0.5, 0.5) + (uv - vec2(0.5, 0.5)) * 1.2;
//    vec2 ScaleTextureCoords1 = vec2(0.5, 0.5) + (uv - vec2(0.5, 0.5)) * 0.8;
//
//
//    vec4 color = returnColor(vec2(ScaleTextureCoords.x + 0.2,ScaleTextureCoords.y + 0.2));
//    vec4 color1 = returnColor(vec2(ScaleTextureCoords1.x - 0.2,ScaleTextureCoords1.y));
//
//    vec4 org = texture2D(inputImageTexture,uv);
//
//    bvec3 com = greaterThan(color.rgb,vec3(0.1));
//    bvec3 com1 = greaterThan(color1.rgb,vec3(0.1));
//
//    if(any(com)){
//        org = vec4(0.0);
//    }
//    if(any(com1)){
//        org = vec4(0.0);
//    }
//
//    gl_FragColor = clamp(color + color1 + org,vec4(0.0),vec4(1.0));
//}



//vec3 rgbcube(float p)
//{
//
//    float p1 = 1.0 / 20.0;
//
//    if(p <= 0.1) {
//       return vec3(1.0, 0.0, 0.0);
//    }else if(p > 0.1 && p <= 0.2){
//       return vec3(1.0 , 0.65, 0.0);
//    }else if(p > 0.2 && p <= 0.3){
//       return vec3(1.0, 1.0, 0.0);
//    }else if(p > 0.3 && p <= 0.4){
//       return vec3(0.0, 1.0, 0.0);
//    }else if(p > 0.4 && p <= 0.5){
//        return vec3(0.0, 0.5, 1.0);
//    }else if(p > 0.5 && p <= 0.6){
//        return vec3(0.0, 0.0, 1.0);
//    }else if(p > 0.6 && p <= 0.7){
//        return vec3(0.5, 0.0, 1.0);
//    }else if(p > 0.7 && p <= 0.8){
//        return vec3(1.0, 0.0, 0.0);
//    }else if(p > 0.8 && p <= 0.9){
//        return vec3(1.0 , 0.65, 0.0);
//    }
//    return vec3(1.0, 1.0, 0.0);
//}
//
//void main (void) {
//    vec2 uv = textureCoordinate;
//
//    vec3 rainbow = rgbcube(uv.y) ;
//    vec4 pic = texture2D(inputImageTexture, textureCoordinate);
//    vec4 mask = texture2D(inputImageTexture2, textureCoordinate);
//    gl_FragColor = vec4(mix(pic.xyz, rainbow, mask.x*0.6), pic.a);
//
//}

//void main (void) {
//    vec2 uv = textureCoordinate;
//    float prog = mod(time, 1.5) / 1.5;
//    vec2 p1 = vec2(0.0);
//    vec2 p2 = vec2(0.0);
//    if(prog <= 0.5){
//        p1 = vec2(1.0-prog/0.5, 1.0);
//        p2 = vec2(1.0, 1.0-prog/0.5);
//    }else{
//        p1 = vec2(0.0, 1.0 - (prog - 0.5)/0.5);
//        p2 = vec2(1.0 - (prog - 0.5)/0.5, 0.0);
//    }
//    float bo = 0.3;
//    float x = (1.0 - p2.y) / (p1.y - p2.y) * (p1.x - p2.x) + p2.x;
//    float y = (uv.x - p2.x) / (p1.x - p2.x) * (p1.y - p2.y) + p2.y;
//    float y2 = (uv.x - bo - p2.x) / (p1.x - p2.x) * (p1.y - p2.y) + p2.y;
//    if(uv.y > y && uv.y < y2) {
//        float offset_x = ((1.0 - (uv.y - y) - p2.y) / (p1.y - p2.y) * (p1.x - p2.x) + p2.x - x) / bo;
//        vec3 rainbow = rgbcube(offset_x) * 0.8;
//        vec4 pic = texture2D(inputImageTexture, textureCoordinate);
//        vec4 mask = texture2D(inputImageTexture2, textureCoordinate);
//        gl_FragColor = vec4(mix(pic.xyz, rainbow, mask.x*0.6), pic.a);
//    }else {
//        gl_FragColor = texture2D(inputImageTexture, textureCoordinate);
//    }
//}



//vec3 rgbcube(float p)
//{
//    if(p <= 0.15) {
//       float p2 = abs(p / 0.15);
//       if(p2 <= 0.5){
//           return vec3(1.0, 0.0, 0.5 - p2);
//       }
//       return vec3(1.0, p2 - 0.5, 0.0);
//    }else if(p > 0.15 && p <= 0.5){
//       float p2 = (abs(p - 0.15) / 0.35);
//       if(p2 <= 0.5){
//           return vec3(1.0, 0.5 + p2, 0.0);
//       }
//       return vec3(1.0 - (p2 - 0.5), 1.0, 0.0);
//    }else if(p > 0.5 && p <= 0.6){
//       float p2 = abs(p - 0.5) / 0.1;
//       if(p2 <= 0.5){
//           return vec3(0.5 - p2, 1.0, 0.0);
//       }
//       return vec3(0.0, 1.0, p2 - 0.5);
//    }else if(p > 0.6 && p <= 0.85){
//       float p2 = abs(p - 0.6) / 0.25;
//       if(p2 <= 0.5){
//           return vec3(0.0, 1.0, 0.5 + p2);
//       }
//       return vec3(0.0, 1.0 - (p2 - 0.5), 1.0);
//    }
//    float p2 = abs(p - 0.85) / 0.15;
//    if(p2 <= 0.5){
//       return vec3(0.0, 0.5 - p2, 1.0);
//    }
//    return vec3(p2 - 0.5, 0.0, 1.0);
//}
