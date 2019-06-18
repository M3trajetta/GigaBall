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
#import "Help.h"
#import "HelpViewController.h"

@implementation Menu{
    SKTextureAtlas* _graphics;
    CGPoint _touchLocationMusic;
    CGPoint _touchLocationSound;
    SKNode* _foreground;
    SKNode* _settings;
    SKSpriteNode* _playButton;
    SKSpriteNode* _optionsButton;
    SKSpriteNode* _scoresButton;
    SKSpriteNode* _helpButton;
    SKSpriteNode* _sound;
    SKSpriteNode* _musicSlider;
    SKSpriteNode* _musicScrollBar;
    SKSpriteNode* _controlAccelerometer;
    SKSpriteNode* _controlTouch;
    SKSpriteNode* _backBtn;
    BOOL _soundOn;
    BOOL _controlWithAccelerometer;
    AudioPlayer* _player;
    NSUserDefaults* _user;
    int _spacing;
    int _addSizeToFont;
    CMMotionManager* cmm;
}

- (void)didMoveToView:(SKView *)view{
    //authenticate Game Center user if not already
    [[GameCenterManager sharedManager] authenticatePlayer];
    
    _graphics = [SKTextureAtlas atlasNamed:@"Graphics"];
    self.physicsWorld.gravity = CGVectorMake(0.0, 0.0);
    
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
    _foreground = [[SKNode node] init];
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
    _optionsButton = [SKSpriteNode spriteNodeWithTexture:[_graphics textureNamed:@"btn-options"]];
    _optionsButton.name = @"options";
    _optionsButton.position = CGPointMake(_playButton.position.x, _playButton.position.y - 90 - _spacing);
    [_foreground addChild: _optionsButton];
    
    // Animate Options button
    _optionsButton.alpha = 0;
    SKAction* animateOptionsButton = [SKAction group:@[[SKAction moveToX:posX duration:1.3],
                                                    [SKAction fadeInWithDuration:1.6]]];
    animateOptionsButton.timingMode = SKActionTimingEaseOut;
    [_optionsButton runAction:animateOptionsButton];
    
    // Score button
    _scoresButton = [SKSpriteNode spriteNodeWithTexture:[_graphics textureNamed:@"btn-scores"]];
    _scoresButton.name = @"scores";
    _scoresButton.position = CGPointMake(_optionsButton.position.x, _optionsButton.position.y - 90 - _spacing);
    [_foreground addChild: _scoresButton];
    
    // Animate Score button
    _scoresButton.alpha = 0;
    SKAction* animateScoreButton = [SKAction group:@[[SKAction moveToX:posX duration:1.6],
                                                       [SKAction fadeInWithDuration:1.9]]];
    animateScoreButton.timingMode = SKActionTimingEaseOut;
    [_scoresButton runAction:animateScoreButton];
    
    // Credit button
     _helpButton = [SKSpriteNode spriteNodeWithTexture:[_graphics textureNamed:@"btn-help"]];
    _helpButton.name = @"help";
    _helpButton.position = CGPointMake(_scoresButton.position.x, _scoresButton.position.y - 90 - _spacing);
    [_foreground addChild: _helpButton];
    
    // Animate Credit button
    _helpButton.alpha = 0;
    SKAction* animate_helpButton = [SKAction group:@[[SKAction moveToX:posX duration:1.9],
                                                     [SKAction fadeInWithDuration:2.1]]];
    animate_helpButton.timingMode = SKActionTimingEaseOut;
    [_helpButton runAction:animate_helpButton];
    
    // Core motion
    cmm = [[CMMotionManager alloc] init];
    [cmm startDeviceMotionUpdates];
    cmm.accelerometerUpdateInterval = 1.0 / 60.0;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    for (UITouch *touch in touches) {
        SKNode* node = [self nodeAtPoint: [touch locationInNode:self]];
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
                _musicSlider.texture = [SKTexture textureWithImageNamed:@"music_off"];
            } else {
                _musicSlider.texture = [SKTexture textureWithImageNamed:@"music_slider"];
            }
        }
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{    
    for (UITouch *t in touches) {
        SKNode* node = [self nodeAtPoint: [t locationInNode:self]];
        SKAction* buttonClick = [SKAction sequence:@[[SKAction scaleTo:1.2 duration:0.1], [SKAction scaleTo:1.0 duration:0.1]]];
        if([node.name isEqualToString:@"play"]){
            [_playButton runAction:buttonClick completion:^{
                NSUserDefaults* epLevel = [NSUserDefaults standardUserDefaults];
                int levelSaved = [[epLevel stringForKey:@"epilogue-level"] intValue];
                self->_player.isPlaying = NO;
                [self->_player.audioPlayer stop];
                SKTransition *reveal = [SKTransition fadeWithColor:[SKColor whiteColor] duration:1.0];
                if(levelSaved){
                    SKScene *gameScene = [[GameScene alloc]initWithSize:self.size andLevel:levelSaved];
                    [self.view presentScene:gameScene transition:reveal];
                } else{
                    SKScene *gameScene = [[GameScene alloc]initWithSize:self.size andLevel:1];
                    [self.view presentScene:gameScene transition:reveal];
                }
            }];
        }
        if([node.name isEqualToString:@"options"]){
            [_optionsButton runAction:buttonClick completion:^{
                    self->_foreground.hidden = YES;
                    [self showOptions];
            }];
        }
        if([node.name isEqualToString:@"scores"]){
            [_scoresButton runAction:buttonClick completion:^{
                [[GameCenterManager sharedManager]showLeaderboard];
            }];
        }
        if([node.name isEqualToString:@"help"]){
            [_helpButton runAction:buttonClick completion:^{
                // Create and configure the scene.
                SKScene *scene = [[Help alloc] initWithSize:self.view.frame.size];
                scene.scaleMode = SKSceneScaleModeAspectFit;
                
                // Present the scene.
                [self.view presentScene:scene];
            }];
        }
        if([node.name isEqualToString:@"sound"]){
            _soundOn = !_soundOn;
            // Save sound preference
            [_user setObject:[NSString stringWithFormat:@"%d",_soundOn] forKey:@"sounds-on"];
            if (_soundOn) _sound.texture = [SKTexture textureWithImageNamed:@"sound_on"];
            else _sound.texture = [SKTexture textureWithImageNamed:@"sound_off"];
        }
        if([node.name isEqualToString:@"back"]){
            [_backBtn runAction:buttonClick completion:^{
                [self->_settings removeFromParent];
                self->_foreground.hidden = NO;
            }];
            
        }
        if([node.name isEqualToString:@"touch_control"]){
            _controlWithAccelerometer = NO;
            [_user setObject:[NSString stringWithFormat:@"%d",_controlWithAccelerometer] forKey:@"accelerometer"];
            _controlTouch.texture = [SKTexture textureWithImageNamed:@"settings_touch"];
            _controlAccelerometer.texture = [SKTexture textureWithImageNamed:@"settings_accelerometer_disabled"];
            
        }
        if([node.name isEqualToString:@"accelerometer_control"]){
            _controlWithAccelerometer = YES;
            [_user setObject:[NSString stringWithFormat:@"%d",_controlWithAccelerometer] forKey:@"accelerometer"];
            _controlAccelerometer.texture = [SKTexture textureWithImageNamed:@"settings_accelerometer"];
            _controlTouch.texture = [SKTexture textureWithImageNamed:@"settings_touch_disabled"];
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
    SKSpriteNode* settingsLabel = [SKSpriteNode spriteNodeWithTexture:[_graphics textureNamed:@"settings_label"]];
    settingsLabel.position = CGPointMake(0, 160 + _spacing);
    [_settings addChild:settingsLabel];
    
    // Add Sounds Label
    SKSpriteNode* soundsLabel = [SKSpriteNode spriteNodeWithTexture:[_graphics textureNamed:@"sound_label"]];
    soundsLabel.position = CGPointMake(-120 - _spacing, 80);
    [_settings addChild:soundsLabel];
    
    // Load sound setting
    NSUserDefaults* user = [NSUserDefaults standardUserDefaults];
    NSString* soundOn = [user stringForKey:@"sounds_on"];
    
    // Add Sounds on / off button
    if(soundOn && [soundOn boolValue]){
        _sound = [SKSpriteNode spriteNodeWithTexture:[_graphics textureNamed:@"sound_on"]];
    } else if(soundOn && ![soundOn boolValue]){
        _sound = [SKSpriteNode spriteNodeWithTexture:[_graphics textureNamed:@"sound_off"]];
    } else {
        _sound = [SKSpriteNode spriteNodeWithTexture:[_graphics textureNamed:@"sound_on"]];
    }
    _sound.position = CGPointMake(50 + _spacing, 80);
    _sound.name = @"sound";
    [_settings addChild:_sound];
    
    // Add Music Label
    SKSpriteNode* musicLabel = [SKSpriteNode spriteNodeWithTexture:[_graphics textureNamed:@"music_label"]];
    musicLabel.position = CGPointMake(-130 - _spacing, 0);
    [_settings addChild:musicLabel];
    
    // Add Sounds scrollbar
    _musicScrollBar = [SKSpriteNode spriteNodeWithTexture:[_graphics textureNamed:@"settings-scrollbar"]];
    _musicScrollBar.position = CGPointMake(musicLabel.position.x + 180 + _spacing, musicLabel.position.y + 10);
    [_settings addChild:_musicScrollBar];
    
    // Add Sounds slider
    _musicSlider = [SKSpriteNode spriteNodeWithTexture:[_graphics textureNamed:@"music_slider"]];
    _musicSlider.name = @"music";
    _musicSlider.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:_musicSlider.size];
    _musicSlider.position = CGPointMake((_player.audioPlayer.volume * 186) - 93, 0);
    [_musicScrollBar addChild:_musicSlider];
    
    // Add Controls Label
    SKSpriteNode* controlsLabel = [SKSpriteNode spriteNodeWithTexture:[_graphics textureNamed:@"controls_label"]];
    controlsLabel.position = CGPointMake(-110 - _spacing, -80);
    [_settings addChild:controlsLabel];
    
    // Check if there are saved data for accelerometer
    NSString* savedControlType = [_user stringForKey:@"accelerometer"];
    if(savedControlType == nil){
        // if no data found, then default is set to touch controls
        _controlWithAccelerometer = NO;
        NSLog(@"NO DATA FOUND. Default used");
    } else {
        _controlWithAccelerometer = [[_user stringForKey:@"accelerometer"] boolValue];
        NSLog(@"DATA FOUND. Accelerometer: %d", _controlWithAccelerometer);
    }
    
    // Add accelerometer icon based on saved or default data
    if(_controlWithAccelerometer == YES) _controlAccelerometer = [SKSpriteNode spriteNodeWithTexture:[_graphics textureNamed:@"settings_accelerometer"]];
    else _controlAccelerometer = [SKSpriteNode spriteNodeWithTexture:[_graphics textureNamed:@"settings_accelerometer_disabled"]];
    
    _controlAccelerometer.position = CGPointMake(controlsLabel.position.x + 120 + _spacing, controlsLabel.position.y);
    _controlAccelerometer.name = @"accelerometer_control";
    [_settings addChild:_controlAccelerometer];
    
    // Add touch icon based on saved or default data
    if(_controlWithAccelerometer == YES) _controlTouch = [SKSpriteNode spriteNodeWithTexture:[_graphics textureNamed:@"settings_touch_disabled"]];
    else _controlTouch = [SKSpriteNode spriteNodeWithTexture:[_graphics textureNamed:@"settings_touch"]];

    _controlTouch.position = CGPointMake(_controlAccelerometer.position.x + _controlAccelerometer.size.width * 0.5 + 60 + _spacing, _controlAccelerometer.position.y);
    _controlTouch.name = @"touch_control";
    [_settings addChild:_controlTouch];
    
    if([cmm isAccelerometerAvailable] == NO){
        // Enable choice of controls
        _controlAccelerometer = [SKSpriteNode spriteNodeWithTexture:[_graphics textureNamed:@"settings_accelerometer_disabled"]];
    }
    
    // Okay button
    _backBtn = [SKSpriteNode spriteNodeWithTexture:[_graphics textureNamed:@"btn-back-settings"]];
    _backBtn.position = CGPointMake(0, -160 - _spacing);
    _backBtn.name = @"back";
    [_settings addChild:_backBtn];
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
