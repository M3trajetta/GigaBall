//
//  Epilogue.m
//  Brick Breaker
//
//  Created by Tantawy Mohammed on 14/5/19.
//  Copyright © 2019 Tantawy Mohammed. All rights reserved.
//

#import "Epilogue.h"
#import "Menu.h"
#import "GameScene.h"

@implementation Epilogue{
    SKTextureAtlas* _graphics;
    SKLabelNode* _time;
    SKLabelNode* _score;
    SKLabelNode* _lives;
    SKSpriteNode* epilogue;
}

- (void)didMoveToView:(SKView *)view{
    
}

- (instancetype)initWithSize:(CGSize)size{
    if(self = [super initWithSize:size]){
        _graphics = [SKTextureAtlas atlasNamed:@"Graphics"];
        
        // Load data - time
        NSUserDefaults* user = [NSUserDefaults standardUserDefaults];
        NSString* timeText = [user stringForKey:@"epilogue-time"];
        // Load data - Lives
        NSString* livesText = [user stringForKey:@"epilogue-lives"];
        // Load data - Score
        NSString* scoreText = [user stringForKey:@"epilogue-score"];
        // Load data - Level
        NSString* levelText = [user stringForKey:@"epilogue-level"];
        
        SKSpriteNode* background = [SKSpriteNode spriteNodeWithTexture:[_graphics textureNamed:@"epilogue-bg"]];
        background.name = @"background";
        background.position = CGPointMake(self.size.width * 0.5, self.size.height * 0.5);
        [self addChild:background];
        
        epilogue = [SKSpriteNode spriteNodeWithTexture:[_graphics textureNamed:@"epilogue-menu-bg"]];
        epilogue.position = CGPointMake(self.frame.size.width * 0.5, self.frame.size.height * 0.5);
        [self addChild:epilogue];
        
        // Title
        SKLabelNode* title = [SKLabelNode labelNodeWithFontNamed:@"Oswald-Bold"];
        title.fontColor = [SKColor whiteColor];
        
        if ([livesText intValue] < 0) title.text = @"Game Over";
        else title.text = @"Level Cleared";
        
        title.fontSize = 50;
        title.position = CGPointMake(0, 120);
        [epilogue addChild:title];
        
        // Time Logo
        SKSpriteNode* timeLogo = [SKSpriteNode spriteNodeWithTexture:[_graphics textureNamed:@"epilogue-time"]];
        timeLogo.position = CGPointMake(-100, 70);
        [epilogue addChild:timeLogo];
        
        // Time Label
        _time = [SKLabelNode labelNodeWithFontNamed:@"Oswald-Bold"];
        _time.fontColor = [SKColor whiteColor];
        _time.fontSize = 25;
        _time.text = [NSString stringWithFormat:@"%@s", timeText];
        _time.position = CGPointMake(0, timeLogo.position.y - 10);
        [epilogue addChild:_time];
        
        // Lives Logo
        SKSpriteNode* livesLogo = [SKSpriteNode spriteNodeWithTexture:[_graphics textureNamed:@"epilogue-lives"]];
        livesLogo.position = CGPointMake(-100, 0);
        [epilogue addChild:livesLogo];
        
        // Lives label
        _lives = [SKLabelNode labelNodeWithFontNamed:@"Oswald-Bold"];
        _lives.fontColor = [SKColor whiteColor];
        _lives.fontSize = 25;
        _lives.text = [NSString stringWithFormat:@"%d", [livesText intValue]+1];
        _lives.position = CGPointMake(0, livesLogo.position.y - 10);
        [epilogue addChild:_lives];
        
        // Score Logo
        SKSpriteNode* scoreLogo = [SKSpriteNode spriteNodeWithTexture:[_graphics textureNamed:@"epilogue-score"]];
        scoreLogo.position = CGPointMake(-100, -70);
        [epilogue addChild:scoreLogo];
        
        // Score label
        _score = [SKLabelNode labelNodeWithFontNamed:@"Oswald-Bold"];
        _score.fontColor = [SKColor whiteColor];
        _score.fontSize = 25;
        _score.text = [NSString stringWithFormat:@"%@", scoreText];
        _score.position = CGPointMake(0, scoreLogo.position.y - 10);
        [epilogue addChild:_score];
        
        SKSpriteNode* btnHome = [SKSpriteNode spriteNodeWithTexture:[_graphics textureNamed:@"btn-home-menu"]];
        btnHome.position = CGPointMake(20, -130);
        btnHome.name = @"home";
        [epilogue addChild:btnHome];
        
        if ([livesText intValue] < 0){
            SKSpriteNode* btnRestart = [SKSpriteNode spriteNodeWithTexture:[_graphics textureNamed:@"btn-restart-menu"]];
            btnRestart.position = CGPointMake(100, -130);
            btnRestart.name = @"restart";
            [epilogue addChild:btnRestart];
        } else {
            SKSpriteNode* btnPlay = [SKSpriteNode spriteNodeWithTexture:[_graphics textureNamed:@"btn-play-menu"]];
            btnPlay.position = CGPointMake(100, -130);
            btnPlay.name = @"play";
            [epilogue addChild:btnPlay];
        }
    }
    return self;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    // Load data - Level
    NSUserDefaults* epLevel = [NSUserDefaults standardUserDefaults];
    NSString* levelText = [epLevel stringForKey:@"epilogue-level"];
    
    for (UITouch *t in touches) {
        SKNode* node = [epilogue nodeAtPoint: [t locationInNode:epilogue]];
        if([node.name isEqualToString:@"home"]){
            // Go to main screen
            NSLog(@"Go to main screen");
            SKScene *homeScene = [[Menu alloc]initWithSize:self.size];
            [self.view presentScene:homeScene];
        }
        if([node.name isEqualToString:@"restart"]){
            // Restart game
        }
        if([node.name isEqualToString:@"play"]){
            // Return to game to next level
            NSLog(@"Go to main screen");
            if(levelText){
                SKScene *gameScreen = [[GameScene alloc]initWithSize:self.size andLevel:[levelText intValue] + 1];
                [self.view presentScene:gameScreen];
            } else{
                SKScene *gameScreen = [[GameScene alloc]initWithSize:self.size andLevel:1];
                [self.view presentScene:gameScreen];
            }
        }
    }
}

@end
