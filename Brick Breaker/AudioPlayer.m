//
//  AudioPlayer.m
//  Brick Breaker
//
//  Created by Tantawy Mohammed on 21/5/19.
//  Copyright © 2019 Tantawy Mohammed. All rights reserved.
//

#import "AudioPlayer.h"

@implementation AudioPlayer

- (instancetype)init:(NSString*)name
{
    self = [super init];
    if (self) {
        NSURL* url= [[NSBundle mainBundle] URLForResource:name withExtension:@"caf"];
        NSError* err = nil;
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:nil];

        // Create audio player with background music
        _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&err];
        if(!_audioPlayer) NSLog(@"Error loading Audio Player: %@", err);
        else{
            _audioPlayer.numberOfLoops = -1;
        }
        _isPlaying = NO;
        _audioPlayer.delegate = _audioPlayer.delegate.self;
    }
    return self;
}
@end
