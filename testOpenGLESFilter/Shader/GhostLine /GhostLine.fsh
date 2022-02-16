precision highp float;
varying vec2 textureCoordinate;
uniform sampler2D inputImageTexture;
uniform sampler2D inputImageTexture2;

uniform vec2 resolution;
uniform float time;

void main() {
    
    vec4 color = texture2D(inputImageTexture, textureCoordinate);
    
    float duration = 5.0;
    float offset = 0.02;
    float maxScale = 1.3;


    float scale = 1.0 + (0.5 - textureCoordinate.x) * 0.3;
                         
    vec2 ScaleTextureCoords1 = vec2(0.5, textureCoordinate.y) + (textureCoordinate - vec2(0.5 , textureCoordinate.y)) / 1.0 ;
    vec4 mask1 = texture2D(inputImageTexture2, ScaleTextureCoords1);

    vec2 ScaleTextureCoords2 = vec2(0.5, textureCoordinate.y) + (textureCoordinate - vec2(0.5, textureCoordinate.y)) / (scale / 0.95) ;
    vec4 mask2 = texture2D(inputImageTexture2, ScaleTextureCoords2);

    vec2 ScaleTextureCoords3 = vec2(0.5, textureCoordinate.y) + (textureCoordinate - vec2(0.5, textureCoordinate.y)) / (scale / 0.90) ;
    vec4 mask3 = texture2D(inputImageTexture2, ScaleTextureCoords3);

    vec2 ScaleTextureCoords4 = vec2(0.5, textureCoordinate.y) + (textureCoordinate - vec2(0.5, textureCoordinate.y)) / (scale / 0.85) ;
    vec4 mask4 = texture2D(inputImageTexture2, ScaleTextureCoords4);

    vec2 ScaleTextureCoords5 = vec2(0.5, textureCoordinate.y) + (textureCoordinate - vec2(0.5, textureCoordinate.y)) / (scale / 0.80) ;
    vec4 mask5 = texture2D(inputImageTexture2, ScaleTextureCoords5);

    vec2 ScaleTextureCoords6 = vec2(0.5, textureCoordinate.y) + (textureCoordinate - vec2(0.5, textureCoordinate.y)) / (scale / 0.75) ;
    vec4 mask6 = texture2D(inputImageTexture2, ScaleTextureCoords6);

    vec2 ScaleTextureCoords7 = vec2(0.5, textureCoordinate.y) + (textureCoordinate - vec2(0.5, textureCoordinate.y)) / (scale / 0.70) ;
    vec4 mask7 = texture2D(inputImageTexture2, ScaleTextureCoords7);

    bvec3 com1 = greaterThan(mask1.rgb, vec3(0.5));
    bvec3 com2 = greaterThan(mask2.rgb, vec3(0.5));
    bvec3 com3 = greaterThan(mask3.rgb, vec3(0.5));
    bvec3 com4 = greaterThan(mask4.rgb, vec3(0.5));
    bvec3 com5 = greaterThan(mask5.rgb, vec3(0.5));
    bvec3 com6 = greaterThan(mask6.rgb, vec3(0.5));
    bvec3 com7 = greaterThan(mask7.rgb, vec3(0.5));

    vec4 mask11 = vec4(0.0);
    vec4 mask22 = vec4(0.0);
    vec4 mask33 = vec4(0.0);
    vec4 mask44 = vec4(0.0);
    vec4 mask55 = vec4(0.0);
    vec4 mask66 = vec4(0.0);
    vec4 mask77 = vec4(0.0);

    if(any(com1)) {
        mask11 = vec4(0.75,0.25,0.55,1.0);
    }

    if(any(com2)) {
    mask22 = vec4(0.37,0.66,0.85,1.0);
    }

    if(any(com3)) {
    mask33 = vec4(0.39,0.66,0.85,1.0);
    }

    if(any(com4)) {
    mask44 = vec4(0.41,0.66,0.85,1.0);
    }

    if(any(com5)) {
    mask55 = vec4(0.65,0.39,0.72,1.0);
    }

    if(any(com6)) {
    mask66 = vec4(0.65,0.39,0.72,1.0);
    }

    if(any(com7)) {
    mask77 = vec4(0.65,0.39,0.72,1.0);
    }

    bvec3 com11 = greaterThan(mask11.rgb, vec3(0.0));
    if(any(com11)) {
        mask22 = vec4(0.0);
        mask33 = vec4(0.0);
        mask44 = vec4(0.0);
        mask55 = vec4(0.0);
        mask66 = vec4(0.0);
        mask77 = vec4(0.0);

        color = vec4(0.0);
    }

    bvec3 com22 = greaterThan(mask22.rgb, vec3(0.0));
    if(any(com22)) {
        mask33 = vec4(0.0);
        mask44 = vec4(0.0);
        mask55 = vec4(0.0);
        mask66 = vec4(0.0);
        mask77 = vec4(0.0);

        color = vec4(0.0);
    }

    bvec3 com33 = greaterThan(mask33.rgb, vec3(0.0));
    if(any(com33)) {
        mask44 = vec4(0.0);
        mask55 = vec4(0.0);
        mask66 = vec4(0.0);
        mask77 = vec4(0.0);

        color = vec4(0.0);
    }

    bvec3 com44 = greaterThan(mask44.rgb, vec3(0.0));
    if(any(com44)) {
        mask55 = vec4(0.0);
        mask66 = vec4(0.0);
        mask77 = vec4(0.0);

        color = vec4(0.0);
    }

    bvec3 com55 = greaterThan(mask55.rgb, vec3(0.0));
    if(any(com55)) {
        mask66 = vec4(0.0);
        mask77 = vec4(0.0);

        color = vec4(0.0);
    }

     bvec3 com66 = greaterThan(mask66.rgb, vec3(0.0));
     if(any(com66)) {
        mask77 = vec4(0.0);
        color = vec4(0.0);
     }

     bvec3 com77 = greaterThan(mask77.rgb, vec3(0.0));
     if(any(com77)) {
         color = vec4(0.0);
     }

    gl_FragColor = clamp(mask11 + mask22 + mask33 + mask44 + mask55 + mask66 + mask77 + color, vec4(0.0), vec4(1.0));
    
}
