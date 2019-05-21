//
//  GameCenterManager.h
//  Brick Breaker
//
//  Created by Tantawy Mohammed on 29/4/19.
//  Copyright © 2019 Tantawy Mohammed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GameCenterManager : NSObject <GKGameCenterControllerDelegate>
+ (instancetype)sharedManager;
- (void)authenticatePlayer;
- (void)showLeaderboard;
- (void)reportScore:(NSInteger)score;
@end

NS_ASSUME_NONNULL_END
