//
//  Ball.m
//  Brick Breaker
//
//  Created by Tantawy Mohammed on 12/4/19.
//  Copyright © 2019 Tantawy Mohammed. All rights reserved.
//

#import "Ball.h"
#import "Constants.h"

@implementation Ball

-(instancetype) initWithType:(BallType)type{
    SKTextureAtlas* graphics = [SKTextureAtlas atlasNamed:@"Graphics"];
    switch (type) {
        case Normal:
            self = [super initWithTexture:[graphics textureNamed:@"ball"]];
            break;
        case Energy:
            self = [super initWithTexture:[graphics textureNamed:@"ball-energy"]];
            break;
            
        default:
            // Normal?
            break;
    }
    
    if(self){
        self.name = @"ball";
        self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:self.frame.size.width * 0.5];
        self.physicsBody.friction = 0;
        self.physicsBody.linearDamping = 0;
        self.physicsBody.restitution = 1;
        self.physicsBody.categoryBitMask = ballCategory;
        self.physicsBody.collisionBitMask = paddleCategory | brickCategory | edgeCategory | shieldCategory;
        self.physicsBody.contactTestBitMask = paddleCategory | brickCategory | edgeCategory | bottomCategory | shieldCategory;
        self.type = type;
    }
    return self;
}

- (void)updateTrail{
    if(self.trail){
        self.trail.position = self.position;
    }
}

- (void)removeFromParent{
    if(self.trail){
        self.trail.particleBirthRate = 0;
        SKAction* removeTrail = [SKAction sequence:@[[SKAction waitForDuration:self.trail.particleLifetime + self.trail.particleLifetimeRange],
                                                     [SKAction removeFromParent]]];
        [self.trail runAction: removeTrail];
    }
    [super removeFromParent];
}
@end
