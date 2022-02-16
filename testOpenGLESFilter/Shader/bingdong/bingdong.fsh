
precision highp float;

uniform sampler2D inputImageTexture;
varying vec2 textureCoordinate;


void main () {
    vec3 col = texture2D(inputImageTexture,textureCoordinate).rgb;
    gl_FragColor.r = abs(col.r-col.g-col.b)*3.0/2.0;
    gl_FragColor.g = abs(col.g-col.b-col.r)*3.0/2.0;
    gl_FragColor.b = abs(col.b-col.r-col.g)*3.0/2.0;
    gl_FragColor.a = 1.0;
    
}

