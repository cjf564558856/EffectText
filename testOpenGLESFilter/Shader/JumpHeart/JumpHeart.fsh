


precision highp float;
uniform sampler2D inputImageTexture;
uniform sampler2D inputImageTexture2;
uniform vec2 resolution;
varying vec2 textureCoordinate;
const float PI = 3.141592653;

uniform float time;

void main (void) {

 
    vec2 fragCoord = gl_FragCoord.xy;
    vec2 p = (2.0*fragCoord-resolution.xy)/min(resolution.y,resolution.x);

    // background color
    vec3 bcol = vec3(1.0,0.8,0.8)*(1.0-0.38*length(p));

    // animate
    float tt = mod(time,1.5)/1.5;
       float ss = pow(tt,.2)*0.5 + 0.5;
       ss = 1.0 + ss*0.5*sin(tt*6.2831*3.0 + p.y*0.5)*exp(-tt*4.0);
       p *= vec2(0.5,1.5) + ss*vec2(0.5,-0.5);

    // shape
    p.y -= 0.25;
    float a = atan(p.x,p.y) / PI;
    float r = length(p);
    float h = abs(a);
    float d = (13.0*h - 22.0*h*h + 10.0*h*h*h)/(6.0-5.0*h);

    // color
    float s = 0.75 + 0.75*p.x;
    s *= 1.0-0.4*r;
    s = 0.3 + 0.7*s;
    s *= 0.5+0.5*pow( 1.0-clamp(r/d, 0.0, 1.0 ), 0.1 );
    vec3 hcol = vec3(1.0,0.5*r,0.3)*s;

    vec3 col = mix( bcol, hcol, smoothstep( -0.06, 0.06, d-r) );
        vec4 pic = texture2D(inputImageTexture, textureCoordinate);
    
    


    gl_FragColor = vec4(col,1.0) ;
    

}



//调整坐标系，将原点从左下角移至屏幕坐标系中央，这样所有片元的向量 gl_FragCoord.xy 均以屏幕中心为起点，则向量 p 就是屏幕中心与屏幕像素点坐标之间的方向向量。
