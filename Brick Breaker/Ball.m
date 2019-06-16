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
            self.trail = [self newBallTrail];
            [self updateTrail];
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

// Create particle effect without file
-(SKEmitterNode *)newBallTrail
{
    //instantiate trail emitter
    SKEmitterNode *trail = [[SKEmitterNode alloc] init];
    
    [trail setParticleTexture:[SKTexture textureWithImageNamed:@"ball-energy"]];
    [trail setParticleColor:[UIColor cyanColor]];
    [trail setNumParticlesToEmit:0];
    [trail setParticleBirthRate:200];
    [trail setParticleLifetime:0.5];
    [trail setEmissionAngleRange:360];
    [trail setParticleSpeed:40];
    [trail setParticleSpeedRange:0];
    [trail setXAcceleration:0];
    [trail setYAcceleration:0];
    [trail setParticleAlpha:1];
    [trail setParticleAlphaRange:0.5];
    [trail setParticleAlphaSpeed:-1];
    [trail setParticleScale:0.3];
    [trail setParticleScaleRange:0.3];
    [trail setParticleScaleSpeed:-0.3];
    [trail setParticleRotation:0];
    [trail setParticleRotationRange:360];
    [trail setParticleRotationSpeed:0];
    
    [trail setParticleColorBlendFactor:1];
    [trail setParticleColorBlendFactorRange:0];
    [trail setParticleColorBlendFactorSpeed:0];
    [trail setParticleBlendMode:SKBlendModeAdd];
    
    return trail;
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
