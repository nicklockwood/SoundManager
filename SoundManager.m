//
//  SoundManager.m
//  SoundManager
//
//  Created by Nick Lockwood on 29/01/2011.
//  Copyright 2011 Charcoal Design. All rights reserved.
//

#import "SoundManager.h"


#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
#import <AVFoundation/AVFoundation.h>
@interface Sound() <AVAudioPlayerDelegate>
#else
#import <AppKit/AppKit.h>
@interface Sound() <NSSoundDelegate>
#endif

@property (nonatomic, assign) float targetVolume;
@property (nonatomic, assign) float volumeDelta;
@property (nonatomic, assign) NSTimeInterval lastTick;
@property (nonatomic, retain) NSTimer *timer;
@property (nonatomic, retain) Sound *selfReference;

@end


@implementation Sound

@synthesize targetVolume;
@synthesize volumeDelta;
@synthesize lastTick;
@synthesize timer;
@synthesize selfReference;
@synthesize url;


+ (Sound *)soundWithName:(NSString *)_name
{
    return [[[self alloc] initWithName:_name] autorelease];
}

+ (Sound *)soundWithURL:(NSURL *)url
{
    return [[[self alloc] initWithURL:url] autorelease];
}

- (Sound *)initWithName:(NSString *)_name;
{
	if ([[_name pathExtension] isEqualToString:@""])
    {
        _name = [_name stringByAppendingPathExtension:FILE_EXTENSION];
    }
    NSString *path = [[NSBundle mainBundle] pathForResource:_name ofType:nil];
    return [self initWithURL:[NSURL fileURLWithPath:path]];
}

- (Sound *)initWithURL:(NSURL *)_url;
{
    if ((self = [super init]))
    {
        url = [_url retain];
        
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
        sound = [[AVAudioPlayer alloc] initWithContentsOfURL:_url error:NULL];
#else
        sound = [[NSSound alloc] initWithContentsOfURL:_url byReference:YES];
#endif
        
    }
    return self;
}

- (float)volume
{
    return [sound volume];
}

- (void)setVolume:(float)volume
{
    [sound setVolume:volume];
}

- (BOOL)playing
{
    return [sound isPlaying];
}

- (void)play:(BOOL)loop
{
    if (!self.playing)
    {
        self.selfReference = self;
        [sound setDelegate:self];
        
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
        [sound setNumberOfLoops:loop? -1: 0];
        [(AVAudioPlayer *)sound play];
#else
        [sound setLoops:loop];
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
    
    self.selfReference = nil;
}

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
#else
- (void)sound:(NSSound *)_sound didFinishPlaying:(BOOL)finishedPlaying
#endif
{
    [self stop];
}

- (void)fadeTo:(float)volume duration:(NSTimeInterval)duration
{
	targetVolume = volume;
	volumeDelta = (volume - self.volume) / duration;
	if (timer == nil)
	{
		lastTick = [[NSDate date] timeIntervalSinceReferenceDate];
		self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0/60.0
													  target:self
													selector:@selector(tick)
													userInfo:nil
													 repeats:YES];
	}
}

- (void)fadeIn:(NSTimeInterval)duration
{
	self.volume = 0.0;
    [self fadeTo:1.0 duration:duration];
}

- (void)fadeOut:(NSTimeInterval)duration
{
	[self fadeTo:0.0 duration:duration];
}

- (void)tick
{
	NSTimeInterval now = [[NSDate date] timeIntervalSinceReferenceDate];
	float delta = (now - lastTick);
	self.volume += delta * volumeDelta;
	if (volumeDelta > 0 && self.volume >= targetVolume)
	{
		self.volume = targetVolume;
		[timer invalidate];
		self.timer = nil;
	}
	else if (volumeDelta < 0 && self.volume <= targetVolume)
	{
		self.volume = targetVolume;
		[timer invalidate];
		self.timer = nil;
	}
    if (self.volume == 0)
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


static SoundManager *sharedManager = nil;


@interface SoundManager ()

@property (nonatomic, retain) Sound *currentMusic;

@end


@implementation SoundManager

@synthesize currentMusic;
@synthesize allowsBackgroundMusic;


+ (SoundManager *)sharedManager
{
	if (sharedManager == nil)
	{
		sharedManager = [[self alloc] init];
	}
	return sharedManager;
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
    
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSArray *extensions = [NSArray arrayWithObjects:@"caf", @"m4a", @"mp4", @"mp3", @"wav", @"aif", nil];
    NSArray *paths = nil;
    for (NSString *extension in extensions)
    {
        paths = [[NSBundle mainBundle] pathsForResourcesOfType:FILE_EXTENSION inDirectory:nil];
        if ([paths count])
        {
            break;
        }
    }
    NSURL *url = [NSURL fileURLWithPath:[paths objectAtIndex:0]];
    AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:NULL];
    [player prepareToPlay];
    [player release];
    [pool drain];
    
#endif
    
}

- (void)playMusic:(NSString *)name
{		
	Sound *music = [Sound soundWithName:name];
    if (![music.url isEqual:currentMusic.url])
	{
		if (currentMusic && currentMusic.playing)
		{
			[currentMusic fadeOut:CROSSFADE_DURATION];
		}
		self.currentMusic = music;
		currentMusic.volume = 0.0;
        [currentMusic play:YES];
        [currentMusic fadeTo:MUSIC_VOLUME duration:CROSSFADE_DURATION];
	}
}

- (void)stopMusic
{
    [currentMusic fadeOut:CROSSFADE_DURATION];
    self.currentMusic = nil;
}

- (void)playSound:(NSString *)name
{
    Sound *sound = [Sound soundWithName:name];
    sound.volume = SOUND_VOLUME;
    [sound play:NO];
}

- (BOOL)playingMusic
{
    return currentMusic != nil;
}

- (void)dealloc
{
	[currentMusic release];
	[super dealloc];
}

@end
