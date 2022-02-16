precision highp float;

uniform sampler2D inputImageTexture;
uniform sampler2D inputImageTexture2;

varying vec2 textureCoordinate;

uniform float time;

uniform vec2 resolution;

const float ratio = 1.0;
const float houdu = 5.0;
const float toumingdu = 10.0;

const float b1 = 1.0;
const float b2 = 1.0;
const float b3 = 1.0;
const float b4 = 5.0;

void main()
{
    vec4 inColor = texture2D(inputImageTexture,textureCoordinate);

    if(inColor.a>0.02){
      vec2 uv1 = textureCoordinate;
      float num1=1.0-uv1.x;
      float num2=uv1.x;
      float num3=1.0-uv1.y;
      float num4=uv1.y;

        float scale = mod(time, 5.0);

      float num = min(min(min(b1*num1*ratio,b2*num2*ratio),b3*num3),b4*num4);
        
      gl_FragColor = inColor+smoothstep(houdu*0.01,-toumingdu*0.01,num);
    }
    else
      gl_FragColor = inColor;
}
