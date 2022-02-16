precision highp float;
varying vec2 textureCoordinate;

const float pointX = 0.5;

const float currentRatio = 1.0;

const float ratio = 1.5;

const float aspect = 1.5;

uniform sampler2D inputImageTexture;
uniform sampler2D inputImageTexture2;

uniform float time;

#define PI 3.14159265


void main()
{
    float angle = min(60.0 * time,10.0);
    
    float theta = -angle * PI / 180.0;
    mat2 left_rotation = mat2(cos(theta), -sin(theta), sin(theta), cos(theta));
     vec2 uv1 = vec2(textureCoordinate.x, textureCoordinate.y * ratio);
     uv1 = left_rotation * vec2(uv1.x - pointX, uv1.y);
     uv1.x += pointX;
     uv1 = vec2(uv1.x, uv1.y / ratio);

     float right_theta = angle * PI / 180.;
     mat2 right_rotation = mat2(cos(right_theta), -sin(right_theta), sin(right_theta), cos(right_theta));
     vec2 uv2 = vec2(textureCoordinate.x, textureCoordinate.y * ratio);
     uv2 = right_rotation * vec2(uv2.x - pointX, uv2.y);
     uv2.x += pointX;
     uv2 = vec2(uv2.x, uv2.y / ratio);
    

    
    float leftUV;
    float rightUV;
    vec4 leftMask;
    vec4 rightMask;

    if (currentRatio < 1.0){
        leftUV = (uv1.y - 0.5) / aspect;
        leftUV += 0.5;
        rightUV = (uv2.y - 0.5) / aspect;
        rightUV += 0.5;
        leftMask = texture2D(inputImageTexture2, vec2(uv1.x,leftUV));
        rightMask = texture2D(inputImageTexture2, vec2(uv2.x,rightUV));

    }else if (currentRatio == 1.0){
        leftUV = (uv1.y - 0.5) / aspect;
        leftUV += 0.5;
        rightUV = (uv2.y - 0.5) / aspect;
        rightUV += 0.5;
        leftMask = texture2D(inputImageTexture2, vec2(uv1.x,leftUV));
        rightMask = texture2D(inputImageTexture2, vec2(uv2.x,rightUV));

    }else if (currentRatio > 1.0){
        leftUV = (uv1.x - 0.5) / aspect;
        leftUV += 0.5;
        rightUV = (uv2.x - 0.5) / aspect;
        rightUV += 0.5;
        leftMask = texture2D(inputImageTexture2, vec2(leftUV,uv1.y));
        rightMask = texture2D(inputImageTexture2, vec2(rightUV,uv2.y));
    }
    gl_FragColor = texture2D(inputImageTexture, vec2(uv1.x,uv1.y)) * leftMask.r + texture2D(inputImageTexture, vec2(uv2.x,uv2.y)) * (1.- rightMask.r);
    return;
    vec4 leftColor = texture2D(inputImageTexture, vec2(uv1.x/1.1+0.05,uv1.y/1.1)) * leftMask.r;
    vec4 rightColor = texture2D(inputImageTexture, vec2(uv2.x/1.1+0.05,uv2.y/1.1)) * (1.- rightMask.r);
    gl_FragColor = leftColor + rightColor;
    
}
