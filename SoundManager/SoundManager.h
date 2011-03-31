//
//  SoundManager.h
//  SoundManager
//
//  Created by Nick Lockwood on 29/01/2011.
//  Copyright 2011 Charcoal Design. All rights reserved.
//

#import <Foundation/Foundation.h>


#define FILE_EXTENSION @"caf"
#define CROSSFADE_DURATION 3.0


extern NSString * const SoundFinishedPlayingNotification;


@interface Sound : NSObject
{    
    float targetVolume;
    float volumeDelta;
    NSTimeInterval lastTick;
    NSTimer *timer;
    Sound *selfReference;
    NSURL *url;
    id sound;
}

+ (Sound *)soundWithName:(NSString *)name;
+ (Sound *)soundWithURL:(NSURL *)url;

- (Sound *)initWithName:(NSString *)name;
- (Sound *)initWithURL:(NSURL *)url;

@property (nonatomic, retain, readonly) NSURL *url;
@property (nonatomic, assign, readonly) BOOL playing;
@property (nonatomic, assign) float volume;

- (void)fadeTo:(float)volume duration:(NSTimeInterval)duration;
- (void)fadeIn:(NSTimeInterval)duration;
- (void)fadeOut:(NSTimeInterval)duration;
- (void)play:(BOOL)loop;

@end


@interface SoundManager : NSObject
{    
    Sound *currentMusic;
    NSMutableArray *currentSounds;
    BOOL allowsBackgroundMusic;
    float soundVolume;
    float musicVolume;
}

@property (nonatomic, readonly) BOOL playingMusic;
@property (nonatomic, assign) BOOL allowsBackgroundMusic;
@property (nonatomic, assign) float soundVolume;
@property (nonatomic, assign) float musicVolume;

+ (SoundManager *)sharedManager;

- (void)prepareToPlay;
- (void)playMusic:(NSString *)name;
- (void)stopMusic;
- (void)playSound:(NSString *)name;

@end