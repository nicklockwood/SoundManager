//
//  SoundManagerExampleAppDelegate.h
//  SoundManagerExample
//
//  Created by Nick Lockwood on 31/03/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SoundManager.h"

@interface SoundManagerExampleAppDelegate : NSObject <NSApplicationDelegate> {
@private
    NSWindow *window;
    NSButton *switchTrackButton;
    NSUInteger trackIndex;
}

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSButton *switchTrackButton;
@property (assign) NSUInteger trackIndex;

- (IBAction)playPauseMusic:(NSButton *)sender;
- (IBAction)switchTrack:(NSButton *)sender;
- (IBAction)playSound1:(NSButton *)sender;
- (IBAction)playSound2:(NSButton *)sender;
- (IBAction)setSoundVolume:(NSSlider *)sender;
- (IBAction)setMusicVolume:(NSSlider *)sender;

@end
