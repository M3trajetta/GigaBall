//
//  HelpViewController.m
//  Brick Breaker
//
//  Created by Tantawy Mohammed on 13/6/19.
//  Copyright © 2019 Tantawy Mohammed. All rights reserved.
//

#import "Help.h"
#import "HelpViewController.h"

@interface HelpViewController ()

@end

@implementation HelpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // Configure the view.
    SKView * skView = (SKView *)self.view;
    skView.showsFPS = YES;
    skView.showsNodeCount = YES;
    
    // Create and configure the scene.
    Help *scene = [[Help alloc] initWithSize:skView.bounds.size vc:self];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    
    // Present the scene.
    [skView presentScene:scene];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.frame];
    self.scrollView.delegate = self;
    self.scrollView.contentSize = scene.world.frame.size;
    [self.view addSubview:self.scrollView];
    
    self.contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, scene.world.size.width, scene.world.size.height)];
    [self.scrollView addSubview:self.contentView];
    
    [self updatePosition];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self.scrollView addGestureRecognizer:tapRecognizer];
}

- (void)updatePosition{
    SKView *view = (SKView *)self.view;
    if ([view.scene isKindOfClass:[Help class]]) {
        Help *levelSelectScene = (Help *)view.scene;
        [levelSelectScene.world setScale:self.scrollView.zoomScale];
        CGPoint origin = self.contentView.frame.origin;
        levelSelectScene.world.position = CGPointMake(-self.scrollView.contentOffset.x + origin.x, -self.scrollView.contentSize.height + self.view.bounds.size.height + self.scrollView.contentOffset.y - origin.y);
    }
}

- (void)handleTap:(UITapGestureRecognizer *)recognizer {
    SKView *view = (SKView *)self.view;
    if ([view.scene respondsToSelector:@selector(handleTap:)]) {
        [view.scene performSelector:@selector(handleTap:) withObject:recognizer];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self updatePosition];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    SKView *view = (SKView *)self.view;
    if ([view.scene isKindOfClass:[Help class]]) {
        Help *levelSelectScene = (Help *)view.scene;
        // call a method on levelSelectScene to get actual offset
        *targetContentOffset = [levelSelectScene scrollOffsetForProposedOffset:*targetContentOffset];
    }
    
}

@end
