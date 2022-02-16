precision highp float;
varying vec2 textureCoordinate;

uniform vec2 resolution;

const float Speed = 0.5;
uniform float time;

uniform sampler2D inputImageTexture;

void main()
{
    vec2 o = vec2(resolution.x/2.0, resolution.y*0.9);
    vec2 d = vec2(0.0, -1.0);
    vec2 uv = textureCoordinate;
    vec3 col = vec3(0.0);
    for (int i=0; i<100; i++) {
        vec4 tex = texture2D(inputImageTexture, vec2(float(i)/256.0, time), -100.0);
        vec2 tgt = vec2(resolution.x/2.0, resolution.y*0.1)-o;
        vec2 seek = normalize(tgt)*(16.0/(length(tgt)+1.0));
        d = normalize(seek+vec2(1.5, -1.0)*(vec2(-0.5, 0.0)+tex.gb));
        float len = min(length(tgt), 9.0 * (tex.r+0.1));
        float dist = abs(dot(o-uv, d.yx*vec2(1.0,-1.0)));
        o += d*len;
        if (dist < 1.5 && length(o-uv) < len*0.75) {
            col = vec3(1.0);
            break;
        }
    }
    gl_FragColor = vec4(col, 0.0);
}


///* discontinuous pseudorandom uniformly distributed in [-0.5, +0.5]^3 */
//vec3 random3(vec3 c) {
//    float j = 4096.0*sin(dot(c,vec3(17.0, 59.4, 15.0)));
//    vec3 r;
//    r.z = fract(512.0*j);
//    j *= .125;
//    r.x = fract(512.0*j);
//    j *= .125;
//    r.y = fract(512.0*j);
//    return r-0.5;
//}
//
//
//const float F3 =  0.3333333;
//const float G3 =  0.1666667;
//
///* 3d simplex noise */
//float simplex3d(vec3 p) {
//     /* 1. find current tetrahedron T and it's four vertices */
//     /* s, s+i1, s+i2, s+1.0 - absolute skewed (integer) coordinates of T vertices */
//     /* x, x1, x2, x3 - unskewed coordinates of p relative to each of T vertices*/
//
//     /* calculate s and x */
//     vec3 s = floor(p + dot(p, vec3(F3)));
//     vec3 x = p - s + dot(s, vec3(G3));
//
//     /* calculate i1 and i2 */
//     vec3 e = step(vec3(0.0), x - x.yzx);
//     vec3 i1 = e*(1.0 - e.zxy);
//     vec3 i2 = 1.0 - e.zxy*(1.0 - e);
//
//     /* x1, x2, x3 */
//     vec3 x1 = x - i1 + G3;
//     vec3 x2 = x - i2 + 2.0*G3;
//     vec3 x3 = x - 1.0 + 3.0*G3;
//
//     /* 2. find four surflets and store them in d */
//     vec4 w, d;
//
//     /* calculate surflet weights */
//     w.x = dot(x, x);
//     w.y = dot(x1, x1);
//     w.z = dot(x2, x2);
//     w.w = dot(x3, x3);
//
//     /* w fades from 0.6 at the center of the surflet to 0.0 at the margin */
//     w = max(0.6 - w, 0.0);
//
//     /* calculate surflet components */
//     d.x = dot(random3(s), x);
//     d.y = dot(random3(s + i1), x1);
//     d.z = dot(random3(s + i2), x2);
//     d.w = dot(random3(s + 1.0), x3);
//
//     /* multiply d by w^4 */
//     w *= w;
//     w *= w;
//     d *= w;
//
//     /* 3. return the sum of the four surflets */
//     return dot(d, vec4(52.0));
//}
//
//
//float noise(vec3 m) {
//    return   0.5333333*simplex3d(m)
//            +0.2666667*simplex3d(2.0*m)
//            +0.1333333*simplex3d(4.0*m)
//            +0.0666667*simplex3d(8.0*m);
//}
//
//void main(){
//  vec2 uv = textureCoordinate;
//  uv = uv * 2. -1.;
//
//  vec2 p = textureCoordinate;
//  vec3 p3 = vec3(p, time*0.4);
//
//  float intensity = noise(vec3(p3*12.0+12.0));
//
//  float t = clamp((uv.x * -uv.x * 0.16) + 0.15, 0., 1.);
//  float y = abs(intensity * -t + uv.y);
//
//  float g = pow(y, 0.2);
//
//  vec3 col = vec3(1.70, 1.48, 1.78);
//  col = col * -g + col;
//  col = col * col;
//  col = col * col;
//
//    gl_FragColor = vec4(col,1.0) + texture2D(inputImageTexture,textureCoordinate);
//}

//
//void main()
//{
//    vec2 uv = textureCoordinate;
//    float aspect = resolution.x / resolution.y;
//    float tx = time * Speed;
//    float xt = uv.x - tx ;
//    float Yoffset ;
//    if (aspect > 1.0) {
//        Yoffset = sin(0.02 * 4.)*0.35;
//
//    }else{
//        Yoffset = sin(0.02)*0.35;
//    }
//
//    float row = floor(xt/0.001);
//    uv.y += sin(row/25.0)* Yoffset;
//    // uv.x += sin(row/25.0)* Yoffset * 1.7;
//    vec4 resultColor = texture2D(inputImageTexture, uv);
//    gl_FragColor = resultColor;
//}

