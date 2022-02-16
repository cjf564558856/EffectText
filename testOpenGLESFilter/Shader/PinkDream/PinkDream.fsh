precision highp float;
varying vec2 textureCoordinate;
uniform sampler2D inputImageTexture;
uniform sampler2D inputImageTexture2;
uniform vec2 resolution;

uniform float time;

void main() {
    
    float progress = mod(time , 4.0);

    vec4 maxColor = vec4(0.0);
    
    int ksize = int(60.0);
    
    float resultI = 0.0;
    
    for (int i = -1 * ksize; i <= ksize ; i++) {

            float x = textureCoordinate.x < 0.6 ?  textureCoordinate.x + float(i) * 0.001 : textureCoordinate.x - float(i) * 0.001;

            float y = textureCoordinate.y - float(i) * 0.001;
            
            if (texture2D(inputImageTexture2, vec2(x, y)).r > maxColor.r) {
                maxColor = max(texture2D(inputImageTexture2, vec2(x, y)), maxColor);
                
                resultI =  float(i);
            
        }
    }

    vec4 color = texture2D(inputImageTexture, textureCoordinate);

    bvec3 com = greaterThan(maxColor.rgb, vec3(0.1));

    
    float radiao = 1.0 - resultI /60.0  ;
    
    float timeScale = 0.0;
    
    if (progress < 1.0 || progress > 3.0) {
        if (progress < 1.0) {
            timeScale = 1.0 - progress ;
        }else{
            timeScale = progress - 3.0 ;
        }
    }else{
        if (progress >= 1.0 && progress <= 2.0) {
            timeScale =  progress - 1.0 ;
        }else{
            timeScale = 3.0 - progress ;
        }
    }

    

    vec4 textcolor = texture2D(inputImageTexture2, textureCoordinate);

    
    if(any(com) && resultI > 0.0) {
        
        float result = 1.0  * timeScale * radiao;
        
        maxColor = progress < 1.0 || progress > 3.0 ? vec4(0.9 ,0.3  ,0.9,result  )  : vec4(0.6 ,0.3,0.8,result ) ;
  
        if (maxColor.a <= 0.5) {
            maxColor = vec4(0.0);
        }else{
            color = vec4(0.0);
        }
        
        gl_FragColor = clamp(maxColor + color   ,vec4(0.0),vec4(1.0));

    }else{
        gl_FragColor = color ;
    }
    

}
