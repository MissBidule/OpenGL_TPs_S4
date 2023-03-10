#version 330

//variables d'entrées
in vec4 vLightSpacePos;
in vec3 vPosition_vs; //w0 normalize(-vPos)
in vec3 vNormal_vs;
in vec2 vTexCoords;

out vec4 fFragColor;

uniform vec3 uKa;
uniform vec3 uKd;
uniform vec3 uKs;
uniform float uShininess;

uniform vec3 uLightDir_vs; //wi (need normalization)
uniform vec3 uLightPos_vs;
uniform vec3 uLightIntensity; //Li

uniform sampler2D uTexture;

vec3 PointblinnPhong() {
        float d = distance(vPosition_vs, uLightPos_vs);
        vec3 Li = (uLightIntensity / (d * d));
        vec3 N = vNormal_vs;
        vec3 w0 = normalize(-vPosition_vs);
        vec3 wi = normalize(uLightPos_vs - vPosition_vs);
        vec3 halfVector = (w0 + wi)/2.f;
        
        return Li*(uKd*max(dot(wi, N), 0.) + uKs*pow(max(dot(halfVector, N), 0.), uShininess));
}

vec3 blinnPhong() {
        vec3 Li = uLightIntensity;
        vec3 N = normalize(vNormal_vs);
        vec3 w0 = normalize(-vPosition_vs);
        vec3 wi = normalize(uLightDir_vs);
        vec3 halfVector = (w0 + wi)/2.f;
        
        return Li*(uKd*max(dot(wi, N), 0.) + uKs*max(pow(dot(halfVector, N), 0.), uShininess));
}

float calcShadowFactor() {
    vec3 projCoords = vLightSpacePos.xyz / vLightSpacePos.w;
    vec2 UVCoords = vec2(0.5 * projCoords.x + 0.5, 0.5 * projCoords.y + 0.5);
    float z = 0.5 * projCoords.z + 0.5;
    float depth = texture(uTexture, UVCoords).x;

    float bias = 0.015;

    if (depth + bias < z)
        return 0.5;
    else
        return 1.0;
}

vec3 projCoords = vLightSpacePos.xyz / vLightSpacePos.w;
vec2 UVCoords = vec2(0.5 * projCoords.x + 0.5, 0.5 * projCoords.y + 0.5);
float z = 0.5 * projCoords.z + 0.5;
float depth = texture(uTexture, UVCoords).x;


void main() {
    fFragColor = vec4(uKa + calcShadowFactor()*blinnPhong(), 1);
}
