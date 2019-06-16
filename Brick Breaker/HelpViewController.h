//
//  HelpViewController.h
//  Brick Breaker
//
//  Created by Tantawy Mohammed on 13/6/19.
//  Copyright © 2019 Tantawy Mohammed. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HelpViewController : UIViewController<UIScrollViewDelegate>
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIView *contentView;
- (void)updatePosition;
@end

NS_ASSUME_NONNULL_END
