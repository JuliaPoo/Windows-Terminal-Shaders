// The terminal graphics as a texture
Texture2D shaderTexture;
SamplerState samplerState;

// Terminal settings such as the resolution of the texture
cbuffer PixelShaderSettings {
  // The number of seconds since the pixel shader was enabled
  float  Time;
  // UI Scale
  float  Scale;
  // Resolution of the shaderTexture
  float2 Resolution;
  // Background color as rgba
  float4 Background;
};

int julia(float2 uv, float2 c){
    int i=0;
    while (i<100 && length(uv)<2.) {
        uv = float2(uv.x*uv.x - uv.y*uv.y, 2.*uv.x*uv.y)+c;
        i += 1;
    }
    return i;
}

float4 main(float4 pos : SV_POSITION, float2 tex : TEXCOORD) : SV_TARGET
{

    float2 uv = pos.xy;
    uv.x = uv.x / Resolution.x;
    uv.y = uv.y / Resolution.y;
    uv = (uv - 0.5) * 4.;
    uv.y = uv.y * Resolution.y/Resolution.x;
    float t = .1* Time + 1.9;
    float r = 0.8;

    //julia
    float j = float(julia(uv, r*float2(cos(t+0.5),sin(1.7*t+0.5))))/(100.*.3);
    float3 filt = 0.8 + 0.2*cos(Time + uv.xyx/4 + float3(0,2,4)); 
    float3 nj = j*filt;

    float4 col = shaderTexture.Sample(samplerState, tex);
    col.xyz = sqrt(col.xyz * col.xyz + nj*nj);
    col.w = (0.5-j) * (1-length(uv/2));
    return col;
}