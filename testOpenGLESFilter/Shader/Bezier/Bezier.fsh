precision highp float;

uniform sampler2D inputImageTexture;
varying vec2 textureCoordinate;
uniform vec2 resolution;

uniform vec2 topLeftVex;
uniform vec2 topLeftTangentVex;
uniform vec2 topRightVex;
uniform vec2 topRightTangentVex;

uniform vec2 bottomLeftVex;
uniform vec2 bottomLeftTangentVex;
uniform vec2 bottomRightVex;
uniform vec2 bottomRightTangentVex;

uniform vec2 leftTopTangentVex;
uniform vec2 leftBottomTangentVex;
uniform vec2 rightTopTangentVex;
uniform vec2 rightBottomTangentVex;

vec2 cubicBezier(in vec2 p0, in vec2 p1, in vec2 p2, in vec2 p3, in float t){
    vec2 q0 = mix(p0, p1, t);
    vec2 q1 = mix(p1, p2, t);
    vec2 q2 = mix(p2, p3, t);
    vec2 r0 = mix(q0, q1, t);
    vec2 r1 = mix(q1, q2, t);
    return mix(r0, r1, t);
}

void main (void) {
    vec2 uv = textureCoordinate * resolution;
    vec2 p0 = vec2(topLeftVex.x, resolution.y - topLeftVex.y);
    vec2 p1 = vec2(topLeftTangentVex.x, resolution.y - topLeftTangentVex.y);
    vec2 p2 = vec2(topRightTangentVex.x, resolution.y - topRightTangentVex.y);
    vec2 p3 = vec2(topRightVex.x, resolution.y - topRightVex.y);
    vec2 b = cubicBezier(p0, p1, p2, p3, textureCoordinate.x);
    vec2 p4 = vec2(bottomLeftVex.x, resolution.y - bottomLeftVex.y);
    vec2 p5 = vec2(bottomLeftTangentVex.x, resolution.y - bottomLeftTangentVex.y);
    vec2 p6 = vec2(bottomRightTangentVex.x, resolution.y - bottomRightTangentVex.y);
    vec2 p7 = vec2(bottomRightVex.x, resolution.y - bottomRightVex.y);
    vec2 b2 = cubicBezier(p4, p5, p6, p7, textureCoordinate.x);
    
    vec2 t0 = vec2(bottomLeftVex.x, resolution.y - bottomLeftVex.y);
    vec2 t1 = vec2(leftBottomTangentVex.x, resolution.y - leftBottomTangentVex.y);
    vec2 t2 = vec2(leftTopTangentVex.x, resolution.y - leftTopTangentVex.y);
    vec2 t3 = vec2(topLeftVex.x, resolution.y - topLeftVex.y);
    vec2 s = cubicBezier(t0, t1, t2, t3, textureCoordinate.y);
    vec2 t4 = vec2(bottomRightVex.x, resolution.y - bottomRightVex.y);
    vec2 t5 = vec2(rightBottomTangentVex.x, resolution.y - rightBottomTangentVex.y);
    vec2 t6 = vec2(rightTopTangentVex.x, resolution.y - rightTopTangentVex.y);
    vec2 t7 = vec2(topRightVex.x, resolution.y - topRightVex.y);
    vec2 s2 = cubicBezier(t4, t5, t6, t7, textureCoordinate.y);
    float dist_h = abs(s2.x - s.x);
    float dist_v = abs(b2.y - b.y);
    float h = (uv.y -b2.y) / dist_v;
    float w = (uv.x -s.x) / dist_h;
    if( h < 0.0 || h > 1.0 || w < 0.0 || w > 1.0) {
        gl_FragColor = vec4(vec3(0.0),1.0);
        return;
    }
    gl_FragColor = texture2D(inputImageTexture, vec2(w, h));
}


