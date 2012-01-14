//
//  SoundManagerExampleViewController.h
//  SoundManagerExample
//
//  Created by Nick Lockwood on 31/03/2011.
//  Copyright 2011 Charcoal Design. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SoundManager.h"


@interface SoundManagerExampleViewController : UIViewController

@property (nonatomic, retain) IBOutlet UIButton *switchTrackButton;
@property (nonatomic, assign) NSUInteger trackIndex;

- (IBAction)playPauseMusic:(UIButton *)sender;
- (IBAction)switchTrack:(UIButton *)sender;
- (IBAction)playSound1:(UIButton *)sender;
- (IBAction)playSound2:(UIButton *)sender;
- (IBAction)setSoundVolume:(UISlider *)sender;
- (IBAction)setMusicVolume:(UISlider *)sender;

@end
