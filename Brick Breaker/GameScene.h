//
//  GameScene.h
//  Brick Breaker
//
//  Created by Tantawy Mohammed on 8/4/19.
//  Copyright © 2019 Tantawy Mohammed. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
@interface GameScene : SKScene <SKPhysicsContactDelegate>
@property (nonatomic) int lives;
@property (nonatomic) int currentLevel;
@property (nonatomic) int score;
@property (nonatomic) int totalScore;
@property (nonatomic) int time;
@property (nonatomic) BOOL gamePaused;
@property (nonatomic) NSMutableArray* powerAnimations;
- (instancetype)initWithSize:(CGSize)size andLevel:(int)level;
@end
