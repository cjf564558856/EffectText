#ifdef GL_FRAGMENT_PRECISION_HIGH
precision highp float;
#else
precision mediump float;
#endif
uniform sampler2D Texture;
varying highp vec2 TextureCoordsVarying;

uniform  float Time;
uniform  vec2 resolution;


void main()
{

    vec2 p = gl_FragCoord.xy / resolution.xy;
    float T = fract(Time);
    float S0 = 1.0;
    float S1 = 50.0;
    float S2 = 1.0;
    float Half = 0.5;
    float PixelSize = ( T < Half ) ? mix( S0, S1, T / Half ) : mix( S1, S2, (T-Half) / Half );
    vec2 D = PixelSize / resolution.xy;
    // remap UV from 0...1 to -0.5...+0.5 to make the mosaic pattern converge torwards the image center\n\t
    vec2 UV = ( p + vec2( -0.5 ) ) / D;
    // don't forget to remap coords back to 0...1 after ceil()\n\t
    vec2 Coord = clamp( D * ( ceil( UV + vec2( -0.5 ) ) ) + vec2( 0.5 ), vec2( 0.0 ), vec2( 1.0 ) );
    vec4 C0 = texture2D( Texture, Coord );
    vec4 C1 = texture2D( Texture, Coord );
    gl_FragColor = mix( C0, C1, T );

    
}
