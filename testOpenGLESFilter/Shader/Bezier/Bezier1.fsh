precision highp float;

uniform sampler2D inputImageTexture;
varying vec2 textureCoordinate;
uniform vec2 resolution;


vec3 cubicBezier(in vec3 p0, in vec3 p1, in vec3 p2, in vec3 p3, in float t){
    vec3 q0 = mix(p0, p1, t);
    vec3 q1 = mix(p1, p2, t);
    vec3 q2 = mix(p2, p3, t);
    vec3 r0 = mix(q0, q1, t);
    vec3 r1 = mix(q1, q2, t);
    return mix(r0, r1, t);
}


void main (void) {
    vec2 uv = textureCoordinate * resolution;

    vec3 start    = vec3(0.3, 0.3, 0.5);
    vec3 end      = vec3(0.0, 0.0, 0.5);
    vec3 control1 = vec3(0.0, 0.0, 0.5);
    vec3 control2 = vec3(0.5, 0.5, 0.5);
    float time    = fract(0.5 * 0.5);

    vec3 posOffset = cubicBezier(start, control1, control2, end, time);
    

    float h = (uv.y - posOffset.y) / posOffset.y;
    float w = (uv.x - posOffset.x) / posOffset.x;
    if( h < 0.0 || h > 1.0 || w < 0.0 || w > 1.0) {
        gl_FragColor = vec4(vec3(0.0),1.0);
        return;
    }
    gl_FragColor = texture2D(inputImageTexture, vec2(w, h));
}

