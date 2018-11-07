//
//  Shader.metal
//  SceneKitMetalCLI
//
//  Created by Peng Liu on 11/6/18.
//  Copyright © 2018 Peng Liu. All rights reserved.
//

#include <metal_stdlib>
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
                           constant Uniforms & uniforms [[ buffer(1) ]])
{
    ColorInOut out;
    out.position = uniforms.projectionMatrix * uniforms.modelViewMatrix * float4(in.position, 1.0);
    out.col = float3(1, 0, 0);
    
    return out;
}

fragment float4 fsRender(ColorInOut in [[stage_in]])
{
    float4 colorSample = float4(in.col.xyz, 0.0);
    return float4(colorSample);
}

