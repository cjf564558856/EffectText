precision highp float;
varying vec2 textureCoordinate;
uniform sampler2D inputImageTexture;
uniform sampler2D inputImageTexture2;
uniform float uniAlpha;

vec4 takeEffectFilter()
{
  highp vec4 textureColor=texture2D(inputImageTexture,textureCoordinate);
  highp float blueColor=textureColor.b*63.;
  
  highp vec2 quad1;
  quad1.y=floor(floor(blueColor)/8.);
  quad1.x=floor(blueColor)-(quad1.y*8.);
  
  highp vec2 quad2;
  quad2.y=floor(ceil(blueColor)/8.);
  quad2.x=ceil(blueColor)-(quad2.y*8.);
  
  highp vec2 texPos1;
  texPos1.x=(quad1.x*1./8.)+.5/512.+((1./8.-1./512.)*textureColor.r);
  texPos1.y=(quad1.y*1./8.)+.5/512.+((1./8.-1./512.)*textureColor.g);
  
  highp vec2 texPos2;
  texPos2.x=(quad2.x*1./8.)+.5/512.+((1./8.-1./512.)*textureColor.r);
  texPos2.y=(quad2.y*1./8.)+.5/512.+((1./8.-1./512.)*textureColor.g);
  
  lowp vec4 newColor1=texture2D(inputImageTexture2,texPos1);
  lowp vec4 newColor2=texture2D(inputImageTexture2,texPos2);
  lowp vec4 newColor=mix(newColor1,newColor2,fract(blueColor));
  newColor = mix(textureColor,vec4(newColor.rgb,textureColor.w),1.0);

  return newColor;
}

void main(void)
{
  vec4 curColor=texture2D(inputImageTexture,textureCoordinate);
  vec4 resultColor=curColor;
  
  resultColor=takeEffectFilter();
  
  gl_FragColor=resultColor;
}

