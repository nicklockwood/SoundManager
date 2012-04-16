//
//  SoundManager.h
//
//  Version 1.2
//
//  Created by Nick Lockwood on 29/01/2011.
//  Copyright 2010 Charcoal Design
//
//  Distributed under the permissive zlib License
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
//  Version 1.2
//
//  Created by Nick Lockwood on 05/01/2012.
//  Copyright 2012 Charcoal Design
//
//  Distributed under the permissive zlib License
//  Get the latest version from here:
//
//  https://gist.github.com/1563325
//

#ifndef AH_RETAIN
#if __has_feature(objc_arc)
#define AH_RETAIN(x) x
#define AH_RELEASE(x)
#define AH_AUTORELEASE(x) x
#define AH_SUPER_DEALLOC
#else
#define __AH_WEAK
#define AH_WEAK assign
#define AH_RETAIN(x) [x retain]
#define AH_RELEASE(x) [x release]
#define AH_AUTORELEASE(x) [x autorelease]
#define AH_SUPER_DEALLOC [super dealloc]
#endif
#endif

//  ARC Helper ends


#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#else
#import <Cocoa/Cocoa.h>
#endif


extern NSString *const SoundFinishedPlayingNotification;
extern NSString *const SoundManagerDefaultFileExtension;


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
    id sound;
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

- (void)prepareToPlay;
- (void)playMusic:(NSString *)name looping:(BOOL)looping;
- (void)stopMusic;
- (void)playSound:(NSString *)name looping:(BOOL)looping;
- (void)stopSound:(NSString *)name;
- (void)stopAllSounds;

@end