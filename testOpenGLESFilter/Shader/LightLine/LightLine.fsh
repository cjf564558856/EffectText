
precision highp float;
uniform sampler2D inputImageTexture;
uniform sampler2D inputImageTexture2;
uniform vec2 resolution;
varying vec2 textureCoordinate;

uniform float time;

#define PI 3.14159


float vDrop(vec2 uv,float t){
    uv.x = uv.x*128.0;
    float dx = fract(uv.x);
    uv.x = floor(uv.x);
    uv.y *= 0.05;
    float o=sin(uv.x*215.4);
    float s=cos(uv.x*33.1)*.3 +.7;
    float trail = mix(95.0,35.0,s);
    float yv = fract(uv.y + t*s + o) * trail;
    yv = 1.0/yv;
    yv = smoothstep(0.0,1.0,yv*yv);
    yv = sin(yv*PI)*(s*5.0);
    float d2 = sin(dx*PI);
    return yv*(d2*d2);
}

void main (void) {

    vec2 p = textureCoordinate.xy - 0.5;
    float d = length(p)+0.1;
    p = vec2(atan(p.x, p.y) / PI, 2.5 / d);
    float t =  time*0.4;
    vec3 col = vec3(1.55,0.65,.225) * vDrop(p,t);
    col += vec3(0.55,0.75,1.225) * vDrop(p,t+0.33);
    col += vec3(0.45,1.15,0.425) * vDrop(p,t+0.66);


    vec4 pic = texture2D(inputImageTexture, textureCoordinate);


    gl_FragColor = vec4(col*(d*d), 1.0) + pic;
}
