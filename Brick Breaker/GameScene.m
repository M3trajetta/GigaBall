//
//  GameScene.m
//  Brick Breaker
//
//  Created by Tantawy Mohammed on 8/4/19.
//  Copyright © 2019 Tantawy Mohammed. All rights reserved.
//

#import "GameScene.h"
#import "Brick.h"
#import "Ball.h"
#import "Paddle.h"
#import "Menu.h"
#import "Constants.h"
#import "Epilogue.h"
#import "AudioPlayer.h"
#import "GameCenterManager.h"

static const int POWERUPS = 13;

@implementation GameScene {
    Ball* _ball;
    Paddle* _paddle;
    Menu* _menu;
    AudioPlayer* _player;
    AVAudioPlayer* _audioPlayer;
    SKSpriteNode* _pause;
    SKSpriteNode* _powerUp;
    SKSpriteNode* _pauseMenu;
    SKSpriteNode* _background;
    SKSpriteNode* _shield;
    SKSpriteNode* _paddleControl;
    SKSpriteNode* _sound;
    SKSpriteNode* _musicSlider;
    SKSpriteNode* _musicScrollBar;
    SKNode* _settings;
    SKNode* _brickLayer;
    CGPoint _touchLocation;
    CGPoint _paddlePosition;
    CGPoint _touchLocationMusic;
    CGPoint _touchLocationSound;
    BOOL _ballReleased;
    BOOL _positioningBall;
    BOOL _canShoot;
    BOOL _gameOver;
    BOOL _menuCreated;
    BOOL _shieldCreated;
    BOOL _magnetOn;
    BOOL _ballIsOnPaddle;
    BOOL _fastBall;
    BOOL _slowBall;
    BOOL _soundOn;
    NSArray* _hearts;
    SKLabelNode* _levelDisplay;
    SKLabelNode* _scoreDisplay;
    SKLabelNode* _timeDisplay;
    SKTextureAtlas* _graphics;
    SKAction* _paddleAnimation;
    SKAction* _brickSmashSound;
    SKAction* _ballBounceSound;
    SKAction* _paddleBounceSound;
    SKAction* _levelUpSound;
    SKAction* _loseLifeSound;
    float _multiplier;
    NSTimer* _timer;
    NSUserDefaults* _user;
    int _spacing;
    int _smallSpace;
    int _addSizeToFont;
}

static const int MIN_SPEED_BALL = 200;
static const int MAX_SPEED_BALL = 800;
CGFloat BALL_SPEED = 400;

- (instancetype)initWithSize:(CGSize)size andLevel:(int)level{
    if(self = [super initWithSize:size]){
        // Stop gravity
        self.physicsWorld.gravity = CGVectorMake(0.0, 0.0);
        
        // Get atlas
        _graphics = [SKTextureAtlas atlasNamed:@"Graphics"];
        
        _user = [NSUserDefaults standardUserDefaults];
        
        CGFloat screenWidth = size.width;
        if(screenWidth <= 400){
            NSLog(@"LESS THAN 400");
            _spacing = 10;
            _smallSpace = 5;
            _addSizeToFont = 5;
            
        } else if(screenWidth > 500 && UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation)){
            _spacing = 50;
            _smallSpace = 15;
            _addSizeToFont = 20;
        } else {
            _spacing = 0;
            _smallSpace = 0;
            _addSizeToFont = 0;
        }
        
        // Add bg
        _background = [SKSpriteNode spriteNodeWithTexture:[_graphics textureNamed:@"bg-game"]];
        _background.size = self.frame.size;
        _background.position = CGPointMake(self.frame.size.width * 0.5, self.frame.size.height * 0.5);
        [self addChild:_background];
        
        // Get notify when there is contact
        self.physicsWorld.contactDelegate = self;
        
        // Create the edge
        self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:CGRectMake(0, -140, size.width, size.height + 100)];
        self.physicsBody.categoryBitMask = edgeCategory;
        
        // Add HUD
        SKSpriteNode* bar = [SKSpriteNode spriteNodeWithTexture:[_graphics textureNamed:@"bg-bar"]];
        bar.size = CGSizeMake(size.width, 40);
        bar.position = CGPointMake(0, size.height);
        bar.anchorPoint = CGPointMake(0, 1);
        [self addChild: bar];
        
        // Set up lives
        _hearts = @[[SKSpriteNode spriteNodeWithTexture:[_graphics textureNamed:@"heart-full"]],
                    [SKSpriteNode spriteNodeWithTexture:[_graphics textureNamed:@"heart-full"]]];
        for (NSUInteger i=0; i < _hearts.count; i++) {
            SKSpriteNode* heart = (SKSpriteNode*)[_hearts objectAtIndex:i];
            heart.position = CGPointMake(20 + 29 * i + _smallSpace * i, self.size.height - 20);
            [self addChild:heart];
        }
        
        // Score
        _scoreDisplay = [SKLabelNode labelNodeWithFontNamed:@"Oswald-Bold"];
        _scoreDisplay.text = @"SCORE 0";
        _scoreDisplay.fontColor = [SKColor whiteColor];
        _scoreDisplay.fontSize = 20;
        _scoreDisplay.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
        _scoreDisplay.verticalAlignmentMode = SKLabelVerticalAlignmentModeTop;
        _scoreDisplay.position = CGPointMake(self.size.width * 0.5 - 50, -10);
        [bar addChild:_scoreDisplay];
        
        // Set up Pause Button
        _pause = [SKSpriteNode spriteNodeWithTexture:[_graphics textureNamed:@"btn-pause"]];
        //_pause.size = CGSizeMake(_pause.size.width * 1.3, _pause.size.height * 1.3);
        _pause.position = CGPointMake(self.size.width - 30, -30);
        [bar addChild:_pause];
        
        // Adding the Bottom
        CGRect bottomRect = CGRectMake(self.frame.origin.x, self.frame.origin.y-5, self.frame.size.width, 5);
        SKNode* bottom = [SKNode node];
        bottom.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:bottomRect];
        [self addChild:bottom];
        bottom.physicsBody.categoryBitMask = bottomCategory;
        bottom.physicsBody.dynamic = NO;
        
        // Set up sounds
        _ballBounceSound = [SKAction playSoundFileNamed:@"BallBounce" waitForCompletion:NO];
        _brickSmashSound = [SKAction playSoundFileNamed:@"BrickSmash" waitForCompletion:NO];
        _paddleBounceSound = [SKAction playSoundFileNamed:@"PaddleBounce" waitForCompletion:NO];
        _levelUpSound = [SKAction playSoundFileNamed:@"LevelUp" waitForCompletion:NO];
        _loseLifeSound = [SKAction playSoundFileNamed:@"LoseLife" waitForCompletion:NO];
        
        // Setting up the brick layer
        _brickLayer = [[SKNode node]init];
        _brickLayer.position = CGPointMake(0, self.size.height - 40);
        [self addChild:_brickLayer];
        
        // Get power animations
        _powerAnimations = [[NSMutableArray alloc] init];
        NSString* powersAnimPath = [[NSBundle mainBundle] pathForResource:@"Powers" ofType:@"plist"];
        NSArray* animations = [NSArray arrayWithContentsOfFile:powersAnimPath];
        for (int i=0; i < animations.count; i++) {
            [self.powerAnimations addObject:[self animationFromArray:[animations objectAtIndex:i] withDuration:0.4]];
        }
        
        if(level && level > 0){
            self.currentLevel = level;
        } else {
            self.currentLevel = 1;
        }
        
        self.lives = 2;
        _multiplier = 1;
        _gameOver = YES;
        _menuCreated = NO;
        _shieldCreated = NO;
        _magnetOn = NO;
        _ballIsOnPaddle = NO;
        
        // Load sound setting
        NSString* soundOn = [_user stringForKey:@"sounds-on"];
        float volume = [[_user stringForKey:@"volume"] floatValue];
        NSLog(@"VOLUME: %f", volume);
        
        // Add Sounds on / off button
        if(soundOn) _soundOn = [soundOn boolValue];
        
        if(!_player.isPlaying) {
            _player = [[AudioPlayer alloc]init:@"GameLoop"];
            if(volume) _player.audioPlayer.volume = volume;
            else _player.audioPlayer.volume = 0.5;
            [_player.audioPlayer play];
            _player.isPlaying = YES;
        }
        [self loadLevel:self.currentLevel];
        [self newBall];
        NSLog(@"Total Score: %d", self.totalScore);
    }
    return self;
}

-(void)newBall{
    // Remove other balls if any
    [self enumerateChildNodesWithName:@"ball" usingBlock:^(SKNode * _Nonnull node, BOOL * _Nonnull stop) {
        [node removeFromParent];
    }];
    [self enumerateChildNodesWithName:@"paddle" usingBlock:^(SKNode * _Nonnull node, BOOL * _Nonnull stop) {
        [node removeFromParent];
    }];
    [self enumerateChildNodesWithName:@"bangLeft" usingBlock:^(SKNode * _Nonnull node, BOOL * _Nonnull stop) {
        [node removeFromParent];
    }];
    [self enumerateChildNodesWithName:@"bangRight" usingBlock:^(SKNode * _Nonnull node, BOOL * _Nonnull stop) {
        [node removeFromParent];
    }];
    for (int i = 0; i < POWERUPS; i++) {
        [_brickLayer enumerateChildNodesWithName:[NSString stringWithFormat:@"%d",i] usingBlock:^(SKNode * _Nonnull node, BOOL * _Nonnull stop) {
            [[self->_brickLayer childNodeWithName:node.name] removeFromParent];
        }];
    }
    
    if(_pauseMenu){
        [_pauseMenu removeFromParent];
    }
    
    // Create paddle from class
    _paddle = [[Paddle alloc]initWithType:1];
    _paddle.canShoot = NO;
    _canShoot = NO;
    _gameOver = NO;
    _multiplier = 1;
    _paddle.position = CGPointMake(self.size.width * 0.5, 90);
    [self addChild:_paddle];
    
    // Control to position the ball
    _paddleControl = [SKSpriteNode spriteNodeWithTexture:[_graphics textureNamed:@"paddle-control"]];
    _paddleControl.position = CGPointMake(0, -40);
    _paddleControl.alpha = 0.5;
    [_paddle addChild:_paddleControl];

    // Position ball from class
    _ball = [[Ball alloc]initWithType:1];
    _ball.position = CGPointMake(0, _paddle.size.height);
    BALL_SPEED = 400;
    _ball.physicsBody.velocity = CGVectorMake(_ball.physicsBody.velocity.dx * BALL_SPEED, _ball.physicsBody.velocity.dy * BALL_SPEED);
    [_paddle addChild: _ball];
    _ballReleased = NO;
}

-(void)shootBangPower{
    SKSpriteNode* bangLeft = [SKSpriteNode spriteNodeWithTexture:[_graphics textureNamed:@"laser"]];
    bangLeft.position = CGPointMake(_paddle.position.x - _paddle.size.width * 0.5, _paddle.position.y + 5);
    bangLeft.name = @"bangLeft";
    [self addChild:bangLeft];
    bangLeft.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:bangLeft.size];
    bangLeft.physicsBody.friction = 0;
    bangLeft.physicsBody.linearDamping = 0;
    bangLeft.physicsBody.restitution = 1;
    bangLeft.physicsBody.velocity = CGVectorMake(0, 500);
    bangLeft.physicsBody.categoryBitMask = bangCategory;
    bangLeft.physicsBody.contactTestBitMask = brickCategory;
    bangLeft.physicsBody.collisionBitMask = brickCategory;
    
    SKSpriteNode* bangRight = [SKSpriteNode spriteNodeWithTexture:[_graphics textureNamed:@"laser"]];
    bangRight.position = CGPointMake(_paddle.position.x + _paddle.size.width * 0.5, _paddle.position.y + 5);
    bangRight.name = @"bangRight";
    [self addChild:bangRight];
    bangRight.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:bangRight.size];
    bangRight.physicsBody.friction = 0;
    bangRight.physicsBody.linearDamping = 0;
    bangRight.physicsBody.restitution = 1;
    bangRight.physicsBody.velocity = CGVectorMake(0, 500);
    bangRight.physicsBody.categoryBitMask = bangCategory;
    bangRight.physicsBody.contactTestBitMask = brickCategory;
    bangRight.physicsBody.collisionBitMask = brickCategory;
}

-(SKSpriteNode*)createBallWithLocation:(CGPoint)position andVelocity:(CGVector)velocity andType:(int)type{
    Ball* _ball = [[Ball alloc] initWithType:type];
    _ball.position = position;
    _ball.physicsBody.velocity = velocity;
    [self addChild:_ball];
    if (_ball.type == 2) {
        NSString* trailPath = [[NSBundle mainBundle] pathForResource:@"BallTrail" ofType:@"sks"];
        SKEmitterNode* ballTrail = [NSKeyedUnarchiver unarchiveObjectWithFile:trailPath];
        ballTrail.targetNode = _brickLayer;
        [self addChild: ballTrail];
        _ball.trail = ballTrail;
        [_ball updateTrail];
    }
    return _ball;
}

-(void)multiBallPower:(CGPoint)position andType:(int)type{
    CGVector direction;
    if(arc4random_uniform(2) == 0){
        direction = CGVectorMake(cosf(M_PI_4), sinf(M_PI_4));
    } else {
        direction = CGVectorMake(cosf(M_PI * 0.75), sinf(M_PI * 0.75));
    }
    [self createBallWithLocation:position andVelocity:CGVectorMake(direction.dx * BALL_SPEED, direction.dy * BALL_SPEED) andType:type];
}

- (void)setLives:(int)lives{
    _lives = lives;
    for(NSUInteger i=0; i<_hearts.count; i++){
        SKSpriteNode* heart = (SKSpriteNode*)[_hearts objectAtIndex:i];
        if (lives > i) {
            heart.texture = [SKTexture textureWithImageNamed:@"heart-full"];
        } else {
            heart.texture = [SKTexture textureWithImageNamed:@"heart-empty"];
        }
    }
}

- (void)setCurrentLevel:(int)currentLevel{
    _currentLevel = currentLevel;
    _levelDisplay.text = [NSString stringWithFormat:@"LEVEL %d", self.currentLevel];
}

- (void)setScore:(int)score{
    _score = score;
    _scoreDisplay.text = [NSString stringWithFormat:@"SCORE %d", self.score];
}

- (void)setTotalScore:(int)totalScore{
    _totalScore = totalScore;
}

- (void)setGamePaused:(BOOL)gamePaused{
    if(!_gameOver){
        _gamePaused = gamePaused;
        self.paused = gamePaused;
        if(self.paused){
            [_timer invalidate];
        } else {
            [_timer invalidate];
            _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTime) userInfo:nil repeats:YES];
        }
    }
}

-(void)loadLevel:(int)levelNumber{
    [_timer invalidate];
    self.time = 0;
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTime) userInfo:nil repeats:YES];
    [_brickLayer removeAllChildren];
    
    int row = 0;
    int col = 0;
    NSString* path = [[NSBundle mainBundle]pathForResource:@"Levels" ofType:@"plist"];
    NSDictionary* levels = [[NSDictionary alloc] initWithContentsOfFile:path];
    NSArray* level = [levels objectForKey:[NSString stringWithFormat:@"%d", levelNumber]];
    for (NSArray* rowPL in level) {
        col = 0;
        for (NSDictionary* colPL in rowPL) {
            int brickType = [colPL[@"brickType"] intValue];
            int powerUp = [colPL[@"powerUp"] intValue];
            int hit = [colPL[@"hit"] intValue];
            if(brickType > 0){
                Brick* brick = [[Brick alloc]initWithType:(BrickType)brickType];
                if(brick){
                    if(_smallSpace > 5){
                        brick.size = CGSizeMake(brick.size.width * 1.2, brick.size.height * 1.2);
                        brick.position = CGPointMake(30 + (brick.size.width * 0.5) + (brick.size.width + 5) * col,
                                                     -(10 + (brick.size.height * 0.5) + (brick.size.height + 5) * row));
                    } else{
                        brick.position = CGPointMake(10 + (brick.size.width * 0.5 - _smallSpace) + (brick.size.width + 3 - _smallSpace) * col,
                                                     -(10 + (brick.size.height * 0.5 - _smallSpace) + (brick.size.height + 3 - _smallSpace) * row));
                    }
                    brick.powerUp = powerUp;
                    brick.hitBrick = hit;
                    [_brickLayer addChild: brick];
                }
            }
            col++;
        }
        row++;
    }
}

-(void) updateTime {
    self.time++;
    if(self.time == 60){
        // update timer to show minutes
    }
    _timeDisplay.text = [NSString stringWithFormat:@"TIME %d", self.time];
}

- (void)didBeginContact:(SKPhysicsContact *)contact{
    SKPhysicsBody* firstBody;
    SKPhysicsBody* secondBody;
    
    // Set up the lowest bitmask to be first body
    if(contact.bodyA.categoryBitMask > contact.bodyB.categoryBitMask){
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
    } else {
        firstBody = contact.bodyA;
        secondBody = contact.bodyB;
    }
    
    // Contact between ball and edge
    if(firstBody.categoryBitMask == ballCategory && secondBody.categoryBitMask == edgeCategory){
        if(_soundOn) [self runAction:_ballBounceSound];
    }
    
    // Contact between ball and paddle
    if(firstBody.categoryBitMask == ballCategory && secondBody.categoryBitMask == paddleCategory){
        if(_magnetOn){
            _ballIsOnPaddle = YES;
            _magnetOn = NO;
        }
            
        if(firstBody.node.position.y > secondBody.node.position.y){
            // Get contact point on paddle coordinates
            CGPoint pointInPaddle = [secondBody.node convertPoint:contact.contactPoint fromNode:self];
            
            //Get contact position as percentage of paddle width
            CGFloat x = (pointInPaddle.x + secondBody.node.frame.size.width * 0.5) / secondBody.node.frame.size.width;
            
            // Cap percentage and flip that
            CGFloat multiplier = 1 - fmaxf(fminf(x, 1.0), 0.0);
            
            // Calculate angle based on ball position on paddle
            CGFloat angle = (M_PI_2 * multiplier) + M_PI_4;
            
            // Convert angle to vector
            CGVector direction = CGVectorMake(cosf(angle), sinf(angle));
            
            if(_ballIsOnPaddle){
                BallType type = ((Ball*)firstBody.node).type;
                [self enumerateChildNodesWithName:@"ball" usingBlock:^(SKNode * _Nonnull node, BOOL * _Nonnull stop) {
                    [node removeFromParent];
                }];
                _ball = [[Ball alloc]initWithType:type];
                _ball.position = CGPointMake(0, _paddle.size.height);
                _ball.physicsBody.velocity = CGVectorMake(_ball.physicsBody.velocity.dx * BALL_SPEED, _ball.physicsBody.velocity.dy * BALL_SPEED);
                [_paddle addChild: _ball];
                _ballReleased = NO;
                _positioningBall = YES;
            } else {
                // Set ball velocity after contact
                firstBody.velocity = CGVectorMake(direction.dx * BALL_SPEED, direction.dy * BALL_SPEED);
            }
        }
        if(_soundOn) [self runAction:_paddleBounceSound];
    }
    
    // Contact between ball and brick
    if(firstBody.categoryBitMask == ballCategory && secondBody.categoryBitMask == brickCategory){
        [self updateScore:100];
        if(((Brick*)secondBody.node).hitBrick){
            ((Brick*)secondBody.node).hitBrick--;
        }
        if([secondBody.node respondsToSelector:@selector(hit)]){
            [secondBody.node performSelector:@selector(hit)];
            if(_soundOn) [self runAction:_brickSmashSound];
            if(((Brick*)secondBody.node).powerUp > 0 && ((Brick*)secondBody.node).hitBrick == 0){
                [self dropPowerUp:secondBody.node.position andPowerUp:((Brick*)secondBody.node).powerUp];
            }
        }
        if(_soundOn) [self runAction:_ballBounceSound];
    }
    
    // Contact between paddle and powerUp
    if(firstBody.categoryBitMask == paddleCategory && secondBody.categoryBitMask == powerUpCategory){
        CGPoint position = firstBody.node.position;
        // Just for collecting the powerup add score
        [self updateScore:100];
        if([secondBody.node.name isEqualToString:@"1"]){
            // Plus one life if lives less than 2
            if(self.lives == 2){
                [self updateScore:500];
            }
            else{
                self.lives++;
            }
        }
        if([secondBody.node.name isEqualToString:@"2"]){
            // Shield
            [self shieldPower];
        }
        if([secondBody.node.name isEqualToString:@"3"]){
            // Grow power
            [self growPaddlePower:position];
        }
        if([secondBody.node.name isEqualToString:@"4"]){
            // Small paddle
            [self shrinkPaddlePower:position];
        }
        if([secondBody.node.name isEqualToString:@"5"]){
            // Multiball
            [self multiBallPower:[_brickLayer convertPoint:secondBody.node.position toNode:self] andType:_ball.type];
        }
        if([secondBody.node.name isEqualToString:@"6"]){
            // Score multiplier gives 2X score for everything, but lasts with the ball
            _multiplier = 2;
        }
        if([secondBody.node.name isEqualToString:@"7"]){
            // Fast Power
            BALL_SPEED = MAX_SPEED_BALL;
        }
        if([secondBody.node.name isEqualToString:@"8"]){
            // Slow Power
            BALL_SPEED = MIN_SPEED_BALL;
        }
        if([secondBody.node.name isEqualToString:@"9"]){
            // Laser gun
            [self bangPower:position];
        }
        
        if([secondBody.node.name isEqualToString:@"10"]){
            // Energy Ball
            [self enumerateChildNodesWithName:@"ball" usingBlock:^(SKNode * _Nonnull node, BOOL * _Nonnull stop) {
                CGPoint ballPos = node.position;
                CGVector ballVel = node.physicsBody.velocity;
                [node removeFromParent];
                [self createBallWithLocation:ballPos andVelocity:ballVel andType:Energy];
            }];
        }
        if([secondBody.node.name isEqualToString:@"11"]){
           // Random Power
        }
        if([secondBody.node.name isEqualToString:@"12"]){
            // Magnet Power
            _magnetOn = YES;
        }
        
        [secondBody.node removeFromParent];
    }
    
    // Projectile destroy brick
    if(firstBody.categoryBitMask == brickCategory && secondBody.categoryBitMask == bangCategory){
        [self updateScore:250];
        if([firstBody.node respondsToSelector:@selector(hit)]){
            [firstBody.node performSelector:@selector(hit)];
            if(((Brick*)firstBody.node).powerUp > 0){
                [self dropPowerUp:firstBody.node.position andPowerUp:((Brick*)firstBody.node).powerUp];
            }
        }
        [firstBody.node removeFromParent];
        [secondBody.node removeFromParent];
    }
    
    // Contact between edge and powerup
    if(firstBody.categoryBitMask == edgeCategory && secondBody.categoryBitMask == powerUpCategory){
        if(_soundOn) [self runAction:_ballBounceSound];
    }
    
    // Contact between ball and bottom of screen
    if (firstBody.categoryBitMask == ballCategory && secondBody.categoryBitMask == bottomCategory) {
        // For some reason this function is called twice
        if(firstBody.node){
            // TODO: Bug - Multiball takes life
            self.lives--;
        }
        [firstBody.node removeFromParent];
        if(self.lives <= 0) self->_gameOver = YES;
    }
    
    // Contact between ball and shield
    if ((firstBody.categoryBitMask & ballCategory) !=0 && (secondBody.categoryBitMask & shieldCategory) !=0) {
        NSLog(@"Contact: SHIELD");
    }
    
    // Contact between powerup and bottom
    if (firstBody.categoryBitMask == powerUpCategory && secondBody.categoryBitMask == bottomCategory) {
        [firstBody.node removeFromParent];
    }
}

-(void)dropPowerUp:(CGPoint)position andPowerUp:(int)powerUp{
    NSString* powerName = @"";
    switch (powerUp) {
        case 1:
            powerName = @"power-plus-one-life-1";
            break;
        case 2:
            powerName = @"power-shield-1";
            break;
        case 3:
            // Paddle Grow
            powerName = @"power-paddle-grow-1";
            break;
        case 4:
            // Paddle Shrink
            powerName = @"power-paddle-shrink-1";
            break;
        case 5:
            // Multiball
            powerName = @"power-multiball-1";
            break;
        case 6:
            // Multiplier of score
            powerName = @"power-multiplier-1";
            break;
        case 7:
            // Speed up ball
            powerName = @"power-ball-speed-up-1";
            break;
        case 8:
            // Slow down ball
            powerName = @"power-ball-speed-down-1";
            break;
        case 9:
            // Laser Gun
            powerName = @"power-laser-1";
            break;
        case 10:
            // Energy Ball
            powerName = @"power-ball-energy-1";
            break;
        case 11:
            // Random
            powerName = @"power-random-1";
            break;
        case 12:
            // Magnet
            powerName = @"power-magnet-1";
            break;
        default:
            break;
    }
    
    if([powerName isEqualToString:@""]){
        // Do nothing
        NSLog(@"Power undefined");
    }   else {
        _powerUp = [SKSpriteNode spriteNodeWithTexture:[_graphics textureNamed:powerName]];
        _powerUp.position = position;
        _powerUp.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:_powerUp.size.width * 0.5];
        _powerUp.name = [NSString stringWithFormat:@"%d", powerUp];
        _powerUp.physicsBody.friction = 0;
        _powerUp.physicsBody.linearDamping = 0;
        _powerUp.physicsBody.restitution = 1;
        _powerUp.physicsBody.categoryBitMask = powerUpCategory;
        _powerUp.physicsBody.collisionBitMask = edgeCategory;
        _powerUp.physicsBody.contactTestBitMask = paddleCategory | bottomCategory;
        
        [_powerUp runAction:[self.powerAnimations objectAtIndex:powerUp]];
        
        CGVector direction;
        if(arc4random_uniform(2) == 0){
            direction = CGVectorMake(cosf(M_PI_4), sinf(M_PI_4));
        } else {
            direction = CGVectorMake(cosf(M_PI * 0.75), sinf(M_PI * 0.75));
        }
        _powerUp.physicsBody.velocity = CGVectorMake(direction.dx * 200, direction.dy * 200);
       [_brickLayer addChild:_powerUp];
    }
}

-(SKAction*)animationFromArray:(NSArray*)textureNames withDuration:(CGFloat)duration{
    // Create array to hold textures
    NSMutableArray* frames = [[NSMutableArray alloc] init];
    
    // Loop through textureNames and load textures
    for (NSString* textureName in textureNames) {
        [frames addObject:[_graphics textureNamed:textureName]];
    }
    
    // Calculate time per frame
    CGFloat frameTime = duration / (CGFloat)frames.count;
    
    // Create and return animation
    return [SKAction repeatActionForever:[SKAction animateWithTextures:frames timePerFrame:frameTime resize:NO restore:NO]];
}

-(void)showMenu{
    _background.texture = [SKTexture textureWithImageNamed:@"bg-game-dark"];
    _pauseMenu = [SKSpriteNode spriteNodeWithTexture:[_graphics textureNamed:@"pause-menu"]];
    _pauseMenu.name = @"_pauseMenu";
    _pauseMenu.position = CGPointMake(self.size.width * 0.5, self.size.height * 0.5);
    [self addChild:_pauseMenu];
    
    _levelDisplay = [SKLabelNode labelNodeWithFontNamed:@"Oswald-Bold"];
    _levelDisplay.fontColor = [SKColor whiteColor];
    _levelDisplay.text = [NSString stringWithFormat:@"Level %d", self.currentLevel];
    _levelDisplay.fontSize = 30 + _addSizeToFont;
    _levelDisplay.position = CGPointMake(-60 - _spacing, 60);
    [_pauseMenu addChild:_levelDisplay];
    
    // Time
    _timeDisplay = [SKLabelNode labelNodeWithFontNamed:@"Oswald-Bold"];
    _timeDisplay.text = [NSString stringWithFormat:@"Time %ds", self.time];
    _timeDisplay.fontColor = [SKColor whiteColor];
    _timeDisplay.fontSize = 30 + _addSizeToFont;
    _timeDisplay.position = CGPointMake(50 + _spacing, 60);
    [_pauseMenu addChild:_timeDisplay];
    
    SKSpriteNode* btnHome = [SKSpriteNode spriteNodeWithTexture:[_graphics textureNamed:@"btn-home"]];
    btnHome.name = @"home";
    btnHome.position = CGPointMake(-75 - _spacing, -5 - _spacing);
    [_pauseMenu addChild:btnHome];
    
    SKSpriteNode* btnRestart = [SKSpriteNode spriteNodeWithTexture:[_graphics textureNamed:@"btn-restart"]];
    btnRestart.name = @"restart";
    btnRestart.position = CGPointMake(0, -5 - _spacing);
    [_pauseMenu addChild:btnRestart];
    
    SKSpriteNode* btnSettings = [SKSpriteNode spriteNodeWithTexture:[_graphics textureNamed:@"btn-settings"]];
    btnSettings.name = @"settings";
    btnSettings.position = CGPointMake(75 + _spacing, -5 - _spacing);
    [_pauseMenu addChild:btnSettings];
    
    SKSpriteNode* btnContinue = [SKSpriteNode spriteNodeWithTexture:[_graphics textureNamed:@"btn-continue"]];
    btnContinue.name = @"continue";
    btnContinue.position = CGPointMake(0, -100 - _spacing * 2 + _smallSpace);
    [_pauseMenu addChild:btnContinue];
    
    _pauseMenu.zPosition = 1;
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches) {
        if(!_ballReleased){
            _positioningBall = YES;
        }
        _touchLocation = [touch locationInNode:self];
        if(_canShoot){
            [self shootBangPower];
        }
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
        if(!self.paused){
            // Calculate how far the touch moved
            CGFloat xMovement = [touch locationInNode:self].x - _touchLocation.x;
        
            // Move paddle distance of touch
            _paddle.position = CGPointMake(_paddle.position.x + xMovement, _paddle.position.y);
            CGFloat paddleMinX = -_paddle.size.width * 0.25 ;
            CGFloat paddleMaxX = self.size.width + (_paddle.size.width * 0.25);
        
            if(_positioningBall){
                paddleMinX = _paddle.size.width * 0.5;
                paddleMaxX = self.size.width - _paddle.size.width * 0.5;
            }
        
            // Cap paddle's position so it remains on the screen
            if(_paddle.position.x < paddleMinX) { _paddle.position = CGPointMake(paddleMinX, _paddle.position.y); }
            if(_paddle.position.x > paddleMaxX) { _paddle.position = CGPointMake(paddleMaxX, _paddle.position.y); }
            _touchLocation = [touch locationInNode:self];
        }
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
        if(_positioningBall){
            _positioningBall = NO;
            _ballReleased = YES;
            _ballIsOnPaddle = NO;
            [_paddle removeAllChildren];
            [self createBallWithLocation:CGPointMake(_paddle.position.x, _paddle.position.y + _paddle.size.height) andVelocity:CGVectorMake(0, BALL_SPEED) andType:_ball.type];
        }
        if(!self.gamePaused){
            if([_pause containsPoint:[t locationInNode:_pause.parent]]){
                self.gamePaused = YES;
                [self showMenu];
            }
        } else {
            _pauseMenu = (SKSpriteNode*)[self childNodeWithName: @"_pauseMenu"];
            SKNode* node = [self nodeAtPoint: [t locationInNode:self]];
            if([node.name isEqualToString:@"home"]){
                // Go to main screen
                SKScene *homeScene = [[Menu alloc]initWithSize:self.size];
                _player.isPlaying = NO;
                [_player.audioPlayer stop];
                [self.view presentScene:homeScene];
            }
            if([node.name isEqualToString:@"restart"]){
                // Restart level
                _background.texture = [SKTexture textureWithImageNamed:@"bg-game"];
                // TODO: Bug found - fix gameover situation if ball not released
                NSLog(@"Restart");
                self.score = 0;
                [self loadLevel:self.currentLevel];
                [self newBall];
                self.gamePaused = NO;
                self.time = 0;
            }
            if([node.name isEqualToString:@"settings"]){
                // Show settings menu
                NSLog(@"Settings");
                [_pauseMenu removeFromParent];
                [self showSettings];
            }
            if([node.name isEqualToString:@"continue"]){
                // Continue Game
                _background.texture = [SKTexture textureWithImageNamed:@"bg-game"];
                [_pauseMenu removeFromParent];
                self.gamePaused = NO;
            }
            if([node.name isEqualToString:@"sound"]){
                _soundOn = !_soundOn;
                [_user setObject:[NSString stringWithFormat:@"%d",_soundOn] forKey:@"sounds-on"];
                if (_soundOn) {
                    _sound.texture = [SKTexture textureWithImageNamed:@"sound-on"];
                } else {
                    _sound.texture = [SKTexture textureWithImageNamed:@"sound-off"];
                }
            }
            if([node.name isEqualToString:@"okay"]){
                [_settings removeFromParent];
                [self showMenu];
            }
        }
    }
}

- (void)showSettings{
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
    NSString* soundOn = [_user stringForKey:@"sounds-on"];
    
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
    _musicSlider.position = CGPointMake((_player.audioPlayer.volume * 186) - 93, 0);
    [_musicScrollBar addChild:_musicSlider];
    
    // Okay button
    SKSpriteNode* okBtn = [SKSpriteNode spriteNodeWithTexture:[_graphics textureNamed:@"btn-ok-settings"]];
    okBtn.position = CGPointMake(0, _musicScrollBar.position.y - 100);
    okBtn.name = @"okay";
    [_settings addChild:okBtn];
}

- (void)didSimulatePhysics{
    [self enumerateChildNodesWithName:@"ball" usingBlock:^(SKNode * _Nonnull node, BOOL * _Nonnull stop) {
        if([node respondsToSelector:@selector(updateTrail)]){
            [node performSelector:@selector(updateTrail) withObject:nil afterDelay:0.0];
        }
    }];
}

-(void)update:(CFTimeInterval)currentTime {
    // Called before each frame is rendered
    if (_gamePaused) {
        self.paused = YES;
        [self showMenu];
        _menuCreated = YES;
    }
    else if (!_gamePaused) {
        self.paused = NO;
        if([self isLevelComplete]){
//            self.currentLevel++;
            if(_soundOn) [self runAction:_levelUpSound];
//            [self loadLevel:self.currentLevel];
//            [self newBall];
            // Epilogue screen
            // Save data - score
            [_user setObject:[NSString stringWithFormat:@"%d",self.score] forKey:@"epilogue-score"];
            // Save data - total score
            [_user setObject:[NSString stringWithFormat:@"%d",self.totalScore] forKey:@"epilogue-total-score"];
            // Save data - time
            [_user setObject:[NSString stringWithFormat:@"%d",self.time] forKey:@"epilogue-time"];
            // Save data - lives
            [_user setObject:[NSString stringWithFormat:@"%d",self.lives] forKey:@"epilogue-lives"];
            
            // Save data - current level
            [_user setObject:[NSString stringWithFormat:@"%d",self.currentLevel] forKey:@"epilogue-level"];
            [_player.audioPlayer stop];
            _player.isPlaying = NO;
            _totalScore += self.score;
            SKScene *epilogue = [[Epilogue alloc]initWithSize:self.size];
            [self.view presentScene:epilogue];
        } else if(_ballReleased && !_positioningBall && ![self childNodeWithName:@"ball"]){
            //[self runAction:_loseLifeSound];
            if(self.lives < 0){
                // Game over
                _gameOver = YES;
                self.currentLevel = 1;
                _totalScore += self.score;
                [[GameCenterManager sharedManager]reportScore: _totalScore];
                [_timer invalidate];
                // Epilogue screen
                // Save data - score
                [_user setObject:[NSString stringWithFormat:@"%d",self.score] forKey:@"epilogue-score"];
                // Save data - time
                [_user setObject:[NSString stringWithFormat:@"%d",self.time] forKey:@"epilogue-time"];
                // Save data - lives
                [_user setObject:[NSString stringWithFormat:@"%d",self.lives] forKey:@"epilogue-lives"];
                
                // Save data - current level
                [_user setObject:[NSString stringWithFormat:@"%d",self.currentLevel] forKey:@"epilogue-level"];
                
                SKScene *epilogue = [[Epilogue alloc]initWithSize:self.size];
                [self.view presentScene:epilogue];
            }
            [self newBall];
        }
    }
}

-(BOOL)isLevelComplete{
    // Look for bricks (non indistructible) are on screen
    for (SKNode* node in _brickLayer.children) {
        if([node isKindOfClass:[Brick class]]){
            if(!((Brick*)node).indistructible){
                return NO;
            }
        }
    }
    // Couldn't find brick searched
    return YES;
}

-(void)updateScore:(int)score{
    self.score += score * _multiplier;
}

-(void)createPaddle:(PaddleType)type andPosition:(CGPoint)position{
    _paddle = [[Paddle alloc]initWithType:type];
    _paddle.position = position;
    _paddle.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:_paddle.size];
    _paddle.physicsBody.categoryBitMask = paddleCategory;
    _paddle.physicsBody.dynamic = NO;
    [self addChild:_paddle];
}

//-------------------- POWERUPS --------------------//

// Through Ball

// Small Paddle
-(void)shrinkPaddlePower:(CGPoint)position{
    // Set up paddle
    [_paddle removeFromParent];
    if(_canShoot){
        [self createPaddle:SmallBang andPosition:position];
    } else {
        [self createPaddle:Small andPosition:position];
    }
}

// Big Paddle
-(void)growPaddlePower:(CGPoint)position{
    // Set up paddle
    [_paddle removeFromParent];
    if(_canShoot){
        [self createPaddle:BigBang andPosition:position];
    } else {
        [self createPaddle:Big andPosition:position];
    }
}

// Laser
-(void)bangPower:(CGPoint)position{
    NSTimeInterval time;
    if(_canShoot) {
        time = 5;
        [self updateScore:250];
    }
    else time = 3;
    _canShoot = YES;
    PaddleType type = [_paddle getPaddleForLaser];
    [_paddle removeFromParent];
    [self createPaddle:type andPosition:position];
    
    if(_canShoot){
        // Allow shooting for ~time seconds
        [self runAction:[SKAction waitForDuration:time] completion:^{
            self->_canShoot = NO;
            [self getPaddlePosition];
            [self->_paddle removeFromParent];
            [self createPaddle:type-1 andPosition:self->_paddlePosition];
        }];
    }
}

-(void)getPaddlePosition{
    _paddlePosition = _paddle.position;
}

// Shield power

- (void)shieldPower{
    // Check if shield exists
    if(_shieldCreated){
        [self updateScore:250];
    } else {
        _shieldCreated = YES;
        _shield.name = @"shield";
        _shield = [SKSpriteNode spriteNodeWithTexture:[_graphics textureNamed:@"shield"]];
        _shield.position = CGPointMake(self.size.width * 0.5, _paddle.position.y - 30);
        _shield.size = CGSizeMake(_shield.size.width, _shield.size.height);
        _shield.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:_shield.size];
        _shield.physicsBody.dynamic = NO;
        _shield.physicsBody.friction = 0;
        _shield.physicsBody.linearDamping = 0;
        _shield.physicsBody.restitution = 1;
        _shield.physicsBody.categoryBitMask = shieldCategory;
        _shield.physicsBody.collisionBitMask = 0;
        _shield.physicsBody.contactTestBitMask = 0;
        [self addChild:_shield];
        [self runAction:[SKAction waitForDuration:5] completion:^{
            [self->_shield removeFromParent];
            self->_shieldCreated = NO;
        }];
    }
    
}

@end
