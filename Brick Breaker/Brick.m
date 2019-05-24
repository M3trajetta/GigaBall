//
//  Brick.m
//  Brick Breaker
//
//  Created by Tantawy Mohammed on 8/4/19.
//  Copyright © 2019 Tantawy Mohammed. All rights reserved.
//

#import "Brick.h"
#import "Constants.h"

@implementation Brick{
    SKAction* _brickSmashSound;
}

- (instancetype)initWithType:(BrickType)type{
    SKTextureAtlas* graphics = [SKTextureAtlas atlasNamed:@"Graphics"];
    switch (type) {
        case Green:
            self = [super initWithTexture:[graphics textureNamed:@"brick-green"]];
            break;
        case Blue:
            self = [super initWithTexture:[graphics textureNamed:@"brick-blue"]];
            break;
        case Gray:
            self = [super initWithTexture:[graphics textureNamed:@"brick-gray"]];
            break;
        case Yellow:
            self = [super initWithTexture:[graphics textureNamed:@"brick-yellow"]];
            break;
        case YellowDmg:
            self = [super initWithTexture:[graphics textureNamed:@"brick-yellow-damaged"]];
        default:
            self = nil;
            break;
    }
    
    if(self){
        self.name = @"brick";
        self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize: self.size];
        self.physicsBody.categoryBitMask = brickCategory;
        self.physicsBody.dynamic = NO;
        self.type = type;
        self.indistructible = (type == Gray);
    }
    return self;
}

- (void)hit{
    switch (self.type) {
        case Green:
            [self createExplosion];
            [self runAction:[SKAction removeFromParent]];
            break;
        case Blue:
            self.texture = [SKTexture textureWithImageNamed:@"brick-green"];
            self.type = Green;
            break;
        case Yellow:
            self.texture = [SKTexture textureWithImageNamed:@"brick-yellow-damaged"];
            self.type = YellowDmg;
            break;
        case YellowDmg:
            [self createExplosion];
            [self runAction:[SKAction removeFromParent]];
            break;
        default:
            // Gray brick are indistructibile - for now
            break;
    }
}

-(void)createExplosion{
    NSString* path = [[NSBundle mainBundle] pathForResource:@"BrickExplosion" ofType:@"sks"];
    SKEmitterNode* explosion = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    explosion.position = self.position;
    [self.parent addChild:explosion];
    
    // Remove emitters
    SKAction* removeExplosion = [SKAction sequence:@[[SKAction waitForDuration:explosion.particleLifetime+explosion.particleLifetimeRange],
                                                     [SKAction removeFromParent]]];
    [explosion runAction: removeExplosion];
}

- (void)setPowerUp:(int)powerUp{
    _powerUp = powerUp;
}

- (void)setScore:(int)score{
    _score = score;
}

@end
