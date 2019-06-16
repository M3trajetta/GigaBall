//
//  BeforePlay.m
//  Brick Breaker
//
//  Created by Tantawy Mohammed on 16/6/19.
//  Copyright © 2019 Tantawy Mohammed. All rights reserved.
//

#import "BeforePlay.h"

@implementation BeforePlay{
    SKSpriteNode* _panel;
    SKSpriteNode* _playButton;
    SKSpriteNode* _shadow;
}

- (instancetype)init
{
    self = [super init];
    SKTextureAtlas* graphics = [SKTextureAtlas atlasNamed:@"Graphics"];
    if (self) {
        _shadow = [SKSpriteNode spriteNodeWithTexture:[graphics textureNamed:@"shadow"]];
        _shadow.position = CGPointZero;
        [self addChild:_shadow];
        
        _panel = [SKSpriteNode spriteNodeWithTexture:[graphics textureNamed:@"before-play-level-1"]];
        _panel.position = CGPointMake(0, 40 + _panel.size.height * 0.5);
        [self addChild:_panel];
        
        _playButton = [SKSpriteNode spriteNodeWithTexture:[graphics textureNamed:@"before-play-playBtn"]];
        _playButton.name = @"before";
        _playButton.position = CGPointMake(0, -40 + _playButton.size.height * 0.5);
        [self addChild:_playButton];
    }
    return self;
}

- (void)show{
    SKAction* slideLeft = [SKAction moveByX:-300 y:0 duration:0.5];
    slideLeft.timingMode = SKActionTimingEaseOut;
    SKAction* slideRight = [SKAction moveByX:300 y:0 duration:0.5];
    slideRight.timingMode = SKActionTimingEaseIn;
    
    SKAction* buttonGrow = [SKAction scaleTo:1.2 duration:0.1];
    SKAction* buttonShrink = [SKAction scaleTo:1.0 duration:0.1];
    SKAction* buttonClick = [SKAction sequence:@[[SKAction waitForDuration:2],buttonGrow, buttonShrink, [SKAction waitForDuration:1]]];
    
    _panel.position = CGPointMake(300, _panel.position.y);
    _playButton.position = CGPointMake(-300, _playButton.position.y);
    
    [_panel runAction:slideLeft];
    [_playButton runAction:slideRight completion:^{
        [self->_playButton runAction:[SKAction repeatAction:buttonClick count:-1]];
    }];
    self.hidden = NO;
    
}

- (void)hide{
    SKAction* slideLeft = [SKAction moveByX:-300 y:0 duration:0.5];
    slideLeft.timingMode = SKActionTimingEaseIn;
    SKAction* slideRight = [SKAction moveByX:300 y:0 duration:0.5];
    slideRight.timingMode = SKActionTimingEaseIn;
    
    _panel.position = CGPointMake(0, _panel.position.y);
    _playButton.position = CGPointMake(0, _playButton.position.y);
    
    [_panel runAction:slideLeft];
    [_playButton runAction:slideRight completion:^{
        self.hidden = YES;
    }];
    
    
}
@end
