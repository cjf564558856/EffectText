
precision highp float;

uniform sampler2D inputImageTexture;
uniform sampler2D maomaofilter;
uniform sampler2D biankuang;
varying vec2 textureCoordinate;

uniform int inputWidth;
uniform int inputHeight;

const float k = 0.15;

vec4 takeEffectFilter(sampler2D baseTex,sampler2D filterTex,float k)
{
  highp vec4 inputColor=texture2D(baseTex,textureCoordinate);
  highp float blueColor=inputColor.b*63.;
  
  highp vec2 quad1;
  quad1.y=floor(floor(blueColor)/8.);
  quad1.x=floor(blueColor)-(quad1.y*8.);
  
  highp vec2 quad2;
  quad2.y=floor(ceil(blueColor)/8.);
  quad2.x=ceil(blueColor)-(quad2.y*8.);
  
  highp vec2 texPos1;
  texPos1.x=(quad1.x*1./8.)+.5/512.+((1./8.-1./512.)*inputColor.r);
  texPos1.y=(quad1.y*1./8.)+.5/512.+((1./8.-1./512.)*inputColor.g);
  
  highp vec2 texPos2;
  texPos2.x=(quad2.x*1./8.)+.5/512.+((1./8.-1./512.)*inputColor.r);
  texPos2.y=(quad2.y*1./8.)+.5/512.+((1./8.-1./512.)*inputColor.g);
  
  lowp vec4 newColor1=texture2D(filterTex,texPos1);
  lowp vec4 newColor2=texture2D(filterTex,texPos2);
  lowp vec4 newColor=mix(newColor1,newColor2,fract(blueColor));
  newColor = mix(inputColor,vec4(newColor.rgb,inputColor.w),k);

  //lv znkx
  if(inputColor.a>0.05)
    return newColor;
  else
    return vec4(0.0);
}

void main()
{
    gl_FragColor = takeEffectFilter(inputImageTexture,maomaofilter,k);

    vec4 biankuangCol = texture2D(biankuang, textureCoordinate);
    if(gl_FragColor.a>0.05)
      gl_FragColor = mix(gl_FragColor,biankuangCol,biankuangCol.a);
}





//precision highp float;
//varying vec2 textureCoordinate;
//
//uniform sampler2D inputImageTexture;
//
//uniform vec2 resolution;
//
//const int blurRadius = 3;
//const vec2 blurStep = vec2(0.5,0.5);
//const float u_intensity = 5.0;
//
//
//float gaussianWeight(float dist, float stdDev)
//{
//    return exp(-dist / (2.0 * stdDev));
//}
//
//vec4 gaussianBlur(sampler2D inputTexture, vec2 textureCoordinate, int radius, vec2 stepUV, vec2 screenSize)
//{
//    float half_gaussian_weight[9];
//
//    half_gaussian_weight[0]= 0.20;//0.137401;
//    half_gaussian_weight[1]= 0.19;//0.125794;
//    half_gaussian_weight[2]= 0.17;//0.106483;
//    half_gaussian_weight[3]= 0.15;//0.080657;
//    half_gaussian_weight[4]= 0.13;//0.054670;
//    half_gaussian_weight[5]= 0.11;//0.033159;
//    half_gaussian_weight[6]= 0.08;//0.017997;
//    half_gaussian_weight[7]= 0.05;//0.008741;
//    half_gaussian_weight[8]= 0.02;//0.003799;
//    // vec4 sumColor       = vec4(0.0);
//    // vec4 resultColor    = vec4(0.0);
//    vec2 unitUV         = stepUV/screenSize;//vec2(blurSize/screenSize.x,blurSize/screenSize.y)*1.25;
//    float stdDev        = 112.0;
//    float sumWeight     = half_gaussian_weight[0];
//    vec4 curColor       = texture2D(inputTexture, textureCoordinate);
//    vec4 centerPixel    = curColor*half_gaussian_weight[0];
//    vec4 sumColor       = curColor*sumWeight;
//    //horizontal
//    for(int i=1;i<=blurRadius;i++)
//    {
//        vec2 textureCoordinateA = textureCoordinate+float(i)*unitUV;
//        vec2 textureCoordinateB = textureCoordinate+float(-i)*unitUV;
//        vec4 colorA = texture2D(inputTexture,textureCoordinateA);
//        vec4 colorB = texture2D(inputTexture,textureCoordinateB);
//        float curWeight = half_gaussian_weight[i];
//        sumColor += colorA*curWeight;
//        sumColor += colorB*curWeight;
//        sumWeight+= curWeight*2.0;
//    }
//
//    vec4 resultColor = sumColor/sumWeight;
//
//    return resultColor;
//}
//
//void main(void)
//{
//    vec2 screenSize = resolution;
//    vec4 curColor = texture2D(inputImageTexture,textureCoordinate);
//    vec4 resultColor = curColor;
//
//    resultColor = gaussianBlur(inputImageTexture,textureCoordinate,blurRadius,blurStep * u_intensity,screenSize);
//    gl_FragColor = resultColor;
//}
