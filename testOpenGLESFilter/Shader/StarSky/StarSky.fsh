precision highp float;
uniform sampler2D inputImageTexture;
uniform sampler2D inputImageTexture2;
uniform vec2 resolution;
varying vec2 textureCoordinate;


#define iterations 17
#define formuparam 0.53

#define volsteps 20
#define stepsize 0.1

#define zoom   0.800
#define tile   0.850
#define speed  0.010

#define brightness 0.0015
#define darkmatter 0.300
#define distfading 0.730
#define saturation 0.850
#define PI 3.14159

uniform float time;


//// ray computation vars
//const float PI = 3.14159265359;
//const float fov = 50.0;
//
//// epsilon-type values
//const float S = 0.01;
//const float EPSILON = 0.01;
//
//// const delta vectors for normal calculation
//const vec3 deltax = vec3(S ,0, 0);
//const vec3 deltay = vec3(0 ,S, 0);
//const vec3 deltaz = vec3(0 ,0, S);
//
//float distanceToNearestSurface(vec3 p){
//    float s = 1.0;
//    vec3 d = abs(p) - vec3(s);
//    return min(max(d.x, max(d.y,d.z)), 0.0)
//        + length(max(d,0.0));
//}
//
//
//// better normal implementation with half the sample points
//// used in the blog post method
//vec3 computeSurfaceNormal(vec3 p){
//    float d = distanceToNearestSurface(p);
//    return normalize(vec3(
//        distanceToNearestSurface(p+deltax)-d,
//        distanceToNearestSurface(p+deltay)-d,
//        distanceToNearestSurface(p+deltaz)-d
//    ));
//}
//
//
//vec3 computeLambert(vec3 p, vec3 n, vec3 l){
//    return vec3(dot(normalize(l-p), n));
//}
//
//vec3 intersectWithWorld(vec3 p, vec3 dir){
//    float dist = 0.0;
//    float nearest = 0.0;
//    vec3 result = vec3(0.0);
//    for(int i = 0; i < 20; i++){
//        nearest = distanceToNearestSurface(p + dir*dist);
//        if(nearest < EPSILON){
//            vec3 hit = p+dir*dist;
//            vec3 light = vec3(100.0*sin(time), 30.0*cos(time), 50.0*cos(time));
//            result = computeLambert(hit, computeSurfaceNormal(hit), light);
//            break;
//        }
//        dist += nearest;
//    }
//    return result;
//}
//
//void main (void) {
//
//    vec2 uv = textureCoordinate;
//
//    float cameraDistance = 10.0;
//    vec3 cameraPosition = vec3(10.0*sin(time), 0.0, 10.0*cos(time));
//    vec3 cameraDirection = vec3(-1.0*sin(time), 0.0, -1.0*cos(time));
//    vec3 cameraUp = vec3(0.0, 1.0, 0.0);
//
//    // generate the ray for this pixel
//    const float fovx = PI * fov / 360.0;
//    float fovy = fovx * resolution.y/resolution.x;
//    float ulen = tan(fovx);
//    float vlen = tan(fovy);
//
//    vec2 camUV = uv*2.0 - vec2(1.0, 1.0);
//    vec3 nright = normalize(cross(cameraUp, cameraDirection));
//    vec3 pixel = cameraPosition + cameraDirection + nright*camUV.x*ulen + cameraUp*camUV.y*vlen;
//    vec3 rayDirection = normalize(pixel - cameraPosition);
//
//    vec3 pixelColour = intersectWithWorld(cameraPosition, rayDirection);
//    gl_FragColor = vec4(pixelColour, 1.0);
//}


//void main (void) {
//    vec2 uv = textureCoordinate.xy;
//
//    float t = 10.0 - mod(time * 6.0,10.0);
//
//    float count = 5.0;
//
//    uv *= 10.0;
//    float color = 0.0;
//    if (uv.y > t && uv.y > 0.99 && uv.y < t + 5.0 ) {
//        float dx =  mod(uv.y, floor(uv.y));
//
//        color = 1.0 - step(dx,0.97);
//    }
//
//
//    vec4 pic = texture2D(inputImageTexture, textureCoordinate);
//
//    vec4 kou = texture2D(inputImageTexture2, textureCoordinate);
//
//    vec2 ScaleTextureCoords2 = vec2(0.5, 0.5) + (textureCoordinate - vec2(0.5, 0.5)) / 1.5;
//    vec4 mask2 = texture2D(inputImageTexture2, ScaleTextureCoords2);
//
//    if (mask2.x > 0.0) {
//        gl_FragColor = pic + color;
//    }else{
//        gl_FragColor = pic ;
//
//    }
//
//
//
//}





//星空

//void main (void) {
//    vec2 uv=vec2(textureCoordinate - 0.5);
//    uv.y*=textureCoordinate.y;
//    vec3 dir=vec3(uv*zoom,1.);
//    float time1=time*speed+.25;
//
//    float a1=.5+0.0/resolution.x*2.;
//    float a2=.8+0.0/resolution.y*2.;
//    mat2 rot1=mat2(cos(a1),sin(a1),-sin(a1),cos(a1));
//    mat2 rot2=mat2(cos(a2),sin(a2),-sin(a2),cos(a2));
//    dir.xz*=rot1;
//    dir.xy*=rot2;
//    vec3 from=vec3(1.,.5,0.5);
//    from+=vec3(time1*2.,time1,-2.);
//    from.xz*=rot1;
//    from.xy*=rot2;
//
//    float s=0.1,fade=1.;
//    vec3 v=vec3(0.);
//    for (int r=0; r<volsteps; r++) {
//        vec3 p=from+s*dir*.5;
//        p = abs(vec3(tile)-mod(p,vec3(tile*2.)));
//        float pa,a=pa=0.;
//        for (int i=0; i<iterations; i++) {
//            p=abs(p)/dot(p,p)-formuparam;
//            a+=abs(length(p)-pa);
//            pa=length(p);
//        }
//        float dm=max(0.,darkmatter-a*a*.001);
//        a*=a*a;
//        if (r>6) fade*=1.-dm;
//        v+=fade;
//        v+=vec3(s,s*s,s*s*s*s)*a*brightness*fade;
//        fade*=distfading;
//        s+=stepsize;
//    }
//    v=mix(vec3(length(v)),v,saturation);
//
//        vec4 pic = texture2D(inputImageTexture, textureCoordinate);
//
//
//    gl_FragColor = vec4(v*.01,1.) + pic;
//
//}

//
//float random (vec2 st) {
//    return fract(sin(dot(st.xy, vec2(565656.233,123123.2033))) * 323434.34344);
//}
//
//vec2 random2( vec2 p ) {
//    return fract(sin(vec2(dot(p,vec2(234234.1,54544.7)), sin(dot(p,vec2(33332.5,18563.3))))) *323434.34344);
//}
//
//
//void main (void) {
//
//    vec2 uv = textureCoordinate;
//    uv *= 100.0;
//    vec2 ipos = floor(uv);
//    vec2 fpos = fract(uv);
//
//    vec2 targetPoint = random2(ipos);
//    float speed = 0.1;
//    targetPoint = 0.5 + 0.4*sin(time1*speed + 6.2831*targetPoint);
//
//    vec4 pic = texture2D(inputImageTexture, textureCoordinate);
//
//    float dist = length(fpos - targetPoint);
//
//    float brightness = sin(time1*speed + 6.2831*targetPoint.x);
//
//    vec3 color = vec3(1. - step(0.013, dist))* brightness;
//
//    gl_FragColor = vec4(color,1.0);
//}
