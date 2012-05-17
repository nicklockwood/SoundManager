//
//  SoundManager.h
//
//  Version 1.3.1
//
//  Created by Nick Lockwood on 29/01/2011.
//  Copyright 2010 Charcoal Design
//
//  Distributed under the permissive zlib license
//  Get the latest version from either of these locations:
//
//  http://charcoaldesign.co.uk/source/cocoa#soundmanager
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

//
//  ARC Helper
//
//  Version 1.3
//
//  Created by Nick Lockwood on 05/01/2012.
//  Copyright 2012 Charcoal Design
//
//  Distributed under the permissive zlib license
//  Get the latest version from here:
//
//  https://gist.github.com/1563325
//

#ifndef AH_RETAIN
#if __has_feature(objc_arc)
#define AH_RETAIN(x) (x)
#define AH_RELEASE(x) (void)(x)
#define AH_AUTORELEASE(x) (x)
#define AH_SUPER_DEALLOC (void)(0)
#define __AH_BRIDGE __bridge
#else
#define __AH_WEAK
#define AH_WEAK assign
#define AH_RETAIN(x) [(x) retain]
#define AH_RELEASE(x) [(x) release]
#define AH_AUTORELEASE(x) [(x) autorelease]
#define AH_SUPER_DEALLOC [super dealloc]
#define __AH_BRIDGE
#endif
#endif

//  ARC Helper ends


#import <Availability.h>
#if defined(__IPHONE_OS_VERSION_MAX_ALLOWED)
#import <UIKit/UIKit.h>
#define SM_USE_AV_AUDIO_PLAYER
#else
#import <Cocoa/Cocoa.h>
#if __MAC_OS_X_VERSION_MIN_REQUIRED > __MAC_10_6
#define SM_USE_AV_AUDIO_PLAYER
#endif
#endif


#ifdef SM_USE_AV_AUDIO_PLAYER
#import <AVFoundation/AVFoundation.h>
#define SM_SOUND AVAudioPlayer
#else
#define SM_SOUND NSSound
#endif


extern NSString *const SoundDidFinishPlayingNotification;


typedef void (^SoundCompletionHandler)(BOOL didFinish);


@interface Sound : NSObject

//required for 32-bit Macs
#ifdef __i386__
{
    @private
    
    float baseVolume;
    float startVolume;
    float targetVolume;
    NSTimeInterval fadeTime;
    NSTimeInterval fadeStart;
    NSTimer *timer;
    Sound *selfReference;
    NSURL *url;
    SM_SOUND *sound;
    SoundCompletionHandler completionHandler;
}
#endif

+ (Sound *)soundNamed:(NSString *)name;
+ (Sound *)soundWithContentsOfFile:(NSString *)path;
- (Sound *)initWithContentsOfFile:(NSString *)path;
+ (Sound *)soundWithContentsOfURL:(NSURL *)url;
- (Sound *)initWithContentsOfURL:(NSURL *)url;

@property (nonatomic, readonly, copy) NSString *name;
@property (nonatomic, readonly, strong) NSURL *url;
@property (nonatomic, readonly, getter = isPlaying) BOOL playing;
@property (nonatomic, assign, getter = isLooping) BOOL looping;
@property (nonatomic, copy) SoundCompletionHandler completionHandler;
@property (nonatomic, assign) float baseVolume;
@property (nonatomic, assign) float volume;

- (void)fadeTo:(float)volume duration:(NSTimeInterval)duration;
- (void)fadeIn:(NSTimeInterval)duration;
- (void)fadeOut:(NSTimeInterval)duration;
- (void)play;
- (void)stop;

@end


@interface SoundManager : NSObject

//required for 32-bit Macs
#ifdef __i386__
{
    @private
    
    Sound *currentMusic;
    NSMutableArray *currentSounds;
    BOOL allowsBackgroundMusic;
    float soundVolume;
    float musicVolume;
    NSTimeInterval soundFadeDuration;
    NSTimeInterval musicFadeDuration;
}
#endif

@property (nonatomic, readonly, getter = isPlayingMusic) BOOL playingMusic;
@property (nonatomic, assign) BOOL allowsBackgroundMusic;
@property (nonatomic, assign) float soundVolume;
@property (nonatomic, assign) float musicVolume;
@property (nonatomic, assign) NSTimeInterval soundFadeDuration;
@property (nonatomic, assign) NSTimeInterval musicFadeDuration;

+ (SoundManager *)sharedManager;

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