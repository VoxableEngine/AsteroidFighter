#include "Uniforms.glsl"
#include "Samplers.glsl"
#include "Transform.glsl"
#include "ScreenPos.glsl"

varying vec2 vTexCoord;
varying vec2 vScreenPos;

#ifdef COMPILEPS
#endif

#define T texture2D(sDiffMap,.0+(p.xy*=0.992))

void VS()
{
    mat4 modelMatrix = iModelMatrix;
    vec3 worldPos = GetWorldPos(modelMatrix);
    gl_Position = GetClipPos(worldPos);
    vTexCoord = GetQuadTexCoord(gl_Position);
    vScreenPos = GetScreenPosPreDiv(gl_Position);
}

void PS()
{
    //vec3 resolution = vec3(1920.0, 1040.0, 10.0);
    //vec3 p = vec3(vTexCoord, 0.0); //gl_FragCoord.xyz / resolution-.0;
    //vec3 o = T.rgb;
    //for (float i=0.;i<5.;i++) 
    //    p.z += pow(max(0.,.5-length(T.bb)),2.0)*exp(-i*0.08);
    //vec2 uv = vTexCoord;
    //uv *= 2.0;
    //uv -= 1.0;
    
    float samples[10];
    samples[0] = -0.04;
    samples[1] = -0.025;
    samples[2] = -0.015;
    samples[3] = -0.01;
    samples[4] = -0.005;
    samples[5] =  0.005;
    samples[6] =  0.01;
    samples[7] =  0.015;
    samples[8] =  0.025;
    samples[9] =  0.04;
    
    vec2 dir = 0.9 + abs(sin(vTexCoord*cElapsedTimePS*10.25)); 
    float dist = length(dir); // sqrt(dir.x*dir.x + dir.y*dir.y); 
    dir = dir/dist; 
    
    vec4 color = texture2D(sDiffMap, vScreenPos); 
    vec4 sum = color;
    //finalColor *= abs(0.05 / (sin(uv.x + sin(uv.y+cElapsedTimePS)*0.3) * 20.0));
    for (int i=0;i<10;i++) 
        sum += texture2D(sDiffMap, vTexCoord + dir * samples[i] * 0.15);

    sum *= 1.0/11.0;
    float t = dist * 5.9;
    t = clamp( t ,0.0,1.0);

    gl_FragColor = mix( color, sum, t );
    
    //vec2 texCoord = vTexCoord;
    //int NUM_SAMPLES = 80;
    //float Density = 100.94;
    //float Weight = 5.65;
    //float Decay = 1.0;
    //float Exposure = 0.0034;
    
    //vec2 ScreenLightPos = vec2(cos(cElapsedTimePS*5.0), sin(cElapsedTimePS*5.0));
    
    // Calculate vector from pixel to light source in screen space.
    //vec2 deltaTexCoord = (vTexCoord - ScreenLightPos);

    // Divide by number of samples and scale by control factor.
    //deltaTexCoord *= 1.0f / NUM_SAMPLES * Density;

    // Store initial sample.
    //vec4 color = texture2D(sDiffMap, vScreenPos);

    // Set up illumination decay factor.
    //float illuminationDecay = 0.5f;

    // Evaluate summation from Equation 3 NUM_SAMPLES iterations.
    //for (int i = 0; i < NUM_SAMPLES; i++)
    //{
        // Step sample location along ray.
    //    texCoord -= deltaTexCoord;

        // Retrieve sample at new location.
    //    vec4 sample = texture2D(sDiffMap, vScreenPos);

        // Apply sample attenuation scale/decay factors.
    //    sample *= illuminationDecay * Weight;

        // Accumulate combined color.
    //    color += sample;

        // Update exponential decay factor.
    //    illuminationDecay *= Decay;
    //}   
    // Output final color with a further scale control factor.
    //gl_FragColor = color * Exposure;
    //gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
}

