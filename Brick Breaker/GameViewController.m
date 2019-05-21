//
//  GameViewController.m
//  Brick Breaker
//
//  Created by Tantawy Mohammed on 8/4/19.
//  Copyright © 2019 Tantawy Mohammed. All rights reserved.
//

#import "GameViewController.h"
#import "GameCenterManager.h"
#import "GameScene.h"
#import "Menu.h"

@implementation GameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //authenticate Game Center user if not already
    [[GameCenterManager sharedManager] authenticatePlayer];
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        // Iphone
        NSLog(@"Iphone detected");
    } else if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        // Ipad
        NSLog(@"Ipad detected");
    } else {
        NSLog(@"Unknown device");
    }
}

-(void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    // Configure the view.
    SKView *skView = (SKView *)self.view;
    if (!skView.scene) {
        skView.showsFPS = YES;
        skView.showsNodeCount = YES;
        skView.showsDrawCount = YES;
        
        // Create and configure the scene.
        Menu *main = [[Menu alloc] initWithSize:skView.bounds.size];
        [skView presentScene: main];
    }
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
