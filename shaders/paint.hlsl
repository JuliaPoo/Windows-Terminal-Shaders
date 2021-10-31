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

float2x2 rot( float a )
{ 
    float s = sin(a);
    float c = cos(a);
    return float2x2( s,  c, -c,  s ); 
}

float noise( in float2 x )
{ 
    return smoothstep(0.,1.,sin(1.5*x.x)*sin(1.5*x.y)); 
}

float fbm( float2 p )
{
    float2x2 m = rot(.4);
    float f = 0.0;
    f += 0.500000*(0.5+0.5*noise( p )); p = mul(m,p)*2.02;
    f += 0.250000*(0.5+0.5*noise( p )); p = mul(m,p)*2.03;
    f += 0.125000*(0.5+0.5*noise( p )); p = mul(m,p)*2.01;
    f += 0.015625*(0.5+0.5*noise( p ));
    return f/0.96875;
}

float pattern(in float2 p, out float2 q, out float2 r, float t)
{
	q.x = fbm( p + float2(0.0,0.0) + .7*t );
    q.y = fbm( p + float2(5.2,1.3) + 1.*t );

    r.x = fbm( p + 10.0*q + float2(1.7,9.2) + sin(t) );
    r.y = fbm( p + 12.0*q + float2(8.3,2.8) + cos(t) );

    return fbm( p + 3.0*r );   
}

float4 main(float4 pos : SV_POSITION, float2 tex : TEXCOORD) : SV_TARGET
{
    float2 uv = pos.xy * 2.;
    uv.x = uv.x/Resolution.x; uv.y = uv.y/Resolution.y;
    uv.x = uv.x*Resolution.x/Resolution.y;
	
    float2 q = float2(0,0); float2 r = float2(0,0);
    float3 col1 = float3(0.,.9,.8);
    float3 col2 = float3(1.,.6,.5);
    
    float f = pattern(uv, q, r, 0.1*Time);
    
    float3 c = lerp(col1, float3(0,0,0), smoothstep(.0,.95,f));
    float3 a = col2 * smoothstep(0., .8, dot(q,r)*0.6);
    c = sqrt(c*c + a*a);
    c = pow(0.5+c, 3);

    float4 paint;
    paint.xyz = c;
    paint.w = 0;

    float4 col = shaderTexture.Sample(samplerState, tex);
    col *= paint;

    return col;
}
