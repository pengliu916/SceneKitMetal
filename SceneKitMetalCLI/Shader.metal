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

typedef struct
{
    float4x4 projectionMatrix;
    float4x4 modelViewMatrix;
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
                           ushort iid [[ instance_id ]])
{
    ColorInOut out;
    int ilayerCnt = u3Quantile.x * u3Quantile.y;
    int z = iid / ilayerCnt;
    int y = (iid % ilayerCnt) / u3Quantile.x;
    int x = iid % u3Quantile.x;
    
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
    
    f3Pos = XYZ_2_xyY(BT2020D65RGB_2_XYZ(lineCol));
    
    f3Pos.z /= 10000.f;
    f3Pos -= float3(0.31271, 0.329, fZoffset);
    
    out.col = lineCol / 10000.f;
    out.position = uniforms.projectionMatrix * uniforms.modelViewMatrix * float4(f3Pos.xzy, 1.0);
    
    return out;
}

fragment float4 fsRender(ColorInOut in [[stage_in]])
{
    float4 colorSample = float4(in.col.xyz, 0.0);
    return float4(colorSample);
}

