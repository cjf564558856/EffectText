

precision highp float;
varying vec2 textureCoordinate;
uniform sampler2D inputImageTexture;
uniform sampler2D inputImageTexture2;
uniform vec2 resolution;

void main() {

//   //寻找周围点
    float  block=500.0;
    float  delta=1.0/block;
      vec4 maxColor=vec4(-1.0);
    for(int i=-1;i<=1;i++){
        for(int j=-1;j<=1;j++){
          float x=(textureCoordinate.x+float(i)*delta);
          float y=(textureCoordinate.y+float(i)*delta);
            //寻找最亮点，代替周围点
          maxColor=max(maxColor,texture2D(inputImageTexture2,vec2(x,y)));
            
            
            //寻找最暗点，代替周围点
          maxColor=min(texture2D(vTexture,vec2(x,y)),maxColor);
        }
    }

    gl_FragColor=maxColor;
}
