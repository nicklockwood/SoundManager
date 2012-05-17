//
//  SoundManager.m
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

#import "SoundManager.h"


#pragma mark Sound class


NSString *const SoundDidFinishPlayingNotification = @"SoundDidFinishPlayingNotification";


#ifdef SM_USE_AV_AUDIO_PLAYER
@interface Sound() <AVAudioPlayerDelegate>
#else
@interface Sound() <NSSoundDelegate>
#endif

@property (nonatomic, assign) float startVolume;
@property (nonatomic, assign) float targetVolume;
@property (nonatomic, assign) NSTimeInterval fadeTime;
@property (nonatomic, assign) NSTimeInterval fadeStart;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) Sound *selfReference;
@property (nonatomic, strong) SM_SOUND *sound;

- (void)prepareToPlay;

@end


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
@synthesize completionHandler;

+ (Sound *)soundNamed:(NSString *)name
{
    NSString *path = name;
    if (![path isAbsolutePath])
    {
        if ([[name pathExtension] isEqualToString:@""])
        {
            name = [name stringByAppendingPathExtension:@"caf"];
        }
        path = [[NSBundle mainBundle] pathForResource:name ofType:@""];
    }
    return [self soundWithContentsOfFile:path];
}

+ (Sound *)soundWithContentsOfFile:(NSString *)path
{
    return AH_AUTORELEASE([[self alloc] initWithContentsOfFile:path]);
}

+ (Sound *)soundWithContentsOfURL:(NSURL *)url
{
    return AH_AUTORELEASE([[self alloc] initWithContentsOfURL:url]);
}

- (Sound *)initWithContentsOfFile:(NSString *)path;
{   
    return [self initWithContentsOfURL:path? [NSURL fileURLWithPath:path]: nil];
}

- (Sound *)initWithContentsOfURL:(NSURL *)_url;
{
    
#ifdef DEBUG
    
    if ([_url isFileURL] && ![[NSFileManager defaultManager] fileExistsAtPath:[_url path]])
    {
        NSLog(@"Sound file '%@' does not exist", [_url path]);
    }
    
#endif
    
    if ((self = [super init]))
    {
        url = AH_RETAIN(_url);
        baseVolume = 1.0f;
        
#ifdef SM_USE_AV_AUDIO_PLAYER
        sound = [[AVAudioPlayer alloc] initWithContentsOfURL:_url error:NULL];
#else
        sound = [[NSSound alloc] initWithContentsOfURL:_url byReference:YES];
#endif
        self.volume = 1.0f;
    }
    return self;
}

- (void)prepareToPlay
{
    //avoid overhead from repeated calls
    static BOOL prepared = NO;
    if (prepared) return;
    prepared = YES;

#ifdef SM_USE_AV_AUDIO_PLAYER
    
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
    [AVAudioSession sharedInstance];
#endif
    
    [sound prepareToPlay];
    
#else
    
    [sound setVolume:0.0f];
    [self play];
    [self performSelector:@selector(stop) withObject:nil afterDelay:0.0];
    
#endif
    
}

- (NSString *)name
{
    return [[url path] lastPathComponent];
}

- (void)setbaseVolume:(float)_baseVolume
{
    _baseVolume = fminf(1.0f, fmaxf(0.0f, _baseVolume));
    
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
    volume = fminf(1.0f, fmaxf(0.0f, volume));
    
    if (timer)
    {
        targetVolume = volume * baseVolume;
    }
    else
    {
        [sound setVolume:volume * baseVolume];
    }
}

- (BOOL)isLooping
{
    
#ifdef SM_USE_AV_AUDIO_PLAYER
    return [sound numberOfLoops] == -1;
#else
    return [sound loops];
#endif
    
}

- (void)setLooping:(BOOL)looping
{
    
#ifdef SM_USE_AV_AUDIO_PLAYER
    [sound setNumberOfLoops:looping? -1: 0];
#else
    [sound setLoops:looping];
#endif
    
}

- (BOOL)isPlaying
{
    return [sound isPlaying];
}

- (void)play
{
    if (!self.playing)
    {
        self.selfReference = self;
        [sound setDelegate:self];
        
        //play sound
        [sound play];
    }
}

- (void)stop
{
    if (self.playing)
    {
        //stop playing
        [sound stop];
        
        //stop timer
        [timer invalidate];
        self.timer = nil;
        
        //fire events
        if (completionHandler) completionHandler(NO);
        [[NSNotificationCenter defaultCenter] postNotificationName:SoundDidFinishPlayingNotification object:self];
        
        //set to nil on next runloop update so sound is not released unexpectedly
        [self performSelector:@selector(setSelfReference:) withObject:nil afterDelay:0.0];
    }
}

#ifdef SM_USE_AV_AUDIO_PLAYER
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)finishedPlaying
#else
- (void)sound:(NSSound *)_sound didFinishPlaying:(BOOL)finishedPlaying
#endif
{
    //stop timer
    [timer invalidate];
    self.timer = nil;
    
    //fire events
    if (completionHandler) completionHandler(NO);
    [[NSNotificationCenter defaultCenter] postNotificationName:SoundDidFinishPlayingNotification object:self];
    
    //set to nil on next runloop update so sound is not released unexpectedly
    [self performSelector:@selector(setSelfReference:) withObject:nil afterDelay:0.0];
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
    [sound setVolume:0.0f];
    [self fadeTo:1.0f duration:duration];
}

- (void)fadeOut:(NSTimeInterval)duration
{
    [self fadeTo:0.0f duration:duration];
}

- (void)tick
{
    NSTimeInterval now = [[NSDate date] timeIntervalSinceReferenceDate];
    float delta = (now - fadeStart)/fadeTime * (targetVolume - startVolume);
    [sound setVolume:(startVolume + delta) * baseVolume];
    if ((delta > 0.0f && [sound volume] >= targetVolume) ||
        (delta < 0.0f && [sound volume] <= targetVolume))
    {
        [sound setVolume:targetVolume * baseVolume];
        [timer invalidate];
        self.timer = nil;
        if ([sound volume] == 0.0f)
        {
            [self stop];
        }
    }
}

- (void)dealloc
{
    [timer invalidate];
    AH_RELEASE(timer);
    AH_RELEASE(url);
    AH_RELEASE(sound);
    AH_RELEASE(completionHandler);
    AH_SUPER_DEALLOC;
}

@end


#pragma mark SoundManager class


@interface SoundManager ()

@property (nonatomic, strong) Sound *currentMusic;
@property (nonatomic, strong) NSMutableArray *currentSounds;

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
    static SoundManager *sharedManager = nil;
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
        soundVolume = 1.0f;
        musicVolume = 1.0f;
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

- (void)prepareToPlayWithSound:(id)soundOrName
{
    Sound *sound = [soundOrName isKindOfClass:[Sound class]]? soundOrName: [Sound soundNamed:soundOrName];
    [sound prepareToPlay];
}

- (void)prepareToPlay
{
    @autoreleasepool
    {
        NSArray *extensions = [NSArray arrayWithObjects:@"caf", @"m4a", @"mp4", @"mp3", @"wav", @"aif", nil];
        NSArray *paths = nil;
        BOOL foundSound = NO;
        for (NSString *extension in extensions)
        {
            paths = [[NSBundle mainBundle] pathsForResourcesOfType:extension inDirectory:nil];
            if ([paths count])
            {
                [self prepareToPlayWithSound:[paths objectAtIndex:0]];
                foundSound = YES;
                break;
            }
        }
        if (!foundSound)
        {
            NSLog(@"SoundManager prepareToPlay failed to find sound in application bundle. Use prepareToPlayWithSound: instead to specify a suitable sound file.");
        }
    }
}

- (void)playMusic:(id)soundOrName looping:(BOOL)looping fadeIn:(BOOL)fadeIn
{
    Sound *music = [soundOrName isKindOfClass:[Sound class]]? soundOrName: [Sound soundNamed:soundOrName];
    if (![music.url isEqual:currentMusic.url])
    {
        if (currentMusic && currentMusic.playing)
        {
            [currentMusic fadeOut:musicFadeDuration];
        }
        self.currentMusic = music;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(musicFinished:)
                                                     name:SoundDidFinishPlayingNotification
                                                   object:music];
        currentMusic.looping = looping;
        currentMusic.volume = fadeIn? 0.0f: musicVolume;
        [currentMusic play];
        if (fadeIn)
        {
            [currentMusic fadeTo:musicVolume duration:musicFadeDuration];
        }
    }
}

- (void)playMusic:(id)soundOrName looping:(BOOL)looping
{       
    [self playMusic:soundOrName looping:looping fadeIn:YES];
}

- (void)playMusic:(id)soundOrName
{       
    [self playMusic:soundOrName looping:YES fadeIn:YES];
}

- (void)stopMusic:(BOOL)fadeOut
{
    if (fadeOut)
    {
        [currentMusic fadeOut:musicFadeDuration];
    }
    else
    {
        [currentMusic stop];
    }
    self.currentMusic = nil;
}

- (void)stopMusic
{
    [self stopMusic:YES];
}

- (void)playSound:(id)soundOrName looping:(BOOL)looping fadeIn:(BOOL)fadeIn
{
    Sound *sound = [soundOrName isKindOfClass:[Sound class]]? soundOrName: [Sound soundNamed:soundOrName];
    if (![currentSounds containsObject:sound])
    {
        [currentSounds addObject:sound];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(soundFinished:)
                                                     name:SoundDidFinishPlayingNotification
                                                   object:sound];
    }
    sound.looping = looping;
    sound.volume = fadeIn? 0.0f: soundVolume;
    [sound play];
    if (fadeIn)
    {
        [sound fadeTo:soundVolume duration:soundFadeDuration];
    }
}

- (void)playSound:(id)soundOrName looping:(BOOL)looping
{
    [self playSound:soundOrName looping:looping fadeIn:NO];
}

- (void)playSound:(id)soundOrName
{
    [self playSound:soundOrName looping:NO fadeIn:NO];
}

- (void)stopSound:(id)soundOrName fadeOut:(BOOL)fadeOut
{
    if ([soundOrName isKindOfClass:[Sound class]])
    {
        if (fadeOut)
        {
            [(Sound *)soundOrName fadeOut:soundFadeDuration];
        }
        else
        {
            [(Sound *)soundOrName stop];
        }
        [currentSounds removeObject:soundOrName];
        return;
    }
    
    if ([[soundOrName pathExtension] isEqualToString:@""])
    {
        soundOrName = [soundOrName stringByAppendingPathExtension:@"caf"];
    }
    
    for (Sound *sound in [currentSounds reverseObjectEnumerator])
    {
        if ([sound.name isEqualToString:soundOrName] || [[sound.url path] isEqualToString:soundOrName])
        {
            if (fadeOut)
            {
                [sound fadeOut:soundFadeDuration];
            }
            else
            {
                [sound stop];
            }
            [currentSounds removeObject:sound];
        }
    }
}

- (void)stopSound:(id)soundOrName
{
    [self stopSound:soundOrName fadeOut:YES];
}

- (void)stopAllSounds:(BOOL)fadeOut
{
    for (Sound *sound in currentSounds)
    {
        [self stopSound:sound fadeOut:YES];
    }
}

- (void)stopAllSounds
{
    [self stopAllSounds:YES];
}

- (BOOL)isPlayingMusic
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
    Sound *sound = [notification object];
    [currentSounds removeObject:sound];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:SoundDidFinishPlayingNotification
                                                  object:sound];
}

- (void)musicFinished:(NSNotification *)notification
{
    Sound *sound = [notification object];
    if (sound == currentMusic)
    {
        self.currentMusic = nil;
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:SoundDidFinishPlayingNotification
                                                      object:sound];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    AH_RELEASE(currentMusic);
    AH_RELEASE(currentSounds);
    AH_SUPER_DEALLOC;
}

@end
