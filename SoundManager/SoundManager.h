//
//  SoundManager.h
//
//  Version 1.4.1
//
//  Created by Nick Lockwood on 29/01/2011.
//  Copyright 2010 Charcoal Design
//
//  Distributed under the permissive zlib license
//  Get the latest version from here:
//
//  https://github.com/nicklockwood/SoundManager
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
//


#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wobjc-missing-property-synthesis"


#import <Availability.h>
#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#define SM_USE_AV_AUDIO_PLAYER 1
#else
#import <Cocoa/Cocoa.h>
#if !defined(SM_USE_AV_AUDIO_PLAYER) && \
__MAC_OS_X_VERSION_MIN_REQUIRED >= __MAC_10_7
#define SM_USE_AV_AUDIO_PLAYER 1
#endif
#endif

#if SM_USE_AV_AUDIO_PLAYER
#import <AVFoundation/AVFoundation.h>
#define SM_SOUND AVAudioPlayer
#else
#define SM_SOUND NSSound
#endif


extern NSString *const SoundDidFinishPlayingNotification;


typedef void (^SoundCompletionHandler)(BOOL didFinish);


@interface Sound : NSObject

+ (instancetype)soundNamed:(NSString *)name;
+ (instancetype)soundWithContentsOfFile:(NSString *)path;
- (instancetype)initWithContentsOfFile:(NSString *)path;
+ (instancetype)soundWithContentsOfURL:(NSURL *)URL;
- (instancetype)initWithContentsOfURL:(NSURL *)URL;

@property (nonatomic, readonly, copy) NSString *name;
@property (nonatomic, readonly) NSURL *URL;
@property (nonatomic, readonly, getter = isPlaying) BOOL playing;
@property (nonatomic, assign, getter = isLooping) BOOL looping;
@property (nonatomic, readonly) NSTimeInterval duration;
@property (nonatomic, assign) NSTimeInterval currentTime;
@property (nonatomic, copy) SoundCompletionHandler completionHandler;
@property (nonatomic, assign) float baseVolume;
@property (nonatomic, assign) float volume;
@property (nonatomic, assign) float pan;

- (void)fadeTo:(float)volume duration:(NSTimeInterval)duration;
- (void)fadeIn:(NSTimeInterval)duration;
- (void)fadeOut:(NSTimeInterval)duration;
- (void)play;
- (void)stop;

@end


@interface SoundManager : NSObject

@property (nonatomic, readonly, getter = isPlayingMusic) BOOL playingMusic;
@property (nonatomic, assign) BOOL allowsBackgroundMusic;
@property (nonatomic, assign) float soundVolume;
@property (nonatomic, assign) float musicVolume;
@property (nonatomic, assign) NSTimeInterval soundFadeDuration;
@property (nonatomic, assign) NSTimeInterval musicFadeDuration;

+ (instancetype)sharedManager;

- (void)prepareToPlayWithSound:(id)soundOrName;
- (void)prepareToPlay;

- (void)playMusic:(id)soundOrName looping:(BOOL)looping fadeIn:(BOOL)fadeIn;
- (void)playMusic:(id)soundOrName looping:(BOOL)looping;
- (void)playMusic:(id)soundOrName;

- (void)stopMusic:(BOOL)fadeOut;
- (void)stopMusic;

- (void)playSound:(id)soundOrName looping:(BOOL)looping fadeIn:(BOOL)fadeIn;
- (void)playSound:(id)soundOrName looping:(BOOL)looping;
- (void)playSound:(id)soundOrName;

- (void)stopSound:(id)soundOrName fadeOut:(BOOL)fadeOut;
- (void)stopSound:(id)soundOrName;
- (void)stopAllSounds:(BOOL)fadeOut;
- (void)stopAllSounds;

@end


#pragma GCC diagnostic pop
