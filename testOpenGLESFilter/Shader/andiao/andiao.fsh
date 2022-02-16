
precision highp float;

uniform sampler2D inputImageTexture;
varying vec2 textureCoordinate;



void main () {
    
    vec2 uv = textureCoordinate.xy;


    
    vec3 col = texture2D(inputImageTexture,textureCoordinate).rgb;

        gl_FragColor.r = col.r*col.r;
        gl_FragColor.g = col.g*col.g;
        gl_FragColor.b = col.b*col.b;
        gl_FragColor.a = 1.0;
    
}
