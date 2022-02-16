#ifdef GL_FRAGMENT_PRECISION_HIGH
precision highp float;
#else
precision mediump float;
#endif
varying highp vec2 TextureCoordsVarying;

uniform sampler2D Texture;

uniform float enables[5];

uniform float Time; // 由time控制

#define PI 3.1415926

vec4 addSpotlight( vec2 spotCoord, float direction, float maxLight,  float minLight ,vec4 lightColor )
{
     vec4 color = texture2D(Texture,TextureCoordsVarying);
     vec4 result = vec4(0.0);
     
     vec2 tanvec = TextureCoordsVarying - spotCoord; // 聚光灯位置
     
     float tanv = tanvec.x/tanvec.y;
     
     float vangle = atan(tanv);
     
     vangle = abs(vangle + direction); // 聚光灯方向
     
     if(vangle < maxLight){ //聚光灯范围
         
         result =  color*lightColor; // 聚光灯颜色
         if(vangle > minLight){ // 聚光灯核心范围
             result =  mix(result,vec4(0.0),smoothstep(minLight,maxLight,vangle));
         }
     }
     
     return vec4(result.rgb,color.a);
 }

float rand(in float x, in float y)
{
    return fract(sin(dot(vec2(x, y), vec2(12.9898, 78.233))) * 43758.5453);
}

void main()
{
    #ifdef ANDROID
         float fLightY = 1.08;
         vec4 colorA = addSpotlight(vec2(0.00455,fLightY),  PI/4.5, 0.4, 0.1, vec4(1.0,0.0,0.0 ,1.0));
         vec4 colorB = addSpotlight(vec2(0.24772,fLightY),  PI/8.0, 0.4, 0.1, vec4(1.0,1.0,0.0 ,1.0));
         vec4 colorC = addSpotlight(vec2(0.5 ,fLightY), 0.0, 0.4, 0.1, vec4(0.0,1.0,0.0 ,1.0));
         vec4 colorD = addSpotlight(vec2(0.75228,fLightY), - PI/8.0, 0.4, 0.1, vec4(1.0,0.0,1.0 ,1.0));
         vec4 colorE = addSpotlight(vec2(0.99545 ,fLightY), - PI/4.5, 0.4, 0.1, vec4(0.0,0.0,1.0 ,1.0));
         
#else
         vec4 colorA = addSpotlight(vec2(-0.2,-0.1), - PI/4.0, 0.4, 0.1, vec4(1.0,0.0,0.0 ,1.0));
         vec4 colorB = addSpotlight(vec2(0.15,-0.1), - PI/8.0, 0.4, 0.1, vec4(1.0,1.0,0.0 ,1.0));
         vec4 colorC = addSpotlight(vec2(0.5 ,-0.1),   0.0,    0.4, 0.1, vec4(0.0,1.0,0.0 ,1.0));
         vec4 colorD = addSpotlight(vec2(0.85,-0.1),   PI/8.0, 0.4, 0.1, vec4(1.0,0.0,1.0 ,1.0));
         vec4 colorE = addSpotlight(vec2(1.2 ,-0.1),   PI/4.0, 0.4, 0.1, vec4(0.0,0.0,1.0 ,1.0));
#endif
         gl_FragColor = vec4(vec4(colorA*enables[0] + colorB*enables[1] + colorC*enables[2] + colorD*enables[3] + colorE*enables[4]).rgb,colorA.a);
}
