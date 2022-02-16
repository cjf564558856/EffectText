
precision highp float;
uniform sampler2D inputImageTexture;
uniform sampler2D inputImageTexture2;
uniform vec2 resolution;
varying vec2 textureCoordinate;
uniform float time;


#define NUM_EXPLOSIONS 7.
#define NUM_PARTICLES 20.
#define inv_nparticels (1./NUM_PARTICLES)
#define PI 3.1415926

float Hash11(float t){
    return fract(sin(t*613.2)*614.8);
}
vec2 Hash12(float t){
  return vec2(fract(sin(t*213.3)*314.8)-0.5,fract(sin(t*591.1)*647.2)-0.5);
}

vec2 Hash12_Polar(float t){
    float o = fract(sin(t*213.3)*314.8)*PI*2.0;
    float r = fract(sin(t*591.1)*647.2);
    return vec2(sin(o)*r,cos(o)*r);
}

float Explosion(vec2 uv, float t)
{
    float fract_t=fract(t);
    float floor_t=floor(t);
    float power=0.3+Hash11(floor_t);
    float sparks=0.;
    for(float i=0.;i<NUM_PARTICLES;i++)
    {
        vec2 dir=Hash12_Polar(i*floor_t)*1.;
        float inv_d=1./(length(uv-dir*sqrt(fract_t)));
        float brightness=mix(0.3,0.09,smoothstep(0.,0.1,fract_t))*(1.0-(0.5+0.5*Hash11(i))*fract_t);
        float sparkling= .5+.5*sin(t*10.2+floor_t*i);
        sparks+=power*brightness*sparkling*inv_nparticels*inv_d;
    }
    return sparks;
}

void main (void) {
    vec2 uv = (gl_FragCoord.xy-.5*resolution.xy)/resolution.y;

    vec3 col=vec3(0);

    for(float i=0.;i<NUM_EXPLOSIONS;i++){
        float t=time*(0.3+0.4*Hash11(i))+i/NUM_EXPLOSIONS;
        float fract_t=fract(t);
        float floor_t=floor(t);
    
        vec3 color=0.7+0.3*sin(vec3(.34,.54,.43)*floor_t*i);
        vec2 center = Hash12(i+10.+5.*floor_t);
        col+=Explosion(uv-center,t)*color;
    }
    col-=0.1;
    vec4 pic = texture2D(inputImageTexture, textureCoordinate);

    gl_FragColor = vec4(mix(col,pic.xyz,0.5) ,1.0);
} 
