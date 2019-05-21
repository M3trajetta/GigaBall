//
//  Menu.m
//  Brick Breaker
//
//  Created by Tantawy Mohammed on 9/4/19.
//  Copyright © 2019 Tantawy Mohammed. All rights reserved.
//

#import "Menu.h"
#import "GameScene.h"
#import "GameCenterManager.h"
#import <AVFoundation/AVFoundation.h>

@implementation Menu{
    SKTextureAtlas* _graphics;
    AVAudioPlayer* _audioPlayer;
    CGPoint _touchLocationMusic;
    CGPoint _touchLocationSound;
    SKNode* _foreground;
    SKNode* _settings;
    SKSpriteNode* _sound;
    SKSpriteNode* _musicSlider;
    SKSpriteNode* _musicScrollBar;
    BOOL _soundOn;
}

- (void)didMoveToView:(SKView *)view{
    _graphics = [SKTextureAtlas atlasNamed:@"Graphics"];
    self.physicsWorld.gravity = CGVectorMake(0.0, 0.0);
    
    SKSpriteNode* background = [SKSpriteNode spriteNodeWithTexture:[_graphics textureNamed:@"bg_menu"]];
    background.size = self.frame.size;
    background.name = @"background";
    background.position = CGPointMake(self.frame.size.width * 0.5, self.frame.size.height * 0.5);
    [self addChild:background];
    
    // Add _foreground
    _foreground = [[SKNode node]init];
    _foreground.position = CGPointMake(self.size.width * 0.5, self.size.height * 0.5);
    [self addChild:_foreground];
    
    // Load logo
    SKSpriteNode* logo = [SKSpriteNode spriteNodeWithTexture:[_graphics textureNamed:@"bb-logo"]];
    logo.position = CGPointMake(_foreground.frame.size.width * 0.5, _foreground.frame.size.height * 0.5 + 200);
    [_foreground addChild:logo];
    
    // Play button
    SKSpriteNode* playButton = [SKSpriteNode spriteNodeWithTexture:[_graphics textureNamed:@"btn-play"]];
    playButton.name = @"play";
    playButton.position = CGPointMake(_foreground.frame.size.width * 0.5, _foreground.frame.size.height * 0.5);
    [_foreground addChild: playButton];
    
    // Options button
    SKSpriteNode* optionsButton = [SKSpriteNode spriteNodeWithTexture:[_graphics textureNamed:@"btn-options"]];
    optionsButton.name = @"options";
    optionsButton.position = CGPointMake(playButton.position.x, playButton.position.y - 80);
    [_foreground addChild: optionsButton];
    
    // Score button
    SKSpriteNode* scoresButton = [SKSpriteNode spriteNodeWithTexture:[_graphics textureNamed:@"btn-scores"]];
    scoresButton.name = @"scores";
    scoresButton.position = CGPointMake(optionsButton.position.x, optionsButton.position.y - 80);
    [_foreground addChild: scoresButton];
    
    // Credit button
    SKSpriteNode* helpButton = [SKSpriteNode spriteNodeWithTexture:[_graphics textureNamed:@"btn-help"]];
    helpButton.name = @"help";
    helpButton.position = CGPointMake(scoresButton.position.x, scoresButton.position.y - 80);
    [_foreground addChild: helpButton];
}

- (instancetype)initWithSize:(CGSize)size{
    if(self = [super initWithSize:size]){
        // Load player for the main menu only
        NSURL* url= [[NSBundle mainBundle] URLForResource:@"ObservingTheStars" withExtension:@"caf"];
        NSError* err = nil;
        
        _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&err];
        if(!_audioPlayer) NSLog(@"Error loading Audio Player: %@", err);
        else{
            _audioPlayer.numberOfLoops = -1;
            _audioPlayer.volume = 0.8;
            [_audioPlayer play];
        }
        _soundOn = YES;
    }
    return self;
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
            _audioPlayer.volume = (_musicSlider.position.x + 93) / 186;
            if(_audioPlayer.volume == 0){
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
            NSUserDefaults* epLevel = [NSUserDefaults standardUserDefaults];
            NSString* levelText = [epLevel stringForKey:@"epilogue-level"];
            if(levelText){
                SKScene *gameScene = [[GameScene alloc]initWithSize:self.size andLevel:[levelText intValue]];
                [self.view presentScene:gameScene];
            } else{
                SKScene *gameScene = [[GameScene alloc]initWithSize:self.size andLevel:1];
                [self.view presentScene:gameScene];
            }
        }
        if([node.name isEqualToString:@"options"]){
            NSLog(@"Options");
            _foreground.hidden = YES;
            [self showOptions];
        }
        if([node.name isEqualToString:@"scores"]){
            NSLog(@"Scores");
            [[GameCenterManager sharedManager]showLeaderboard];
        }
        if([node.name isEqualToString:@"help"]){
            NSLog(@"Help");
        }
        if([node.name isEqualToString:@"sound"]){
            _soundOn = !_soundOn;
            NSUserDefaults* user = [NSUserDefaults standardUserDefaults];
            [user setObject:[NSString stringWithFormat:@"%d",_soundOn] forKey:@"sounds-on"];
            if (_soundOn) {
                _sound.texture = [SKTexture textureWithImageNamed:@"settings-slider"];
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
    title.fontSize = 50;
    title.text = @"Settings";
    title.position = CGPointMake(0, 120);
    [_settings addChild:title];
    
    // Add Sounds Label
    SKLabelNode* soundsLabel = [SKLabelNode labelNodeWithFontNamed:@"Oswald-Bold"];
    soundsLabel.fontColor = [SKColor whiteColor];
    soundsLabel.fontSize = 30;
    soundsLabel.text = @"Sounds";
    soundsLabel.position = CGPointMake(-120, 50);
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
    _sound.position = CGPointMake(0, 60);
    _sound.name = @"sound";
    _sound.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:_sound.size];
    [_settings addChild:_sound];
    
    // Add Music Label
    SKLabelNode* musicLabel = [SKLabelNode labelNodeWithFontNamed:@"Oswald-Bold"];
    musicLabel.fontColor = [SKColor whiteColor];
    musicLabel.fontSize = 30;
    musicLabel.text = @"Music";
    musicLabel.position = CGPointMake(-120, -30);
    [_settings addChild:musicLabel];
    
    // Add Sounds scrollbar
    _musicScrollBar = [SKSpriteNode spriteNodeWithTexture:[_graphics textureNamed:@"settings-scrollbar"]];
    _musicScrollBar.position = CGPointMake(musicLabel.position.x + 160, musicLabel.position.y + 10);
    [_settings addChild:_musicScrollBar];
    
    // Add Sounds slider
    _musicSlider = [SKSpriteNode spriteNodeWithTexture:[_graphics textureNamed:@"settings-slider"]];
    _musicSlider.name = @"music";
    _musicSlider.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:_musicSlider.size];
    _musicSlider.position = CGPointMake((_audioPlayer.volume * 186) - 93, 0);
    [_musicScrollBar addChild:_musicSlider];
    
    // Okay button
    SKSpriteNode* okBtn = [SKSpriteNode spriteNodeWithTexture:[_graphics textureNamed:@"btn-ok-settings"]];
    okBtn.position = CGPointMake(0, _musicScrollBar.position.y - 100);
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
