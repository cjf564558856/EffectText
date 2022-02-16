
precision highp float;
uniform sampler2D inputImageTexture;
uniform sampler2D inputImageTexture2;
uniform vec2 resolution;
varying vec2 textureCoordinate;
uniform float time;

const float PI = 3.14159265359;
const float fov = 50.0;
const float fovx = PI * fov / 360.0;
const float S = 0.01;
const vec3 deltax = vec3(S ,0, 0);
const vec3 deltay = vec3(0 ,S, 0);
const vec3 deltaz = vec3(0 ,0, S);


void main (void) {
    vec2 uv = textureCoordinate.xy;

    float t = 15.0 - mod(time * 4.0,15.0);

    float count = 5.0;

    uv *= 10.0;
    float color = 0.0;
    
    
    if (t <= 10.0) {
        if (uv.y < t && uv.y > 0.99 && uv.y > t - 5.0 ) {
            float dx =  mod(uv.y, floor(uv.y));

            color = 1.0 - step(dx,0.97);
        }
    }else{
        if (uv.y > t - 5.0 && uv.y < 10.0) {
            float dx =  mod(uv.y, floor(uv.y));

            color = 1.0 - step(dx,0.97);
        }
    }
    



    vec4 pic = texture2D(inputImageTexture, textureCoordinate);

    vec4 kou = texture2D(inputImageTexture2, textureCoordinate);

    vec2 ScaleTextureCoords2 = vec2(0.5, 0.5) + (textureCoordinate - vec2(0.5, 0.5)) / 1.2;
    vec4 mask2 = texture2D(inputImageTexture2, ScaleTextureCoords2);

    if (mask2.x > 0.0) {
        gl_FragColor = pic + color;
    }else{
        gl_FragColor = pic ;

    }



}


//float distanceToNearestSurface(vec3 p){
//    float s = 1.0;
//    vec3 q = abs(p) - vec3(s);
//    float dist = max(max(q.x, q.y), q.z);
//    if(q.x > 0.0 && q.y > 0.0 && q.z > 0.0){
//        dist = length(q);
//    }
//    return dist;
//}
//
//vec3 intersectsWithWorld(vec3 p, vec3 dir){
//      float dist = 0.0;
//    float nearest = 0.0;
//    bool hit = false;
//    for(int i = 0; i < 20; i++){
//        float nearest = distanceToNearestSurface(p + dir*dist);
//        if(nearest < 0.02){
//            return vec3(1.0,1.0,1.0);
//        }
//        dist += nearest;
//    }
//    return vec3(0.0);
//}
//
//void main (void) {
//    vec2 uv = textureCoordinate;
//
//    float itime = time / 5.0;
//
//    float cameraDistance = 10.0;
//    vec3 cameraPosition = vec3(cameraDistance * sin(itime), 0.2 * cameraDistance * cos(itime * 5.0), cameraDistance * cos(itime));
//
////    vec3 cameraPosition = vec3(10.0*sin(itime), 0.0, 10.0*cos(itime));
//
//    vec3 cameraDirection = vec3(-1.0*sin(itime), 0.0, -1.0 * cos(itime));
//    vec3 cameraUp = vec3(0.0, 50.0, 0.0);
//
//
//
//    float fovy = fovx * resolution.y/resolution.x;
//    float ulen = tan(fovx);
//    float vlen = tan(fovy);
//    vec2 camUV = uv*2.0 - vec2(1.0, 1.0);
//    vec3 nright = normalize(cross(cameraUp, cameraDirection));
//    vec3 pixel = cameraPosition + cameraDirection + nright*camUV.x*ulen + cameraUp*camUV.y*vlen;
//    vec3 rayDirection = normalize(pixel - cameraPosition);
//
//    vec3 pixelColor = intersectsWithWorld(cameraPosition, rayDirection);
//
//
//    vec4 pic = texture2D(inputImageTexture, textureCoordinate);
//
//    gl_FragColor = vec4(pixelColor, 1.0) + pic;
//}
