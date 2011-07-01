//
//  SoundManager.h
//
//  Version 1.1.2
//
//  Created by Nick Lockwood on 29/01/2011.
//  Copyright 2010 Charcoal Design. All rights reserved.
//
//  Get the latest version of SoundManager from either of these locations:
//
//  http://charcoaldesign.co.uk/source/cocoa#soundmanager
//  https://github.com/demosthenese/soundmanager
//
//  This software is provided 'as-is', without any express or implied
//  warranty.  In no event will the authors be held liable for any damages
//  arising from the use of this software.
//
//  Permission is granted to anyone to use this software for any purpose,
//  including commercial applications, and to alter it and redistribute it
//  freely, subject to the following restrictions:
//
//  1. The origin of this software must not be misrepresented; you must not
//  claim that you wrote the original software. If you use this software
//  in a product, an acknowledgment in the product documentation would be
//  appreciated but is not required.
//
//  2. Altered source versions must be plainly marked as such, and must not be
//  misrepresented as being the original software.
//
//  3. This notice may not be removed or altered from any source distribution.


#import <Foundation/Foundation.h>


#define FILE_EXTENSION @"caf"


extern NSString * const SoundFinishedPlayingNotification;


@interface Sound : NSObject
#ifdef __i386__
{    
	float baseVolume;
    float startVolume;
    float targetVolume;
    NSTimeInterval fadeTime;
	NSTimeInterval fadeStart;
    NSTimer *timer;
    Sound *selfReference;
    NSURL *url;
    id sound;
}
#endif

+ (Sound *)soundWithName:(NSString *)name;
+ (Sound *)soundWithURL:(NSURL *)url;

- (Sound *)initWithName:(NSString *)name;
- (Sound *)initWithURL:(NSURL *)url;

@property (nonatomic, retain, readonly) NSString *name;
@property (nonatomic, retain, readonly) NSURL *url;
@property (nonatomic, assign, readonly) BOOL playing;
@property (nonatomic, assign) BOOL looping;
@property (nonatomic, assign) float baseVolume;
@property (nonatomic, assign) float volume;

- (void)fadeTo:(float)volume duration:(NSTimeInterval)duration;
- (void)fadeIn:(NSTimeInterval)duration;
- (void)fadeOut:(NSTimeInterval)duration;
- (void)play;
- (void)stop;

@end


@interface SoundManager : NSObject
#ifdef __i386__
{    
    Sound *currentMusic;
    NSMutableArray *currentSounds;
    BOOL allowsBackgroundMusic;
    float soundVolume;
    float musicVolume;
    NSTimeInterval soundFadeDuration;
    NSTimeInterval musicFadeDuration;
}
#endif

@property (nonatomic, readonly) BOOL playingMusic;
@property (nonatomic, assign) BOOL allowsBackgroundMusic;
@property (nonatomic, assign) float soundVolume;
@property (nonatomic, assign) float musicVolume;
@property (nonatomic, assign) NSTimeInterval soundFadeDuration;
@property (nonatomic, assign) NSTimeInterval musicFadeDuration;

+ (SoundManager *)sharedManager;

- (void)prepareToPlay;
- (void)playMusic:(NSString *)name looping:(BOOL)looping;
- (void)stopMusic;
- (void)playSound:(NSString *)name looping:(BOOL)looping;
- (void)stopSound:(NSString *)name;
- (void)stopAllSounds;

@end