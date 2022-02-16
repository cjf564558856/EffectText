

precision highp float;
uniform sampler2D inputImageTexture;
uniform sampler2D inputImageTexture2;
uniform vec2 resolution;
varying vec2 textureCoordinate;
uniform float time;


#define PI (3.14159265358979)

vec3 hue(float x) {
    x = mod(x, 6.);
    return clamp(vec3(
        abs(x - 3.) - 1.,
        -abs(x - 2.) + 2.,
        -abs(x - 4.) + 2.
    ), 0., 1.);
}

vec3 deepfry(vec3 rgb, float x) {
    rgb *= x;
    return rgb + vec3(
      max(0., rgb.g - 1.) + max(0., rgb.b - 1.),
      max(0., rgb.b - 1.) + max(0., rgb.r - 1.),
      max(0., rgb.r - 1.) + max(0., rgb.g - 1.)
    );
}

void main (void) {
    float t = mod(time, 6.);
    float scale = length(resolution.xy);
    vec2 uv = (gl_FragCoord.xy / scale
    - (resolution.xy / scale / 2.)) * 2.;
    
    float r = (log(uv.x*uv.x+uv.y*uv.y) + length(uv) * -1.6) * (1.0 + 0.4 * sin(t * PI / 3.));
    float theta = atan(uv.y, uv.x);
    
    

    vec3 col = deepfry(
        hue(r * -3. + theta * 6. / PI + t * 3.),
        1. + 0.5 * sin(r * 1.8 + theta * 1.0 + t * -2. * PI)
    );
    vec4 pic = texture2D(inputImageTexture, textureCoordinate);

    gl_FragColor = vec4(col,1.0) + pic;
}
