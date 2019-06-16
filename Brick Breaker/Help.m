//
//  Help.m
//  Brick Breaker
//
//  Created by Tantawy Mohammed on 13/6/19.
//  Copyright © 2019 Tantawy Mohammed. All rights reserved.
//

#import "Help.h"
#import "Menu.h"

@implementation Help{
    SKSpriteNode* _screen;
    SKSpriteNode* _help;
    SKSpriteNode* _next;
    SKSpriteNode* _back;
    SKSpriteNode* _skip;
    SKSpriteNode* _instructionsA;
    SKSpriteNode* _instructionsB;
    SKTextureAtlas* _graphics;
    int _position;
}

- (void)helpOneAnimation {
    SKAction* moveLeft = [SKAction moveToX:_help.position.x + 80 duration:1];
    SKAction* moveRight = [SKAction moveToX:_help.position.x - 80 duration:1];
    SKAction* moveLeftRight = [SKAction sequence:@[moveLeft, moveRight]];
    SKAction* movePaddle = [SKAction repeatAction:moveLeftRight count:-1];
    [_help runAction: [SKAction sequence:@[[SKAction waitForDuration:9],movePaddle]]];
}

- (void)didMoveToView:(SKView *)view{
    // Set up Atlas
    _graphics = [SKTextureAtlas atlasNamed:@"Graphics"];
    
    // Init position
    _position = 1;
    [self setUpHelpScreen:_position];
    
    // Add action to move help
    [self helpOneAnimation];
}

- (void)instructionsFirstScreen:(SKAction *)fadeIn fadeOut:(SKAction *)fadeOut {
    _instructionsA = [SKSpriteNode spriteNodeWithTexture:[_graphics textureNamed:@"help-instructions-1"]];
    _instructionsA.name = @"instructions";
    _instructionsA.position = CGPointMake(self.size.width * 0.5, self.size.height * 0.5);
    [self addChild:_instructionsA];
    _instructionsA.alpha = 0;
    [_instructionsA runAction:[SKAction sequence:@[fadeIn, [SKAction waitForDuration:3] ,fadeOut]]];
    
    _instructionsB = [SKSpriteNode spriteNodeWithTexture:[_graphics textureNamed:@"help-instructions-2"]];
    _instructionsB.name = @"instructions";
    _instructionsB.position = CGPointMake(self.size.width * 0.5, self.size.height * 0.5);
    [self addChild:_instructionsB];
    _instructionsB.alpha = 0;
    [_instructionsB runAction:[SKAction sequence:@[[SKAction waitForDuration:8], fadeIn]]];
    
    // Add helper
    _help = [SKSpriteNode spriteNodeWithTexture:[_graphics textureNamed:@"help-animation-1"]];
    _help.name = @"screen1";
    _help.position = CGPointMake(self.size.width * 0.5 + _help.size.width * 0.3, _help.size.height * 0.5);
    [self addChild:_help];
}

-(void)setUpHelpScreen:(int)position{
    SKAction* fadeIn = [SKAction fadeInWithDuration:2];
    SKAction* fadeOut = [SKAction fadeOutWithDuration:2];
    // Add screen background
    _screen = [SKSpriteNode spriteNodeWithTexture:[_graphics textureNamed:[NSString stringWithFormat:@"help-screen-%d", position]]];
    _screen.name = [NSString stringWithFormat:@"screen%d", position];
    _screen.size = self.size;
    _screen.position = CGPointMake(self.size.width * 0.5, self.size.height * 0.5);
    [self addChild:_screen];
    
    // Add next button
    _next = [SKSpriteNode spriteNodeWithTexture:[_graphics textureNamed:@"btn-next-help"]];
    _next.name = @"next";
    _next.position = CGPointMake(self.size.width - 30, self.size.height * 0.5);
    [self addChild:_next];
    _next.alpha = 0;
    [_next runAction:[SKAction sequence:@[[SKAction waitForDuration:8], fadeIn]]];
    
    // Add next button
    _back = [SKSpriteNode spriteNodeWithTexture:[_graphics textureNamed:@"btn-back-help"]];
    _back.name = @"back";
    _back.position = CGPointMake(30, self.size.height * 0.5);
    [self addChild:_back];
    _back.alpha = 0;
    [_back runAction:[SKAction sequence:@[[SKAction waitForDuration:8], fadeIn]]];
    
    // Add skip button
    _skip = [SKSpriteNode spriteNodeWithTexture:[_graphics textureNamed:@"btn-skip-help"]];
    _skip.name = @"skip";
    _skip.position = CGPointMake(self.size.width - 50, self.size.height - 50);
    [self addChild:_skip];
    
    SKSpriteNode* instructions;
    // Add help if needed
    if(position == 1){
        // Add instructions
        
        [self instructionsFirstScreen:fadeIn fadeOut:fadeOut];
    } else if(position == 2){
        instructions = [SKSpriteNode spriteNodeWithTexture:[_graphics textureNamed:@"help-animation-2"]];
        instructions.position = CGPointMake(self.size.width * 0.5, self.size.height * 0.5 - 20);
        [self addChild:instructions];
    } else if(position == 3){
        instructions = [SKSpriteNode spriteNodeWithTexture:[_graphics textureNamed:@"help-animation-3"]];
        instructions.position = CGPointMake(self.size.width * 0.5, self.size.height * 0.5 + 20);
        [self addChild:instructions];
    }
}

- (void)setGamePaused:(BOOL)gamePaused{
    if (gamePaused) {
        self.paused = NO;
    }
}

- (void)update:(NSTimeInterval)currentTime{
    self.paused = NO;
    if(_position == 1) _back.hidden = YES;
    else _back.hidden = NO;
    if(_position == 3) _next.hidden = YES;
    else _next.hidden = NO;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    for (UITouch *t in touches) {
        SKNode* node = [self nodeAtPoint: [t locationInNode:self]];
        if([node.name isEqualToString:@"next"]){
            [_help removeFromParent];
            _position++;
            [self setUpHelpScreen:_position];
        }
        if([node.name isEqualToString:@"back"]){
            _position--;
            [self setUpHelpScreen:_position];
            if(_position == 1) [self helpOneAnimation];
        }
        if([node.name isEqualToString:@"skip"]){
            SKView *skView = (SKView *)self.view;
            Menu* menu = [[Menu alloc] initWithSize:skView.bounds.size];
            menu.scaleMode = SKSceneScaleModeAspectFit;
            [skView presentScene: menu];
        }
    }
}
@end
