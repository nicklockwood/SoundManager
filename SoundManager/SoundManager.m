//
//  SoundManager.m
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


#import "SoundManager.h"


#pragma GCC diagnostic ignored "-Wobjc-missing-property-synthesis"
#pragma GCC diagnostic ignored "-Wdirect-ivar-access"
#pragma GCC diagnostic ignored "-Wselector"
#pragma GCC diagnostic ignored "-Wgnu"


#import <Availability.h>
#if !__has_feature(objc_arc)
#error This class requires automatic reference counting
#endif


NSString *const SoundDidFinishPlayingNotification = @"SoundDidFinishPlayingNotification";

@interface Sound()

#if SM_USE_AV_AUDIO_PLAYER
<AVAudioPlayerDelegate>
#else
<NSSoundDelegate>
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

+ (instancetype)soundNamed:(NSString *)name
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

+ (instancetype)soundWithContentsOfFile:(NSString *)path
{
    return [[self alloc] initWithContentsOfFile:path];
}

+ (instancetype)soundWithContentsOfURL:(NSURL *)URL
{
    return [[self alloc] initWithContentsOfURL:URL];
}

- (instancetype)initWithContentsOfFile:(NSString *)path
{   
    return [self initWithContentsOfURL:path? [NSURL fileURLWithPath:path]: nil];
}

- (instancetype)initWithContentsOfURL:(NSURL *)URL
{
    
#ifdef DEBUG
    
    if ([URL isFileURL] && ![[NSFileManager defaultManager] fileExistsAtPath:[URL path]])
    {
        NSLog(@"Sound file '%@' does not exist", [URL path]);
    }
    
#endif
    
    if ((self = [super init]))
    {
        _URL = URL;
        _baseVolume = 1.0f;
        
#if SM_USE_AV_AUDIO_PLAYER
        _sound = [[AVAudioPlayer alloc] initWithContentsOfURL:URL error:NULL];
#else
        _sound = [[NSSound alloc] initWithContentsOfURL:URL byReference:YES];
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

#if SM_USE_AV_AUDIO_PLAYER
    
#if TARGET_OS_IPHONE
    [AVAudioSession sharedInstance];
#endif
    
    [_sound prepareToPlay];
    
#else
    
    [_sound setVolume:0.0f];
    [self play];
    [self performSelector:@selector(stop) withObject:nil afterDelay:0.0];
    
#endif
    
}

- (NSString *)name
{
    return [[_URL path] lastPathComponent];
}

- (void)setbaseVolume:(float)baseVolume
{
    baseVolume = fminf(1.0f, fmaxf(0.0f, baseVolume));
    
    if (ABS(_baseVolume - baseVolume) < 0.001f)
    {
        float previousVolume = self.volume;
        _baseVolume = baseVolume;
        self.volume = previousVolume;
    }
}

- (float)volume
{
    if (_timer)
    {
        return _targetVolume / _baseVolume;
    }
    else
    {
        return [_sound volume] / _baseVolume;
    }
}

- (void)setVolume:(float)volume
{
    volume = fminf(1.0f, fmaxf(0.0f, volume));
    
    if (_timer)
    {
        _targetVolume = volume * _baseVolume;
    }
    else
    {
        [_sound setVolume:volume * _baseVolume];
    }
}

#if SM_USE_AV_AUDIO_PLAYER

- (float)pan
{
    return [_sound pan];
}

- (void)setPan:(float)pan
{
    [_sound setPan:pan];
}

#else

- (float)pan
{
    return 0.0f;
}

- (void)setPan:(__unused float)pan
{
    //does nothing
}

#endif

- (NSTimeInterval)duration
{
    return [_sound duration];
}

- (NSTimeInterval)currentTime
{
    return [_sound currentTime];
}

- (void)setCurrentTime:(NSTimeInterval)currentTime
{
    [_sound setCurrentTime:currentTime];
}

- (BOOL)isLooping
{
    
#if SM_USE_AV_AUDIO_PLAYER
    return [_sound numberOfLoops] == -1;
#else
    return [_sound loops];
#endif
    
}

- (void)setLooping:(BOOL)looping
{
    
#if SM_USE_AV_AUDIO_PLAYER
    [_sound setNumberOfLoops:looping? -1: 0];
#else
    [_sound setLoops:looping];
#endif
    
}

- (BOOL)isPlaying
{
    return [_sound isPlaying];
}

- (void)play
{
    if (!self.playing)
    {
        self.selfReference = self;
        [_sound setDelegate:self];
        
        //play sound
        [_sound play];
    }
}

- (void)stop
{
    if (self.playing)
    {
        //stop playing
        [_sound stop];
        
        //stop timer
        [_timer invalidate];
        self.timer = nil;
        
        //fire events
        if (_completionHandler) _completionHandler(NO);
        [[NSNotificationCenter defaultCenter] postNotificationName:SoundDidFinishPlayingNotification object:self];
        
        //set to nil on next runloop update so sound is not released unexpectedly
        [self performSelectorOnMainThread:@selector(setSelfReference:) withObject:nil waitUntilDone:NO];
    }
}

#if SM_USE_AV_AUDIO_PLAYER
- (void)audioPlayerDidFinishPlaying:(__unused AVAudioPlayer *)player successfully:(BOOL)finishedPlaying
#else
- (void)sound:(__unused NSSound *)sound didFinishPlaying:(BOOL)finishedPlaying
#endif
{
    //stop timer
    [_timer invalidate];
    self.timer = nil;
    
    //fire events
    if (_completionHandler) _completionHandler(finishedPlaying);
    [[NSNotificationCenter defaultCenter] postNotificationName:SoundDidFinishPlayingNotification object:self];
    
    //set to nil on next runloop update so sound is not released unexpectedly
    [self performSelectorOnMainThread:@selector(setSelfReference:) withObject:nil waitUntilDone:NO];
}

- (void)fadeTo:(float)volume duration:(NSTimeInterval)duration
{
    _startVolume = [_sound volume];
    _targetVolume = volume * _baseVolume;
    _fadeTime = duration;
    _fadeStart = [[NSDate date] timeIntervalSinceReferenceDate];
    if (_timer == nil)
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
    [_sound setVolume:0.0f];
    [self fadeTo:1.0f duration:duration];
}

- (void)fadeOut:(NSTimeInterval)duration
{
    [self fadeTo:0.0f duration:duration];
}

- (void)tick
{
    NSTimeInterval now = [[NSDate date] timeIntervalSinceReferenceDate];
    float delta = (float)((now - _fadeStart)/_fadeTime * (_targetVolume - _startVolume));
    [_sound setVolume:(_startVolume + delta) * _baseVolume];
    if ((delta > 0.0f && [_sound volume] >= _targetVolume) ||
        (delta < 0.0f && [_sound volume] <= _targetVolume))
    {
        [_sound setVolume:_targetVolume * _baseVolume];
        [_timer invalidate];
        self.timer = nil;
        if ([_sound volume] == 0.0f)
        {
            [self stop];
        }
    }
}

- (void)dealloc
{
    [_timer invalidate];
}

@end


@interface SoundManager ()

@property (nonatomic, strong) Sound *currentMusic;
@property (nonatomic, strong) NSMutableArray *currentSounds;

@end


@implementation SoundManager

+ (instancetype)sharedManager
{
    static SoundManager *sharedManager = nil;
    if (sharedManager == nil)
    {
        sharedManager = [[self alloc] init];
    }
    return sharedManager;
}

- (instancetype)init
{
    if ((self = [super init]))
    {
        _soundVolume = 1.0f;
        _musicVolume = 1.0f;
        _soundFadeDuration = 1.0;
        _musicFadeDuration = 1.0;
        _currentSounds = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)setAllowsBackgroundMusic:(BOOL)allow
{
    if (_allowsBackgroundMusic != allow)
    {
        
#if TARGET_OS_IPHONE
        
        _allowsBackgroundMusic = allow;
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
        NSArray *extensions = @[@"caf", @"m4a", @"mp4", @"mp3", @"wav", @"aif"];
        NSArray *paths = nil;
        BOOL foundSound = NO;
        for (NSString *extension in extensions)
        {
            paths = [[NSBundle mainBundle] pathsForResourcesOfType:extension inDirectory:nil];
            if ([paths count])
            {
                [self prepareToPlayWithSound:paths[0]];
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
    if (![music.URL isEqual:_currentMusic.URL])
    {
        if (_currentMusic && _currentMusic.playing)
        {
            [_currentMusic fadeOut:_musicFadeDuration];
        }
        self.currentMusic = music;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(musicFinished:)
                                                     name:SoundDidFinishPlayingNotification
                                                   object:music];
        _currentMusic.looping = looping;
        _currentMusic.volume = fadeIn? 0.0f: _musicVolume;
        [_currentMusic play];
        if (fadeIn)
        {
            [_currentMusic fadeTo:_musicVolume duration:_musicFadeDuration];
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
        [_currentMusic fadeOut:_musicFadeDuration];
    }
    else
    {
        [_currentMusic stop];
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
    if (![_currentSounds containsObject:sound])
    {
        [_currentSounds addObject:sound];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(soundFinished:)
                                                     name:SoundDidFinishPlayingNotification
                                                   object:sound];
    }
    sound.looping = looping;
    sound.volume = fadeIn? 0.0f: _soundVolume;
    [sound play];
    if (fadeIn)
    {
        [sound fadeTo:_soundVolume duration:_soundFadeDuration];
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
            [(Sound *)soundOrName fadeOut:_soundFadeDuration];
        }
        else
        {
            [(Sound *)soundOrName stop];
        }
        [_currentSounds removeObject:soundOrName];
        return;
    }
    
    if ([[soundOrName pathExtension] isEqualToString:@""])
    {
        soundOrName = [soundOrName stringByAppendingPathExtension:@"caf"];
    }
    
    for (Sound *sound in [_currentSounds reverseObjectEnumerator])
    {
        if ([sound.name isEqualToString:soundOrName] || [[sound.URL path] isEqualToString:soundOrName])
        {
            if (fadeOut)
            {
                [sound fadeOut:_soundFadeDuration];
            }
            else
            {
                [sound stop];
            }
            [_currentSounds removeObject:sound];
        }
    }
}

- (void)stopSound:(id)soundOrName
{
    [self stopSound:soundOrName fadeOut:YES];
}

- (void)stopAllSounds:(BOOL)fadeOut
{
    for (Sound *sound in [_currentSounds reverseObjectEnumerator])
    {
        [self stopSound:sound fadeOut:fadeOut];
    }
}

- (void)stopAllSounds
{
    [self stopAllSounds:YES];
}

- (BOOL)isPlayingMusic
{
    return _currentMusic != nil;
}

- (void)setSoundVolume:(float)newVolume
{
    _soundVolume = newVolume;
    for (Sound *sound in _currentSounds)
    {
        sound.volume = _soundVolume;
    }
}

- (void)setMusicVolume:(float)newVolume
{
    _musicVolume = newVolume;
    _currentMusic.volume = _musicVolume;
}

- (void)soundFinished:(NSNotification *)notification
{
    Sound *sound = [notification object];
    [_currentSounds removeObject:sound];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:SoundDidFinishPlayingNotification
                                                  object:sound];
}

- (void)musicFinished:(NSNotification *)notification
{
    Sound *sound = [notification object];
    if (sound == _currentMusic)
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
}

@end
