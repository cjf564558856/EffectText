
precision highp float;
varying vec2 textureCoordinate;

uniform sampler2D inputImageTexture;

const vec2 direction = vec2(0.2);
const vec2 scale = vec2(0.5);
uniform float time;

void main()
{
    
    
    vec2 uv3 = textureCoordinate;
    uv3 -= 0.5;
    uv3 = uv3*scale ;
    uv3 += 0.5;
    
    gl_FragColor = texture2D(inputImageTexture,uv3+direction);
}
