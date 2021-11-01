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

float noise( in float2 x ){ return smoothstep(0.,1.,sin(1.5*x.x)*sin(1.5*x.y)); }

float fbm( float2 p ){
    
    float2x2 m = rot(.4);
    float f = 0.0;
    f += 0.500000*(0.5+0.5*noise( p )); p = mul(m,p)*2.02;
    f += 0.250000*(0.5+0.5*noise( p )); p = mul(m,p)*2.03;
    f += 0.125000*(0.5+0.5*noise( p )); p = mul(m,p)*2.01;
    f += 0.015625*(0.5+0.5*noise( p ));
    return f/0.96875;
}

float pattern (in float2 p, out float2 q, out float2 r, float t) {
   
	q.x = fbm( 2.0*p + float2(0.0,0.0) + 2.*t );
    q.y = fbm( 1.5*p + float2(5.2,1.3) + 1.*t );

    r.x = fbm( p + 4.*q + float2(1.7,9.2) + sin(t) + .9*sin(30.*length(q)));
    r.y = fbm( p + 8.*q + float2(8.3,2.8) + cos(t) + .9*sin(20.*length(q)));

    float2 s;
    s.x = fbm( p + 21.0*r + float2(1.7,9.2) + sin(t) );
    s.y = fbm( p + 16.0*r + float2(8.3,2.8) + cos(t) );

    return fbm( p + 7.*mul(s,rot(t)) );
}

float4 main(float4 pos : SV_POSITION, float2 tex : TEXCOORD) : SV_TARGET
{

    float2 uv = 2*pos.xy;
    uv.x = uv.x/Resolution.x;
    uv.y = uv.y/Resolution.y;
    uv.x = uv.x * Resolution.x/Resolution.y;
	
    float2 q = float2(0.,0.); float2 r = float2(0.,0.);
    float3 col1 = float3(.9,.7,.5);
    float3 col2 = float3(.3,.5,.4);
    float3 c;

    float f = pattern(uv, q, r, 0.1*Time);

    //mix colours
    c = lerp(col1, float3(0,0,0), pow(smoothstep(.0,.9,f), 2.));
    float x = smoothstep(0., .8, (q.y*r.y + r.x*q.x)*.6);
    c = c + col2 * pow(x, 3.) * 1.5;
    //add contrast
    c *= pow(dot(q,r) + .7, 5.);
    //soften the bright parts
    c *= f*1.5;

    //c += float3(1.7,1.2,1.2) * dot(q,r);
    //c += float3(.2) * smoothstep(0., .2,pow(length(q),3.));
    //c += dot(q,r);
    //c += smoothstep(0.,3.,pow(length(df),0.12));

    float4 agate;
    agate.xyz = c;
    agate.w = abs(pow(c/abs(c), 5));

    float4 col = shaderTexture.Sample(samplerState, tex);
    col *= agate;

    return col;
}
