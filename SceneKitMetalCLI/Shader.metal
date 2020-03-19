//
//  Shader.metal
//  SceneKitMetalCLI
//
//  Created by Peng Liu on 11/6/18.
//  Copyright © 2018 Peng Liu. All rights reserved.
//

#include <metal_stdlib>
#include "ColorUtilities.metal"
using namespace metal;

inline float3 BT2020D65_2_LMS(float3 f3RGB) {
    const float3x3 mTran = float3x3(1688.f / 4096.f, 2146.f / 4096.f, 262.f / 4096.f,
                                    683.f / 4096.f, 2951.f / 4096.f, 462.f / 4096.f,
                                    99.f / 4096.f, 309.f / 4096.f, 3688.f / 4096.f);
    return f3RGB * mTran;
}

inline float3 LMSPrime_2_ITP(float3 f3LMS) {
    const float3x3 mTran = float3x3( 0.4000,  0.4000,  0.2000,
                                    4.4550, -4.8510,  0.3960,
                                    0.8056,  0.3572, -1.1628);
    return f3LMS * mTran;
}

typedef struct
{
    float4x4 projectionMatrix;
    float4x4 modelViewMatrix;
    float edrFactor;
} Uniforms;

typedef struct
{
    float3 position [[attribute(0)]];
} Vertex;

typedef struct
{
    float4 position [[position]];
    float3 col;
} ColorInOut;

vertex ColorInOut vsRender(Vertex in [[ stage_in ]],
                           constant Uniforms & uniforms [[ buffer(1) ]],
                           constant uint3 & u3Quantile [[ buffer(2) ]],
                           constant bool & bShowAll [[ buffer(3) ]],
                           constant float & fFocuseVal [[ buffer(4) ]],
                           uint iid [[ instance_id ]])
{
    ColorInOut out;
    int ilayerCnt = u3Quantile.x * u3Quantile.y;
    int z = iid / ilayerCnt;
    int y = (iid % ilayerCnt) / u3Quantile.x;
    int x = iid % u3Quantile.x;
    
    //if (all(uint3(x,y,z)!=(u3Quantile - 1)) && x*y*z !=0)
        //return out;
    
    float3 f3BoxSize = 1.0 / float3(u3Quantile);
    float3 f3Offset = float3(x,y,z) * f3BoxSize;
    float fZoffset = 0.f;
    if (!bShowAll) {
        float3 f3MaxCol = f3BoxSize + f3Offset;
        float3 f3MinCol = f3Offset;
        float fMaxBrightness = BT2020D65RGB_2_XYZ(PQ2L(f3MaxCol)).y;
        float fMinBrightness = BT2020D65RGB_2_XYZ(PQ2L(f3MinCol)).y;
        fZoffset = fFocuseVal/10000.f;
        //if ( fFocuseVal/10000.f>f3MaxCol.y || fFocuseVal/10000.f < f3MinCol.x)
        if ( fFocuseVal>fMaxBrightness || fFocuseVal < fMinBrightness)
            return out;
    } else {
        fZoffset = 0.3f;
    }
    // This is color value in PQ
    float3 f3Pos = (in.position + 0.5) * f3BoxSize + f3Offset;
    
    float3 lineCol = PQ2L(f3Pos);
    
    //f3Pos = XYZ_2_xyY(BT2020D65RGB_2_XYZ(lineCol));
    f3Pos = LMSPrime_2_ITP(L2PQ(BT2020D65_2_LMS(lineCol)));
    
   // fZoffset = fFocuseVal/100.f;
    //f3Pos.x *= fZoffset;
    //f3Pos -= float3(0.31271, 0.329, fZoffset);
    f3Pos.x -= 0.5;
    
    out.col = lineCol / 10000.f * uniforms.edrFactor;
    out.position = uniforms.projectionMatrix * uniforms.modelViewMatrix * float4(f3Pos.yxz, 1.0);
    
    return out;
}

fragment float4 fsRender(ColorInOut in [[stage_in]])
{
    float4 colorSample = float4(in.col.xyz, 0.0);
    return float4(colorSample);
}

