//
//  Paddle.h
//  Brick Breaker
//
//  Created by Tantawy Mohammed on 12/4/19.
//  Copyright © 2019 Tantawy Mohammed. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

typedef enum : NSUInteger{
    Standard = 1,
    StandardBang = 2,
    Small = 3,
    SmallBang = 4,
    Big = 5,
    BigBang = 6
} PaddleType;

NS_ASSUME_NONNULL_BEGIN

@interface Paddle: SKSpriteNode

@property (nonatomic) PaddleType type;
@property (nonatomic) BOOL canShoot;

- (instancetype)initWithType:(PaddleType)type;
- (PaddleType)getPaddleForLaser;

@end

NS_ASSUME_NONNULL_END
