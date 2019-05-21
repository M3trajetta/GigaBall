//
//  Ball.h
//  Brick Breaker
//
//  Created by Tantawy Mohammed on 12/4/19.
//  Copyright © 2019 Tantawy Mohammed. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
typedef enum : NSUInteger{
    Normal = 1,
    Energy= 2,
    Through = 3
} BallType;

NS_ASSUME_NONNULL_BEGIN

@interface Ball : SKSpriteNode

@property (nonatomic) BallType type;
@property (nonatomic) SKEmitterNode* trail;
-(void)updateTrail;
-(instancetype)initWithType:(BallType)type;

@end

NS_ASSUME_NONNULL_END
