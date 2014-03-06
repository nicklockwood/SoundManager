//
//  SoundManagerExampleViewController.m
//  SoundManagerExample
//
//  Created by Nick Lockwood on 31/03/2011.
//  Copyright 2011 Charcoal Design. All rights reserved.
//

#import "SoundManagerExampleViewController.h"

@implementation SoundManagerExampleViewController

- (void)viewDidLoad
{
    [SoundManager sharedManager].allowsBackgroundMusic = YES;
    [[SoundManager sharedManager] prepareToPlay];
}

- (void)playMusic
{
    if (self.trackIndex == 0)
    {
        [[SoundManager sharedManager] playMusic:@"track1" looping:YES];
    }
    else
    {
        [[SoundManager sharedManager] playMusic:@"track2" looping:YES];
    }
}

- (IBAction)playPauseMusic:(UIButton *)sender
{
    if ([SoundManager sharedManager].playingMusic)
    {
        [[SoundManager sharedManager] stopMusic];
        [sender setTitle:@"Play Music" forState:UIControlStateNormal];
        self.switchTrackButton.enabled = NO;
        self.switchTrackButton.alpha = 0.5;
    }
    else
    {
        [self playMusic];
        [sender setTitle:@"Pause Music" forState:UIControlStateNormal];
        self.switchTrackButton.enabled = YES;
        self.switchTrackButton.alpha = 1.0;
    }
}

- (IBAction)switchTrack:(__unused UIButton *)sender
{
    self.trackIndex ++;
    self.trackIndex %= 2;
    [self playMusic];
}

- (IBAction)playSound1:(__unused UIButton *)sender
{
    [[SoundManager sharedManager] playSound:@"sound1" looping:NO];
}

- (IBAction)playSound2:(__unused UIButton *)sender
{
    [[SoundManager sharedManager] playSound:@"sound2" looping:NO];
}

- (IBAction)setSoundVolume:(UISlider *)sender
{
    [SoundManager sharedManager].soundVolume = sender.value;
}

- (IBAction)setMusicVolume:(UISlider *)sender
{
    [SoundManager sharedManager].musicVolume = sender.value;
}

@end
