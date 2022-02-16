precision highp float;

varying vec2 uv0;
varying vec2 uv1;

uniform sampler2D inputImageTexture;
uniform sampler2D inputImageTexture2;

uniform float featherStep;
uniform float invert;

void main()
{
    vec2 col = texture2D(inputImageTexture2, uv0).rg;
    float alpha = (col.r * 4.0 * 256.0 + col.g * 255.0) / 781.0;
    float setFeather = featherStep * 0.5;
    alpha = clamp(smoothstep(0.49 - setFeather, 0.51 + setFeather, alpha), 0.0, 1.0);
    if (invert > 0.0)
    {
        alpha = 1.0 - alpha;
    }
    vec4 rgbaInput = texture2D(inputImageTexture, uv1);
    gl_FragColor = vec4(rgbaInput.rgb, rgbaInput.a * alpha);
}
