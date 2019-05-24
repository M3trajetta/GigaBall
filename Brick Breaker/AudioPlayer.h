//
//  AudioPlayer.h
//  Brick Breaker
//
//  Created by Tantawy Mohammed on 21/5/19.
//  Copyright © 2019 Tantawy Mohammed. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AudioPlayer : NSObject
@property (nonatomic) AVAudioPlayer* audioPlayer;
@property (nonatomic) float volume;
@property (nonatomic) BOOL isPlaying;
- (instancetype)init:(NSString*)name;
@end

NS_ASSUME_NONNULL_END
