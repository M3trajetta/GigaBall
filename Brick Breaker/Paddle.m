//
//  Paddle.m
//  Brick Breaker
//
//  Created by Tantawy Mohammed on 12/4/19.
//  Copyright © 2019 Tantawy Mohammed. All rights reserved.
//

#import "Paddle.h"
#import "Constants.h"

@implementation Paddle

-(instancetype)initWithType:(PaddleType)type{
    SKTextureAtlas* graphics = [SKTextureAtlas atlasNamed:@"Graphics"];
    switch (type) {
        case Standard:
            self = [super initWithTexture:[graphics textureNamed:@"paddle"]];
            self.canShoot = NO;
            break;
        case StandardBang:
            self = [super initWithTexture:[graphics textureNamed:@"paddle-laser"]];
            self.canShoot = YES;
            break;
        case Small:
            self = [super initWithTexture:[graphics textureNamed:@"paddle-small"]];
            self.canShoot = NO;
            break;
        case SmallBang:
            self = [super initWithTexture:[graphics textureNamed:@"paddle-small-laser"]];
            self.canShoot = YES;
            break;
        case Big:
            self = [super initWithTexture:[graphics textureNamed:@"paddle-big"]];
            self.canShoot = NO;
            break;
        case BigBang:
            self = [super initWithTexture:[graphics textureNamed:@"paddle-big-laser"]];
            self.canShoot = YES;
            break;
        default:
            self.type = 1;
            break;
    }
    
    if(self){
        self.name = @"paddle";
        self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.size];
        self.physicsBody.friction = 0;
        self.physicsBody.linearDamping = 0;
        self.physicsBody.restitution = 1;
        self.physicsBody.categoryBitMask = paddleCategory;
        self.physicsBody.collisionBitMask = ballCategory;
        self.physicsBody.contactTestBitMask = ballCategory;
        self.physicsBody.dynamic = NO;
        self.type = type;
    }
    return self;
}

- (PaddleType)getPaddleForLaser{
    switch (self.type) {
        case Standard:
            return StandardBang;
            break;
        case Small:
            return SmallBang;
        case Big:
            return BigBang;
        default:
            return StandardBang;
            break;
    }
}

- (void)setCanShoot:(BOOL)canShoot{
    _canShoot = canShoot;
}

- (void)setType:(PaddleType)type{
    _type = type;
}
@end
