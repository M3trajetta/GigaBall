//
//  GameCenterManager.m
//  Brick Breaker
//
//  Created by Tantawy Mohammed on 29/4/19.
//  Copyright © 2019 Tantawy Mohammed. All rights reserved.
//

#import "AppDelegate.h"
#import "GameCenterManager.h"
#import <GameKit/GameKit.h>
#import <Foundation/Foundation.h>
#define LEADERBOARD_ID @"gigaball.highscore"
#define ACHIEVEMENT_FIRST_ID @"first_game"
#define ACHIEVEMENT_NOVICE_ID @"novice_player"
#define ACHIEVEMENT_INT_ID @"intermediate_player"
#define ACHIEVEMENT_EXPERT_ID @"expert_player"

@interface GameCenterManager()
@property (nonatomic, strong) UIViewController *presentationController;
@end

@implementation GameCenterManager

+ (instancetype)sharedManager {
    static GameCenterManager *sharedManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[GameCenterManager alloc] init];
    });
    return sharedManager;
}

- (id)init{
    self = [super init];
    if (self) {
        [self authenticatePlayer];
        AppDelegate *del = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        self.presentationController = del.window.rootViewController;
    }
    return self;
}

- (void)authenticatePlayer {
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    
    [localPlayer setAuthenticateHandler:
     ^(UIViewController *viewController, NSError *error) {
         if (viewController != nil) {
             [self.presentationController presentViewController:viewController animated:YES completion:nil];
         } else if ([GKLocalPlayer localPlayer].authenticated) {
             NSLog(@"Player successfully authenticated");
             NSLog(@"Welcome, %@", [GKLocalPlayer localPlayer].alias);
         } else if (error) {
             NSLog(@"Game Center authentication error: %@", error);
         }
     }];
}

- (void)showLeaderboard{
    GKGameCenterViewController *gcViewController = [[GKGameCenterViewController alloc] init];
    gcViewController.gameCenterDelegate = self;
    gcViewController.viewState = GKGameCenterViewControllerStateLeaderboards;
    gcViewController.leaderboardIdentifier = LEADERBOARD_ID;
    [self.presentationController presentViewController:gcViewController animated:YES completion:nil];
}

- (void)reportScore:(NSInteger)score {
    GKScore *gScore = [[GKScore alloc] initWithLeaderboardIdentifier:LEADERBOARD_ID];
    gScore.value = score;
    gScore.context = 0;
    
    [GKScore reportScores:@[gScore] withCompletionHandler:^(NSError *error) {
        if (!error) {
            NSLog(@"Score reported successfully!");
            
            // score reported, so lets see if it
            // unlocked any achievements
            NSMutableArray *achievements = [[NSMutableArray alloc] init];
            
            // if the player hit an achievement threshold,
            // create the achievement using the ID and add
            // it to the array
            if(score >= 100) {
                GKAchievement *noviceAchievement = [[GKAchievement alloc] initWithIdentifier:ACHIEVEMENT_NOVICE_ID];
                noviceAchievement.percentComplete = 100;
                [achievements addObject:noviceAchievement];
            }
//
            if(score >= 10000) {
                GKAchievement *intAchievement = [[GKAchievement alloc] initWithIdentifier:ACHIEVEMENT_INT_ID];
                intAchievement.percentComplete = 100;
                [achievements addObject:intAchievement];
            }
//
//            if(score >= 200000) {
//                GKAchievement *expertAchievement = [[GKAchievement alloc] initWithIdentifier:ACHIEVEMENT_EXPERT_ID];
//                expertAchievement.percentComplete = 100;
//                [achievements addObject:expertAchievement];
//            }
            
            // tell the Game Center to mark
            // the array of achievements as completed
            [GKAchievement reportAchievements:achievements withCompletionHandler:^(NSError *error) {
                if (error != nil) {
                    NSLog(@"%@", [error localizedDescription]);
                }
            }];
        }
        else {
            NSLog(@"Unable to report score");
        }
    }];
}

- (void)gameCenterViewControllerDidFinish:
(GKGameCenterViewController *)gameCenterViewController {
    [gameCenterViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
