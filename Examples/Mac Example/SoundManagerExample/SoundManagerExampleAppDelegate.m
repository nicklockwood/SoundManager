//
//  SoundManagerExampleAppDelegate.m
//  SoundManagerExample
//
//  Created by Nick Lockwood on 31/03/2011.
//  Copyright 2011 Charcoal Design. All rights reserved.
//

#import "SoundManagerExampleAppDelegate.h"

@implementation SoundManagerExampleAppDelegate

@synthesize window;
@synthesize switchTrackButton;
@synthesize trackIndex;

- (void)applicationDidFinishLaunching:(__unused NSNotification *)notification
{
    [[SoundManager sharedManager] prepareToPlay];
}

- (void)playMusic
{
    if (trackIndex == 0)
    {
        [[SoundManager sharedManager] playMusic:@"track1" looping:YES];
    }
    else
    {
        [[SoundManager sharedManager] playMusic:@"track2" looping:YES];
    }
}

- (IBAction)playPauseMusic:(NSButton *)sender
{
    if ([SoundManager sharedManager].playingMusic)
    {
        [[SoundManager sharedManager] stopMusic];
        [sender setTitle:@"Play Music"];
        [switchTrackButton setEnabled:NO];
    }
    else
    {
        [self playMusic];
        [sender setTitle:@"Pause Music"];
        [switchTrackButton setEnabled:YES];
    }
}

- (IBAction)switchTrack:(__unused NSButton *)sender
{
    trackIndex ++;
    trackIndex = trackIndex % 2;
    [self playMusic];
}

- (IBAction)playSound1:(__unused NSButton *)sender
{
    [[SoundManager sharedManager] playSound:@"sound1" looping:NO];
}

- (IBAction)playSound2:(__unused NSButton *)sender
{
    [[SoundManager sharedManager] playSound:@"sound2" looping:NO];
}

- (IBAction)setSoundVolume:(NSSlider *)sender
{
    [SoundManager sharedManager].soundVolume = [sender floatValue]/100.0;
}

- (IBAction)setMusicVolume:(NSSlider *)sender
{
    [SoundManager sharedManager].musicVolume = [sender floatValue]/100.0;
}

@end
