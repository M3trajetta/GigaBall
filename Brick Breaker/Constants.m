//
//  Constants.m
//  Brick Breaker
//
//  Created by Tantawy Mohammed on 11/4/19.
//  Copyright © 2019 Tantawy Mohammed. All rights reserved.
//

#import "Constants.h"

@implementation Constants

const uint32_t ballCategory         = 0x1 << 0;        //00000001
const uint32_t paddleCategory       = 0x1 << 1;        //00000010
const uint32_t brickCategory        = 0x1 << 2;        //00000100
const uint32_t edgeCategory         = 0x1 << 3;        //00001000
const uint32_t powerUpCategory      = 0x1 << 4;        //00010000
const uint32_t bangCategory         = 0x1 << 5;        //00100000
const uint32_t shieldCategory       = 0x1 << 6;        //01000000
const uint32_t bottomCategory       = 0x1 << 7;        //10000000

@end
