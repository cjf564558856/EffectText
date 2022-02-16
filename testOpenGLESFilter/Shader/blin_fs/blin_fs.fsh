
#ifdef GL_ES
precision mediump float;
#endif
uniform vec4 U_AmbientMaterial;
uniform vec4 U_DiffuseMaterial;
uniform vec4 U_SpecularMaterial;
uniform vec4 U_AmbientLight;
uniform vec4 U_LightPos;
uniform vec4 U_DiffuseLight;
uniform vec4 U_SpecularLight;
uniform vec4 U_CameraPos;
varying vec4 V_Normal;
varying vec4 V_WorldPos;

void main()
{
    
    vec4 U_LightPos = vec4(0.0,1.0,0.0,0.0);
    
    vec3 L=U_LightPos.xyz;
    L=normalize(L);
    vec3 n=normalize(V_Normal.xyz);
    float diffuseIntensity=max(0.0,dot(L,n));
    vec4 diffuseColor=U_DiffuseLight*U_DiffuseMaterial*diffuseIntensity;
    vec4 specularColor=vec4(0.0,0.0,0.0,0.0);
    if(diffuseIntensity>0.0){
        vec3 worldPos=V_WorldPos.xyz;
        vec3 viewDir=normalize(U_CameraPos.xyz-worldPos);
        vec3 halfVector=normalize(L+viewDir);
        specularColor=U_SpecularLight*U_SpecularMaterial*pow(max(0.0,dot(n,halfVector)),4.0);
    }
    gl_FragColor=U_AmbientMaterial*U_AmbientLight+diffuseColor+specularColor;
}
