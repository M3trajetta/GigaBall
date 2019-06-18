//
//  GameViewController.m
//  Brick Breaker
//
//  Created by Tantawy Mohammed on 8/4/19.
//  Copyright © 2019 Tantawy Mohammed. All rights reserved.
//

#import "GameViewController.h"
#import "HelpViewController.h"
#import "GameCenterManager.h"
#import "GameScene.h"
#import "Menu.h"
#import "Help.h"

@implementation GameViewController{
    CAShapeLayer* _shapeLayer;
    CAShapeLayer* _background;
    CAShapeLayer* _trackLayer;
    CAShapeLayer* _pulsatingLayer;
    UILabel* _loadingLabel;
    UILabel* _percentageLabel;
    NSTimer* _timer;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _background = [CAShapeLayer layer];
    _background.bounds = self.view.bounds;
    _background.position = self.view.center;
    _background.backgroundColor = [UIColor colorWithRed:0.08 green:0.09 blue:0.13 alpha:1].CGColor;
    [self.view.layer addSublayer:_background];
    
    
    [self setupCircleLayers];
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(loadingView) userInfo:nil repeats:NO];
    [self setupLoadingLabels];
}

-(void)loadingView{
    [_timer invalidate];
    [self startLoading];
}

- (void)startLoading {
    CABasicAnimation* loading = [CABasicAnimation alloc];
    loading.keyPath = @"strokeEnd";
    loading.toValue = @1;
    loading.duration = 2;
    loading.fillMode = kCAFillModeForwards;
    loading.removedOnCompletion = NO;
    [_shapeLayer addAnimation:loading forKey:@"basicLoading"];
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(updateLoadingLabel) userInfo:nil repeats:YES];
}

-(void)animatePulsatingLayer{
    CABasicAnimation* pulsating = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    pulsating.toValue = @1.3;
    pulsating.duration = 0.8;
    pulsating.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    pulsating.autoreverses = YES;
    pulsating.repeatCount = INFINITY;
    [_pulsatingLayer addAnimation:pulsating forKey:@"pulsatingAnimation"];
}

-(void)updateLoadingLabel{
    self.percentage++;
    _percentageLabel.text = [NSString stringWithFormat:@"%d%%",self.percentage];
    if(self.percentage == 25) _loadingLabel.text = @"Loading.";
    if(self.percentage == 50) _loadingLabel.text = @"Loading..";
    if(self.percentage == 75) _loadingLabel.text = @"Loading...";
    if(self.percentage == 100) _loadingLabel.text = @"Completed!";
    if (self.percentage > 100) {
        [NSThread sleepForTimeInterval:1];
        [_timer invalidate];
        self.percentage = 0;
        [_shapeLayer removeFromSuperlayer];
        [_trackLayer removeFromSuperlayer];
        [_pulsatingLayer removeFromSuperlayer];
        [_loadingLabel removeFromSuperview];
        [_percentageLabel removeFromSuperview];
        [_background removeFromSuperlayer];
        // Configure the view.
        SKView *skView = (SKView *)self.view;
        if (!skView.scene) {
//            skView.showsFPS = YES;
//            skView.showsNodeCount = YES;
//            skView.showsDrawCount = YES;
            // Create and configure the scene.
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
                CGSize screenSize = [[UIScreen mainScreen] bounds].size;
                if (screenSize.height >= 812){
                    Menu* main = [[Menu alloc] initWithSize:CGSizeMake(screenSize.width, screenSize.height-74)];
                    main.scaleMode = SKSceneScaleModeAspectFit;
                    [skView presentScene: main];
                } else {
                    Menu* main = [[Menu alloc] initWithSize:skView.bounds.size];
                    main.scaleMode = SKSceneScaleModeAspectFit;
                    [skView presentScene: main];
                }
            } else {
                Menu* main = [[Menu alloc] initWithSize:skView.bounds.size];
                main.scaleMode = SKSceneScaleModeAspectFit;
                [skView presentScene: main];
            }
            
        }
    }
}

-(void)setupLoadingLabels{
    // Add percentage label
    _loadingLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width)];
    _loadingLabel.font = [UIFont fontWithName:@"zorque" size:40];
    _loadingLabel.text = @"Loading";
    _loadingLabel.textColor = [UIColor whiteColor];
    _loadingLabel.textAlignment = NSTextAlignmentCenter;
    _loadingLabel.center = CGPointMake(self.view.center.x, self.view.center.y + 200);
    [self.view addSubview:_loadingLabel];
    
    // Add percentage label
    _percentageLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 100)];
    _percentageLabel.font = [UIFont fontWithName:@"AlbaMatter" size:32];
    _percentageLabel.text = @"0%";
    _percentageLabel.textColor = [UIColor whiteColor];
    _percentageLabel.textAlignment = NSTextAlignmentCenter;
    _percentageLabel.center = self.view.center;
    [self.view addSubview:_percentageLabel];
}

-(void)setupCircleLayers{
    // Pulsating Layer
    _pulsatingLayer = [self createCircleShapeLayer:[UIColor clearColor] andFillColor:[UIColor colorWithRed:0.34 green:0.12 blue:0.25 alpha:1]];
    [self.view.layer addSublayer:_pulsatingLayer];
    [self animatePulsatingLayer];
    
    // Track Layer
    _trackLayer = [self createCircleShapeLayer:[UIColor colorWithRed:0.22 green:0.1 blue:0.19 alpha:1] andFillColor:[UIColor colorWithRed:0.08 green:0.09 blue:0.13 alpha:1]];
    [self.view.layer addSublayer:_trackLayer];
    
    // Shape Layer
    _shapeLayer = [self createCircleShapeLayer:[UIColor colorWithRed:0.92 green:0.18 blue:0.43 alpha:1] andFillColor:[UIColor clearColor]];
    _shapeLayer.transform = CATransform3DMakeRotation(-M_PI/2, 0, 0, 1);
    _shapeLayer.strokeEnd = 0;
    [self.view.layer addSublayer:_shapeLayer];
}

-(CAShapeLayer*)createCircleShapeLayer:(UIColor*)strokeColor andFillColor: (UIColor*)fillColor {
    CAShapeLayer* layer = [CAShapeLayer layer];
    UIBezierPath* circularPath = [UIBezierPath bezierPathWithArcCenter:CGPointZero radius:100 startAngle:0 endAngle:2 * M_PI clockwise:YES];
    layer.path = circularPath.CGPath;
    layer.strokeColor = strokeColor.CGColor;
    layer.lineWidth = 20;
    layer.fillColor = fillColor.CGColor;
    layer.lineCap = kCALineCapRound;
    layer.position = self.view.center;
    return layer;
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
