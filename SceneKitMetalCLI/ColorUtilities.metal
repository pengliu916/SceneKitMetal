//
//  ColorUtilities.metal
//  SceneKitMetalCLI
//
//  Created by Peng Liu on 11/7/18.
//  Copyright © 2018 Peng Liu. All rights reserved.
//

#include <metal_stdlib>

#import "SharedHeader.h"

using namespace metal;

// fL: [0,10000] for 0 to 10000nits
template <class T>
inline T L2PQ(T fL) {
    T fx = pow(fL / 10000.f, fM1);
    fx = (fC1 + fC2 * fx) / (1.f + fC3 * fx);
    return pow(fx, fM2);
}

// fPQ: [0,1]
template <class T>
inline T PQ2L(T fPQ) {
    T fx = pow(fPQ, 1.f / fM2);
    fx = (fx - fC1) / (fC2 - fC3 * fx);
    fx = max(fx, 0.f);
    return 10000.f * pow(fx, 1.f / fM1);
}

inline float3 BT2020D65RGB_2_XYZ(float3 f3RGB) {
    const float3x3 mTran = float3x3(+0.636958048301291, +0.144616903586208, +0.168880975164172,
                                    +0.262700212011267, +0.677998071518871, +0.059301716469862,
                                    +0.000000000000000, +0.028072693049087, +1.060985057710791);
    return f3RGB * mTran;
}

inline float3 P3D65RGB_2_XYZ(float3 f3RGB) {
    const float3x3 mTran = float3x3(+0.486570948648216, +0.265667693169093, +0.198217285234362,
                                    +0.228974564069749, +0.691738521836506, +0.079286914093745,
                                    +0.000000000000000, +0.045113381858903, +1.043944368900976);
    return f3RGB * mTran;
}

inline float3 XYZ_2_BT2020D65RGB(float3 f3XYZ) {
    const float3x3 mTran = float3x3(+1.716651187971268, -0.355670783776392, -0.253366281373660,
                                    -0.666684351832489, +1.616481236634939, +0.015768545813911,
                                    +0.017639857445311, -0.042770613257808, +0.942103121235474);
    return f3XYZ * mTran;
}

inline float3 XYZ_2_P3D65RGB(float3 f3XYZ) {
    const float3x3 mTran = float3x3(+2.493509123934610, -0.931388179404779, -0.402712756741652,
                                    -0.829473213929554, +1.762630579600303, +0.02364237105589,
                                    +0.035851264433918, -0.076183936922076, +0.957029586694311);
    return f3XYZ * mTran;
}

inline float3 XYZ_2_xyY(float3 f3XYZ) {
    float fXYZSum = dot(f3XYZ, 1);
    if (fXYZSum <= 0.000001)
        // Return D65 white
        return float3(0.31271, 0.32902, 0);
    return float3(f3XYZ.xy / fXYZSum, f3XYZ.y);
}
