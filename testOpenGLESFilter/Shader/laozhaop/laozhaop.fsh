
precision highp float;

uniform sampler2D inputImageTexture;
varying vec2 textureCoordinate;



void main () {

    
    vec3 col = texture2D(inputImageTexture,textureCoordinate).rgb;
        gl_FragColor.r = 0.393*col.r+0.769*col.g+0.189*col.b;
        gl_FragColor.g = 0.349*col.r+0.686*col.g+0.168*col.b;
        gl_FragColor.b = 0.272*col.r+0.534*col.g+0.131*col.b;
        gl_FragColor.a = 1.0;

    
}
