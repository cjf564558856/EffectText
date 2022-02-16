precision highp float;

attribute vec4 position;
attribute vec4 inputTextureCoordinate;
varying vec2 uv0;
varying vec2 uv1;

uniform float aspectRatio;
uniform vec2 size;
uniform vec2 center;
uniform float degrees;

#define PI 3.14159265358979323846

void main()
{
    gl_Position = position;
    float rotate = (360.0-(degrees-180.)) * 2.0 * PI / 360.0;
    vec2 setSize;
    if (aspectRatio>1.)
      setSize = vec2(size.x / aspectRatio, size.x) * 1.77;
    else
      setSize = vec2(size.x, size.x * aspectRatio) * 1.77;

    vec2 uv = vec2((inputTextureCoordinate.x - 0.5) * 2.0 * aspectRatio, -(inputTextureCoordinate.y - 0.5) * 2.0);
    uv = vec2(uv.x - center.x * aspectRatio, uv.y + center.y);
    uv = vec2(cos(rotate) * uv.x - sin(rotate) * uv.y, sin(rotate) * uv.x + cos(rotate) * uv.y);
    uv = vec2(uv.x / setSize.x, uv.y / setSize.y);
    uv0 = vec2(uv.x * 0.5 / aspectRatio + 0.5, uv.y * 0.5 + 0.5);
    uv1  = inputTextureCoordinate.xy;
}