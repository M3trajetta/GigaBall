//
//  Brick.h
//  Brick Breaker
//
//  Created by Tantawy Mohammed on 8/4/19.
//  Copyright © 2019 Tantawy Mohammed. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
typedef enum : NSUInteger{
    Green = 1,
    Blue = 2,
    Gray = 3,
    Yellow = 4,
    YellowDmg = 5
} BrickType;

NS_ASSUME_NONNULL_BEGIN

@interface Brick : SKSpriteNode

@property (nonatomic) BrickType type;
@property (nonatomic) int powerUp;
@property (nonatomic) int hitBrick;
@property (nonatomic) BOOL indistructible;
@property (nonatomic) int score;

-(instancetype)initWithType: (BrickType)type;
-(void)hit;

@end

NS_ASSUME_NONNULL_END
