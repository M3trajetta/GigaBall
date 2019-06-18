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
#import "AudioPlayer.h"

@implementation Epilogue{
    SKTextureAtlas* _graphics;
    SKLabelNode* _time;
    SKLabelNode* _score;
    SKLabelNode* _lives;
    SKSpriteNode* epilogue;
    int _smallSpace;
    int _spacing;
    int _addSizeToFont;
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
        //NSString* scoreText = [user stringForKey:@"epilogue-score"];
        // Load data - Score
        NSString* totalScoreText = [user stringForKey:@"epilogue-score"];
        // Load data - Level
        //NSString* levelText = [user stringForKey:@"epilogue-level"];
        
        CGFloat screenWidth = size.width;
        if(screenWidth > 500 && UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation)){
            _spacing = 50;
            _smallSpace = 15;
            NSLog(@"Needs spacing");
            _addSizeToFont = 20;
        } else {
            _spacing = 0;
            _smallSpace = 0;
            _addSizeToFont = 0;
        }
        
        SKSpriteNode* background = [SKSpriteNode spriteNodeWithTexture:[_graphics textureNamed:@"epilogue-bg"]];
        background.name = @"background";
        background.position = CGPointMake(self.size.width * 0.5, self.size.height * 0.5);
        [self addChild:background];
        
        
        if ([livesText intValue] < 0) epilogue = [SKSpriteNode spriteNodeWithTexture:[_graphics textureNamed:@"epilogue-menu-bg-go"]];
        else epilogue = [SKSpriteNode spriteNodeWithTexture:[_graphics textureNamed:@"epilogue-menu-bg-lc"]];
        epilogue.position = CGPointMake(self.frame.size.width * 0.5, self.frame.size.height * 0.5);
        [self addChild:epilogue];
        
        // Time Logo
        SKSpriteNode* timeLogo = [SKSpriteNode spriteNodeWithTexture:[_graphics textureNamed:@"ep-time"]];
        timeLogo.position = CGPointMake(-100 - _spacing, 70 + _smallSpace);
        [epilogue addChild:timeLogo];
        
        // Time Label
        _time = [SKLabelNode labelNodeWithFontNamed:@"zorque"];
        _time.fontColor = [SKColor whiteColor];
        _time.fontSize = 25 + _addSizeToFont;
        _time.text = [NSString stringWithFormat:@"%@ sec", timeText];
        _time.position = CGPointMake(0, timeLogo.position.y - 10 - _smallSpace);
        [epilogue addChild:_time];
        
        // Lives Logo
        SKSpriteNode* livesLogo = [SKSpriteNode spriteNodeWithTexture:[_graphics textureNamed:@"ep-lives"]];
        livesLogo.position = CGPointMake(-100 - _spacing, 0 - _smallSpace);
        [epilogue addChild:livesLogo];
        
        // Lives label
        _lives = [SKLabelNode labelNodeWithFontNamed:@"zorque"];
        _lives.fontColor = [SKColor whiteColor];
        _lives.fontSize = 25 + _addSizeToFont;
        _lives.text = [NSString stringWithFormat:@"%d", [livesText intValue]+1];
        _lives.position = CGPointMake(0, livesLogo.position.y - 10 - _smallSpace);
        [epilogue addChild:_lives];
        
        // Score Logo
        SKSpriteNode* scoreLogo = [SKSpriteNode spriteNodeWithTexture:[_graphics textureNamed:@"ep-score"]];
        scoreLogo.position = CGPointMake(-100 - _spacing, -70 - _smallSpace*2);
        [epilogue addChild:scoreLogo];
        
        // Score label
        _score = [SKLabelNode labelNodeWithFontNamed:@"zorque"];
        _score.fontColor = [SKColor whiteColor];
        _score.fontSize = 25 + _addSizeToFont;
        _score.text = [NSString stringWithFormat:@"%@", totalScoreText];
        _score.position = CGPointMake(0, scoreLogo.position.y - 10 - _smallSpace);
        [epilogue addChild:_score];
        
        SKSpriteNode* btnHome = [SKSpriteNode spriteNodeWithTexture:[_graphics textureNamed:@"btn-home-menu"]];
        btnHome.position = CGPointMake(20, -130 - _spacing - _smallSpace);
        btnHome.name = @"home";
        [epilogue addChild:btnHome];
        
        if ([livesText intValue] < 0){
            SKSpriteNode* btnRestart = [SKSpriteNode spriteNodeWithTexture:[_graphics textureNamed:@"btn-restart-menu"]];
            btnRestart.position = CGPointMake(100 + _spacing, -130 - _spacing - _smallSpace);
            btnRestart.name = @"restart";
            [epilogue addChild:btnRestart];
        } else {
            SKSpriteNode* btnPlay = [SKSpriteNode spriteNodeWithTexture:[_graphics textureNamed:@"btn-play-menu"]];
            btnPlay.position = CGPointMake(100 + _spacing, -130 - _spacing - _smallSpace);
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
            SKScene *gameScreen = [[GameScene alloc]initWithSize:self.size andLevel: 1];
            
            [self.view presentScene:gameScreen];
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
