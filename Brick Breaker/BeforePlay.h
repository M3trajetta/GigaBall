//
//  BeforePlay.h
//  Brick Breaker
//
//  Created by Tantawy Mohammed on 16/6/19.
//  Copyright © 2019 Tantawy Mohammed. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BeforePlay : SKNode
@property (nonatomic) int levelNumber;
-(void)show;
-(void)hide;
@end

NS_ASSUME_NONNULL_END
