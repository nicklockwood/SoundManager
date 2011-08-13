//
//  SoundManager.m
//
//  Version 1.1.3
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


#import "SoundManager.h"


#pragma mark -
#pragma Sound class


#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
#import <AVFoundation/AVFoundation.h>
@interface Sound() <AVAudioPlayerDelegate>
#else
#import <AppKit/AppKit.h>
@interface Sound() <NSSoundDelegate>
#endif

@property (nonatomic, assign) float startVolume;
@property (nonatomic, assign) float targetVolume;
@property (nonatomic, assign) NSTimeInterval fadeTime;
@property (nonatomic, assign) NSTimeInterval fadeStart;
@property (nonatomic, retain) NSTimer *timer;
@property (nonatomic, retain) Sound *selfReference;
@property (nonatomic, retain) id sound;

@end


NSString * const SoundFinishedPlayingNotification = @"SoundFinishedPlayingNotification";


@implementation Sound

@synthesize baseVolume;
@synthesize startVolume;
@synthesize targetVolume;
@synthesize fadeTime;
@synthesize fadeStart;
@synthesize timer;
@synthesize selfReference;
@synthesize url;
@synthesize sound;


+ (Sound *)soundWithName:(NSString *)name
{
    return [[[self alloc] initWithName:name] autorelease];
}

+ (Sound *)soundWithURL:(NSURL *)url
{
    return [[[self alloc] initWithURL:url] autorelease];
}

- (Sound *)initWithName:(NSString *)_name;
{
	if ([[_name pathExtension] isEqualToString:@""])
    {
        _name = [_name stringByAppendingPathExtension:DEFAULT_FILE_EXTENSION];
    }
	
    NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:_name];
	
#ifdef DEBUG
	
	if (![[NSFileManager defaultManager] fileExistsAtPath:path])
	{
		NSLog(@"Sound file '%@' does not exist", _name);
	}
	
#endif
	
	return [self initWithURL:[NSURL fileURLWithPath:path]];
}

- (Sound *)initWithURL:(NSURL *)_url;
{
    if ((self = [super init]))
    {
        url = [_url retain];
		baseVolume = 1.0;
        
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
        sound = [[AVAudioPlayer alloc] initWithContentsOfURL:_url error:NULL];
#else
        sound = [[NSSound alloc] initWithContentsOfURL:_url byReference:YES];
#endif
		self.volume = 1.0;
    }
    return self;
}

- (NSString *)name
{
    return [[[url path] lastPathComponent] stringByDeletingPathExtension];
}

- (void)setbaseVolume:(float)_baseVolume
{
	_baseVolume = fmin(1.0, fmax(0.0, _baseVolume));
	
	if (baseVolume != _baseVolume)
	{
		float previousVolume = self.volume;
		baseVolume = _baseVolume;
		self.volume = previousVolume;
	}
}

- (float)volume
{
    if (timer)
    {
        return targetVolume / baseVolume;
    }
    else
    {
        return [sound volume] / baseVolume;
    }
}

- (void)setVolume:(float)volume
{
	volume = fmin(1.0, fmax(0.0, volume));
	
    if (timer)
    {
        targetVolume = volume * baseVolume;
    }
    else
    {
        [sound setVolume:volume * baseVolume];
    }
}

- (BOOL)looping
{
	
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
	return [sound numberOfLoops] == -1;
#else
	return [sound loops];
#endif
	
}

- (void)setLooping:(BOOL)looping
{
	
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
	[sound setNumberOfLoops:looping? -1: 0];
#else
	[sound setLoops:looping];
#endif
	
}

- (BOOL)playing
{
    return [sound isPlaying];
}

- (void)play
{
    if (!self.playing)
    {
        self.selfReference = self;
        [sound setDelegate:self];
        
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
        [(AVAudioPlayer *)sound play];
#else
        [(NSSound *)sound play];
#endif
        
    }
}

- (void)stop
{
    
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
    [(AVAudioPlayer *)sound stop];
#else
    [(NSSound *)sound stop];
#endif
    
	//autorelease so sound is not released immediately
    [selfReference autorelease];
	selfReference = nil;
}

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
#else
- (void)sound:(NSSound *)_sound didFinishPlaying:(BOOL)finishedPlaying
#endif
{
    [self stop];
	
    [[NSNotificationCenter defaultCenter] postNotificationName:SoundFinishedPlayingNotification object:self];
}

- (void)fadeTo:(float)volume duration:(NSTimeInterval)duration
{
	startVolume = [sound volume];
	targetVolume = volume * baseVolume;
	fadeTime = duration;
	fadeStart = [[NSDate date] timeIntervalSinceReferenceDate];
	if (timer == nil)
	{
		self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0/60.0
													  target:self
													selector:@selector(tick)
													userInfo:nil
													 repeats:YES];
	}
}

- (void)fadeIn:(NSTimeInterval)duration
{
	[sound setVolume:0.0];
    [self fadeTo:1.0 duration:duration];
}

- (void)fadeOut:(NSTimeInterval)duration
{
	[self fadeTo:0.0 duration:duration];
}

- (void)tick
{
	NSTimeInterval now = [[NSDate date] timeIntervalSinceReferenceDate];
	float delta = (now - fadeStart)/fadeTime * (targetVolume - startVolume);
	[sound setVolume:(startVolume + delta) * baseVolume];
	if ((delta > 0 && [sound volume] >= targetVolume) ||
        (delta < 0 && [sound volume] <= targetVolume))
	{
		[sound setVolume:targetVolume * baseVolume];
		[timer invalidate];
		self.timer = nil;
	}
    if ([sound volume] == 0)
    {
        [self stop];
    }
}

- (void)dealloc
{
    [timer invalidate];
	[timer release];
    [url release];
    [sound release];
	[super dealloc];
}

@end


#pragma mark -
#pragma SoundManager class


static SoundManager *sharedManager = nil;


@interface SoundManager ()

@property (nonatomic, retain) Sound *currentMusic;
@property (nonatomic, retain) NSMutableArray *currentSounds;

@end


@implementation SoundManager

@synthesize currentMusic;
@synthesize currentSounds;
@synthesize allowsBackgroundMusic;
@synthesize soundVolume;
@synthesize musicVolume;
@synthesize soundFadeDuration;
@synthesize musicFadeDuration;


+ (SoundManager *)sharedManager
{
	if (sharedManager == nil)
	{
		sharedManager = [[self alloc] init];
	}
	return sharedManager;
}

- (SoundManager *)init
{
    if ((self = [super init]))
    {
        soundVolume = 1.0;
        musicVolume = 1.0;
        soundFadeDuration = 1.0;
        musicFadeDuration = 1.0;
        currentSounds = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)setAllowsBackgroundMusic:(BOOL)allow
{
    if (allowsBackgroundMusic != allow)
    {

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
        
        allowsBackgroundMusic = allow;
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setCategory:allow? AVAudioSessionCategoryAmbient: AVAudioSessionCategorySoloAmbient error:NULL];
#endif
        
    }
}

- (void)prepareToPlay
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSArray *extensions = [NSArray arrayWithObjects:@"caf", @"m4a", @"mp4", @"mp3", @"wav", @"aif", nil];
    NSArray *paths = nil;
    for (NSString *extension in extensions)
    {
        paths = [[NSBundle mainBundle] pathsForResourcesOfType:extension inDirectory:nil];
        if ([paths count])
        {
            break;
        }
    }
    NSURL *url = [NSURL fileURLWithPath:[paths objectAtIndex:0]];
    
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
    
    [AVAudioSession sharedInstance];
    AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:NULL];
    [player prepareToPlay];
    [player release];
    
#else
    
    NSSound *sound = [[NSSound alloc] initWithContentsOfURL:url byReference:YES];
    [sound setVolume:0];
    [sound play];
    [sound release];
    
#endif
    
    [pool drain];
}

- (void)playMusic:(NSString *)name looping:(BOOL)looping
{		
	Sound *music = [Sound soundWithName:name];
    if (![music.url isEqual:currentMusic.url])
	{
		if (currentMusic && currentMusic.playing)
		{
			[currentMusic fadeOut:musicFadeDuration];
		}
		self.currentMusic = music;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(musicFinished:)
                                                     name:SoundFinishedPlayingNotification
                                                   object:music];
		currentMusic.looping = looping;
		currentMusic.volume = 0.0;
		[currentMusic play];
		[currentMusic fadeTo:musicVolume duration:musicFadeDuration];
	}
}

- (void)stopMusic
{
    [currentMusic fadeOut:musicFadeDuration];
    self.currentMusic = nil;
}

- (void)playSound:(NSString *)name looping:(BOOL)looping
{
    Sound *sound = [Sound soundWithName:name];
    [currentSounds addObject:sound];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(soundFinished:)
                                                 name:SoundFinishedPlayingNotification
                                               object:sound];
    sound.volume = soundVolume;
	sound.looping = looping;
    [sound play];
}

- (void)stopSound:(NSString *)name
{
    NSInteger i;
    for (i = [currentSounds count] - 1; i >= 0; i--)
    {
        Sound *sound = [currentSounds objectAtIndex:i];
        if ([sound.name isEqualToString:name])
        {
            [sound fadeOut:soundFadeDuration];
            [currentSounds removeObjectAtIndex:i];
        }
    }
}

- (void)stopAllSounds
{
    for (Sound *sound in currentSounds)
    {
        [sound fadeOut:soundFadeDuration];
    }
    [currentSounds removeAllObjects];
}

- (BOOL)playingMusic
{
    return currentMusic != nil;
}

- (void)setSoundVolume:(float)newVolume
{
    soundVolume = newVolume;
    for (Sound *sound in currentSounds)
    {
        sound.volume = soundVolume;
    }
}

- (void)setMusicVolume:(float)newVolume
{
    musicVolume = newVolume;
    currentMusic.volume = musicVolume;
}

- (void)soundFinished:(NSNotification *)notification
{
    [currentSounds removeObject:[notification object]];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:SoundFinishedPlayingNotification
                                                  object:[notification object]];
}

- (void)musicFinished:(NSNotification *)notification
{
    if ([notification object] == currentMusic)
    {
        self.currentMusic = nil;
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:SoundFinishedPlayingNotification
                                                      object:[notification object]];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
	[currentMusic release];
	[super dealloc];
}

@end
