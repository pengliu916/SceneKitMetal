//
//  SharedHeader.h
//  SceneKitMetalCLI
//
//  Created by Peng Liu on 11/7/18.
//  Copyright © 2018 Peng Liu. All rights reserved.
//

#ifndef SharedHeader_h
#define SharedHeader_h

#ifdef __METAL_VERSION__
#define CONST constant
#else
#import <Foundation/Foundation.h>
#define CONST const
#endif

#include <simd/simd.h>

CONST float fM1 = 2610.0 / 4096.0 / 4.0;
CONST float fM2 = 2523.0 / 4096.0 * 128.0;
CONST float fC1 = 3424.0 / 4096.0;
CONST float fC2 = 2413.0 * 32.0 / 4096.0;
CONST float fC3 = 2392.0 / 4096.0 * 32.0;

#endif /* SharedHeader_h */
