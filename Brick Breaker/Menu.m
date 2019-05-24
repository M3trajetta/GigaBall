//
//  Menu.m
//  Brick Breaker
//
//  Created by Tantawy Mohammed on 9/4/19.
//  Copyright © 2019 Tantawy Mohammed. All rights reserved.
//

#import "Menu.h"
#import "AppDelegate.h"
#import "GameScene.h"
#import "GameCenterManager.h"
#import "AudioPlayer.h"
#import "Epilogue.h"

@implementation Menu{
    SKTextureAtlas* _graphics;
    CGPoint _touchLocationMusic;
    CGPoint _touchLocationSound;
    SKNode* _foreground;
    SKNode* _settings;
    SKSpriteNode* _playButton;
    SKSpriteNode* _sound;
    SKSpriteNode* _musicSlider;
    SKSpriteNode* _musicScrollBar;
    BOOL _soundOn;
    BOOL _safeArea;
    AudioPlayer* _player;
    NSUserDefaults* _user;
    int _spacing;
    int _addSizeToFont;
}

- (void)didMoveToView:(SKView *)view{
    _graphics = [SKTextureAtlas atlasNamed:@"Graphics"];
    self.physicsWorld.gravity = CGVectorMake(0.0, 0.0);
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    CGFloat width = CGRectGetWidth(self.view.bounds);
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        // Iphone
        NSLog(@"Iphone detected: %f", width);
        if (screenSize.height >= 812){
            // Safe area
        }
    } else if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        // Ipad
        NSLog(@"Ipad detected: %f", width);

    } else {
        NSLog(@"Unknown device");
    }
    
    
    CGFloat screenWidth = CGRectGetWidth(self.view.bounds);
    // Check if screen width is greater than 500 and orientation of the device is portrait
    if(screenWidth > 500){
        _spacing = 50;
        _addSizeToFont = 20;
    } else {
        _spacing = 0;
        _addSizeToFont = 0;
    }
    // Load saved info
    _user = [NSUserDefaults standardUserDefaults];
    
    // Create player for this screen
    _player = [[AudioPlayer alloc]init:@"ChillTrap"];
    
    // Load volume if saved
    float volume = [[_user stringForKey:@"volume"] floatValue];
    if(volume) _player.audioPlayer.volume = volume;
    else _player.audioPlayer.volume = 0.5;
    [_player.audioPlayer play];
    
    SKSpriteNode* background = [SKSpriteNode spriteNodeWithTexture:[_graphics textureNamed:@"bg_menu"]];
    background.name = @"background";
    background.position = CGPointMake(self.size.width * 0.5, self.size.height * 0.5);
    [self addChild:background];
    
    // Add _foreground
    _foreground = [[SKNode node]init];
    _foreground.position = CGPointMake(self.size.width * 0.5, self.size.height * 0.5);
    [self addChild:_foreground];
    
    // Load logo
    SKSpriteNode* logo = [SKSpriteNode spriteNodeWithTexture:[_graphics textureNamed:@"bb-logo"]];
    //logo.size = CGSizeMake(logo.size.width * 2, logo.size.height * 2);
    logo.position = CGPointMake(_foreground.frame.size.width * 0.5, _foreground.frame.size.height * 0.5 + 200);
    [_foreground addChild:logo];
    
    // Animate logo
    logo.xScale = 4.0;
    logo.yScale = 4.0;
    logo.alpha = 0;
    SKAction* animateLogo = [SKAction group:@[[SKAction scaleTo:1.0 duration:0.5],
                                              [SKAction fadeInWithDuration:1.0]]];
    animateLogo.timingMode = SKActionTimingEaseOut;
    [logo runAction:animateLogo];
    
    // Play button
    _playButton = [SKSpriteNode spriteNodeWithTexture:[_graphics textureNamed:@"btn-play"]];
    _playButton.name = @"play";
    _playButton.position = CGPointMake(_foreground.frame.size.width * 0.5, _foreground.frame.size.height * 0.5 - _spacing);
    [_foreground addChild: _playButton];
    
    // Animate Play Button
    CGFloat posX = _foreground.frame.size.width * 0.5;
    _playButton.position = CGPointMake(posX + 200, _foreground.frame.size.height * 0.5 - _spacing);
    _playButton.alpha = 0;
    SKAction* animatePlayButton = [SKAction group:@[[SKAction moveToX:posX duration:1.0],
                                                    [SKAction fadeInWithDuration:1.3]]];
    animatePlayButton.timingMode = SKActionTimingEaseOut;
    [_playButton runAction:animatePlayButton];
    
    // Options button
    SKSpriteNode* optionsButton = [SKSpriteNode spriteNodeWithTexture:[_graphics textureNamed:@"btn-options"]];
    optionsButton.name = @"options";
    optionsButton.position = CGPointMake(_playButton.position.x, _playButton.position.y - 80 - _spacing);
    [_foreground addChild: optionsButton];
    
    // Animate Options button
    optionsButton.alpha = 0;
    SKAction* animateOptionsButton = [SKAction group:@[[SKAction moveToX:posX duration:1.3],
                                                    [SKAction fadeInWithDuration:1.6]]];
    animateOptionsButton.timingMode = SKActionTimingEaseOut;
    [optionsButton runAction:animateOptionsButton];
    
    // Score button
    SKSpriteNode* scoresButton = [SKSpriteNode spriteNodeWithTexture:[_graphics textureNamed:@"btn-scores"]];
    scoresButton.name = @"scores";
    scoresButton.position = CGPointMake(optionsButton.position.x, optionsButton.position.y - 80 - _spacing);
    [_foreground addChild: scoresButton];
    
    // Animate Score button
    scoresButton.alpha = 0;
    SKAction* animateScoreButton = [SKAction group:@[[SKAction moveToX:posX duration:1.6],
                                                       [SKAction fadeInWithDuration:1.9]]];
    animateScoreButton.timingMode = SKActionTimingEaseOut;
    [scoresButton runAction:animateScoreButton];
    
    // Credit button
    SKSpriteNode* helpButton = [SKSpriteNode spriteNodeWithTexture:[_graphics textureNamed:@"btn-help"]];
    helpButton.name = @"help";
    helpButton.position = CGPointMake(scoresButton.position.x, scoresButton.position.y - 80 - _spacing);
    [_foreground addChild: helpButton];
    
    // Animate Credit button
    helpButton.alpha = 0;
    SKAction* animateHelpButton = [SKAction group:@[[SKAction moveToX:posX duration:1.9],
                                                     [SKAction fadeInWithDuration:2.1]]];
    animateHelpButton.timingMode = SKActionTimingEaseOut;
    [helpButton runAction:animateHelpButton];
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    for (UITouch *touch in touches) {
        SKNode* node = [self nodeAtPoint: [touch locationInNode:self]];
        if([node.name isEqualToString:@"play"]){
            _playButton.texture = [SKTexture textureWithImageNamed:@"btn-play-pressed"];
        }
        if([node.name isEqualToString:@"music"]){
            _touchLocationMusic = [touch locationInNode:self];
        }
        if([node.name isEqualToString:@"sounds"]){
            _touchLocationSound = [touch locationInNode:self];
        }
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    CGFloat minX = -_musicScrollBar.size.width * 0.5;
    CGFloat maxX = _musicScrollBar.size.width * 0.5;
    
    for (UITouch *touch in touches) {
        SKNode* node = [self nodeAtPoint: [touch locationInNode:self]];
        if([node.name isEqualToString:@"music"]){
            // Calculate how far the touch moved
            CGFloat xMovementMusic = [touch locationInNode:self].x - _touchLocationMusic.x;
            // Move paddle distance of touch
            _musicSlider.position = CGPointMake(_musicSlider.position.x + xMovementMusic, _musicSlider.position.y);
            // Cap music slider position so it remains on the screen
            if(_musicSlider.position.x < minX) { _musicSlider.position = CGPointMake(minX, _musicSlider.position.y); }
            if(_musicSlider.position.x > maxX) { _musicSlider.position = CGPointMake(maxX, _musicSlider.position.y); }
            _touchLocationMusic = [touch locationInNode:self];
            _player.audioPlayer.volume = (_musicSlider.position.x + 93) / 186;
            [_user setObject:[NSString stringWithFormat:@"%f",_player.audioPlayer.volume] forKey:@"volume"];
            if(_player.audioPlayer.volume == 0){
                _musicSlider.texture = [SKTexture textureWithImageNamed:@"music-off"];
            } else {
                _musicSlider.texture = [SKTexture textureWithImageNamed:@"settings-slider"];
            }
        }
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{    
    for (UITouch *t in touches) {
        SKNode* node = [self nodeAtPoint: [t locationInNode:self]];
        if([node.name isEqualToString:@"play"]){
            _playButton.texture = [SKTexture textureWithImageNamed:@"btn-play"];
            NSUserDefaults* epLevel = [NSUserDefaults standardUserDefaults];
            int levelSaved = [[epLevel stringForKey:@"epilogue-level"] intValue];
            _player.isPlaying = NO;
            [_player.audioPlayer stop];
            SKTransition *reveal = [SKTransition fadeWithColor:[SKColor whiteColor] duration:1.0];
            if(levelSaved){
                SKScene *gameScene = [[GameScene alloc]initWithSize:self.size andLevel:levelSaved];
                [self.view presentScene:gameScene transition:reveal];
            } else{
                SKScene *gameScene = [[GameScene alloc]initWithSize:self.size andLevel:1];
                [self.view presentScene:gameScene transition:reveal];
            }
        }
        if([node.name isEqualToString:@"options"]){
            _foreground.hidden = YES;
            [self showOptions];
        }
        if([node.name isEqualToString:@"scores"]){
            [[GameCenterManager sharedManager]showLeaderboard];
        }
        if([node.name isEqualToString:@"help"]){
            NSLog(@"Help");
        }
        if([node.name isEqualToString:@"sound"]){
            _soundOn = !_soundOn;
            // Save sound preference
            [_user setObject:[NSString stringWithFormat:@"%d",_soundOn] forKey:@"sounds-on"];
            if (_soundOn) {
                _sound.texture = [SKTexture textureWithImageNamed:@"sound-on"];
            } else {
                _sound.texture = [SKTexture textureWithImageNamed:@"sound-off"];
            }
        }
        if([node.name isEqualToString:@"okay"]){
            [_settings removeFromParent];
            _foreground.hidden = NO;
        }
    }
}

- (void)showOptions{
    // Foreground for the settings
    _settings = [[SKNode node]init];
    _settings.position = CGPointMake(self.size.width * 0.5, self.size.height * 0.5);
    [self addChild:_settings];
    
    // Add the box for the settings
    SKSpriteNode* settings = [SKSpriteNode spriteNodeWithTexture:[_graphics textureNamed:@"settings-bg"]];
    settings.position = CGPointZero;
    [_settings addChild:settings];
    
    // Add title for the box
    SKLabelNode* title = [SKLabelNode labelNodeWithFontNamed:@"Oswald-Bold"];
    title.fontColor = [SKColor whiteColor];
    title.fontSize = 50 + _addSizeToFont;
    title.text = @"Settings";
    title.position = CGPointMake(0, 120 + _spacing);
    [_settings addChild:title];
    
    // Add Sounds Label
    SKLabelNode* soundsLabel = [SKLabelNode labelNodeWithFontNamed:@"Oswald-Bold"];
    soundsLabel.fontColor = [SKColor whiteColor];
    soundsLabel.fontSize = 30 + _addSizeToFont;
    soundsLabel.text = @"Sounds";
    soundsLabel.position = CGPointMake(-120 - _spacing, 50);
    [_settings addChild:soundsLabel];
    
    // Load sound setting
    NSUserDefaults* user = [NSUserDefaults standardUserDefaults];
    NSString* soundOn = [user stringForKey:@"sounds-on"];
    
    // Add Sounds on / off button
    if(soundOn && [soundOn boolValue]){
        _sound = [SKSpriteNode spriteNodeWithTexture:[_graphics textureNamed:@"sound-on"]];
    } else if(soundOn && ![soundOn boolValue]){
        _sound = [SKSpriteNode spriteNodeWithTexture:[_graphics textureNamed:@"sound-off"]];
    } else {
        _sound = [SKSpriteNode spriteNodeWithTexture:[_graphics textureNamed:@"sound-on"]];
    }
    _sound.position = CGPointMake(0 + _spacing, 60);
    _sound.name = @"sound";
    _sound.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:_sound.size];
    [_settings addChild:_sound];
    
    // Add Music Label
    SKLabelNode* musicLabel = [SKLabelNode labelNodeWithFontNamed:@"Oswald-Bold"];
    musicLabel.fontColor = [SKColor whiteColor];
    musicLabel.fontSize = 30 + _addSizeToFont;
    musicLabel.text = @"Music";
    musicLabel.position = CGPointMake(-130 - _spacing, -30);
    [_settings addChild:musicLabel];
    
    // Add Sounds scrollbar
    _musicScrollBar = [SKSpriteNode spriteNodeWithTexture:[_graphics textureNamed:@"settings-scrollbar"]];
    _musicScrollBar.position = CGPointMake(musicLabel.position.x + 180 + _spacing, musicLabel.position.y + 10);
    [_settings addChild:_musicScrollBar];
    
    // Add Sounds slider
    _musicSlider = [SKSpriteNode spriteNodeWithTexture:[_graphics textureNamed:@"settings-slider"]];
    _musicSlider.name = @"music";
    _musicSlider.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:_musicSlider.size];
    _musicSlider.position = CGPointMake((_player.audioPlayer.volume * 186) - 93, 0);
    [_musicScrollBar addChild:_musicSlider];
    
    // Okay button
    SKSpriteNode* okBtn = [SKSpriteNode spriteNodeWithTexture:[_graphics textureNamed:@"btn-ok-settings"]];
    okBtn.position = CGPointMake(0, _musicScrollBar.position.y - 100 - _spacing);
    okBtn.name = @"okay";
    [_settings addChild:okBtn];
}


- (void)setGamePaused:(BOOL)gamePaused{
    if (gamePaused) {
        self.paused = NO;
    }
}

- (void)update:(NSTimeInterval)currentTime{
    self.paused = NO;
}



@end
