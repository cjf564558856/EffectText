

precision mediump float;
varying vec2 textureCoordinate;
uniform sampler2D inputImageTexture;
uniform vec2 resolution;

void main()
{
    vec4 color=vec4(0.0);
    int coreSize=3;
    float texelOffset=1.0/resolution.x;
    float kernel[9];
    kernel[6]=0.0;kernel[7]=1.0;kernel[8]=0.0;
    kernel[3]=1.0;kernel[4]=-4.0;kernel[5]=1.0;
    kernel[0]=0.0;kernel[1]=1.0;kernel[2]=0.0;
    int index=0;
    for(int y=0;y<coreSize;y++)
    {
        for(int x=0;x<coreSize;x++)
        {
            vec4 currentColor=texture2D(inputImageTexture,textureCoordinate+vec2(float(-1+x)*texelOffset,float(-1+y)*texelOffset));
            
            
            color+=currentColor*kernel[index++];
        }
    }
    
    vec4 color1 = texture2D(inputImageTexture,textureCoordinate);
    bvec4 com = greaterThanEqual(color1,vec4(1.0));

    if (any(com)) {
        color1 = vec4(0.0,0.0,0.0,1.0);
    }
    
    gl_FragColor=10.0*color+color1;
}





//precision highp float;
//varying vec2 textureCoordinate;
//uniform sampler2D inputImageTexture;
//uniform vec2 resolution;
//uniform vec3 edgeColor;
//
//void generate_map(inout vec4 m[9], sampler2D tex, vec2 coord) {
//    float w = 1.0 / resolution.x;
//    float h = 1.0 / resolution.y;
//    m[0] = texture2D(tex, coord + vec2(-w, -h));
//    m[1] = texture2D(tex, coord + vec2(0.0, -h));
//    m[2] = texture2D(tex, coord + vec2(w, -h));
//    m[3] = texture2D(tex, coord + vec2(-w, 0.0));
//    m[4] = texture2D(tex, coord);
//    m[5] = texture2D(tex, coord + vec2(w, 0.0));
//    m[6] = texture2D(tex, coord + vec2(-w,  h));
//    m[7] = texture2D(tex, coord + vec2(0.0, h));
//    m[8] = texture2D(tex, coord + vec2(w, h));
//}
//
//vec3 returnEdgeColor(sampler2D tex){
//    vec4 m[9];
//    generate_map(m, tex, textureCoordinate);
//    vec4 edge_h = (m[0] * -1.0) + m[2] + (m[3] * -2.0) + (m[5] * 2.0) + (m[6] * -1.0) + m[8];
//    vec4 edge_v = m[0] + (2.0 * m[1]) + m[2] - (m[6] + 2.0 * m[7] + m[8]);
//    edge_h = clamp(edge_h, vec4(0.0), vec4(1.0));
//    edge_v = clamp(edge_v, vec4(0.0), vec4(1.0));
//    vec4 edge = sqrt(pow(edge_h, vec4(2.0)) + pow(edge_v, vec4(2.0)));
//    edge = clamp(1.15 * edge, vec4(0.0), vec4(1.0));
//    //float threshold = 1.0 - edge.x;
//    //float mask = step(0.5, threshold);
//    //vec3 color = vec3(edge.x * 0.91, edge.x * 0.29, edge.x * 0.29);
//    vec3 color = vec3(edge.x * edgeColor.r, edge.x * edgeColor.g, edge.x * edgeColor.b);
//    //vec4 mask2 = mask * texture2D(inputImageTexture, textureCoordinate);
//    //gl_FragColor = vec4(color + mask2.xyz, 1.0);
//
//    return color;
//}
//
//void main() {
//
//    vec3 color1 = returnEdgeColor(inputImageTexture);
//
//    gl_FragColor = vec4(color1, 1.0);
//}
