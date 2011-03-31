//
//  SoundManagerExampleViewController.m
//  SoundManagerExample
//
//  Created by Nick Lockwood on 31/03/2011.
//  Copyright 2011 Charcoal Design. All rights reserved.
//

#import "SoundManagerExampleViewController.h"

@implementation SoundManagerExampleViewController

@synthesize switchTrackButton;
@synthesize trackIndex;

- (void)viewDidLoad
{
    [SoundManager sharedManager].allowsBackgroundMusic = YES;
    [[SoundManager sharedManager] prepareToPlay];
}

- (void)playMusic
{
    if (trackIndex == 0)
    {
        [[SoundManager sharedManager] playMusic:@"track1"];
    }
    else
    {
        [[SoundManager sharedManager] playMusic:@"track2"];
    }
}

- (IBAction)playPauseMusic:(UIButton *)sender
{
    if ([SoundManager sharedManager].playingMusic)
    {
        [[SoundManager sharedManager] stopMusic];
        [sender setTitle:@"Play Music" forState:UIControlStateNormal];
        switchTrackButton.enabled = NO;
        switchTrackButton.alpha = 0.5;
    }
    else
    {
        [self playMusic];
        [sender setTitle:@"Pause Music" forState:UIControlStateNormal];
        switchTrackButton.enabled = YES;
        switchTrackButton.alpha = 1.0;
    }
}

- (IBAction)switchTrack:(UIButton *)sender
{
    trackIndex ++;
    trackIndex = trackIndex % 2;
    [self playMusic];
}

- (IBAction)playSound1:(UIButton *)sender
{
    [[SoundManager sharedManager] playSound:@"sound1"];
}

- (IBAction)playSound2:(UIButton *)sender
{
    [[SoundManager sharedManager] playSound:@"sound2"];
}

- (void)dealloc
{
    [switchTrackButton release];
    [super dealloc];
}

@end
