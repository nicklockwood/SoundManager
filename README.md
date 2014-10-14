Purpose
--------------

SoundManager is a simple class for playing sound and music in iOS or Mac apps.


Supported OS & SDK Versions
-----------------------------

* Supported build target - iOS 8.0 / Mac OS 10.8 (Xcode 6.0, Apple LLVM compiler 6.0)
* Earliest supported deployment target - iOS 6.0 / Mac OS 10.7
* Earliest compatible deployment target - iOS 4.3 / Mac OS 10.6 (64 bit)

NOTE: 'Supported' means that the library has been tested with this version. 'Compatible' means that the library should work on this iOS version (i.e. it doesn't rely on any unavailable SDK features) but is no longer being tested for compatibility and may require tweaking or bug fixes to run correctly.


ARC Compatibility
------------------

As of version 1.4, SoundManager requires ARC. If you wish to use SoundManager in a non-ARC project, just add the -fobjc-arc compiler flag to the SoundManager.m class. To do this, go to the Build Phases tab in your target settings, open the Compile Sources group, double-click iRate.m in the list and type -fobjc-arc into the popover.

If you wish to convert your whole project to ARC, comment out the #error line in SoundManager.m, then run the Edit > Refactor > Convert to Objective-C ARC... tool in Xcode and make sure all files that you wish to use ARC for (including SoundManager.m) are checked.


Installation
--------------

To use the SoundManager class in an app, just drag the class files into your project. For iOS apps, or Mac OS apps with a deployment target of 10.7 (Lion) or above you will also need to add the AVFoundation framework.


Classes
-------------

The SoundManager package defines two classes, the SoundManager class itself, which is documented below, and the Sound class, which is used as a wrapper around each sound file being played. The Sound class can be used either directly or with the SoundManager class.


Sound properties
-------------------

    @property (nonatomic, readonly, copy) NSString *name;
    
The name of the sound. This is either the name that was passed to the `soundNamed:` constructor method, or the last path component of the sound file.
    
    @property (nonatomic, readonly, strong) NSURL *URL;
    
The absolute URL of the sound file.

    @property (nonatomic, readonly) NSTimeInterval duration;
    
The duration (in seconds) of the sound file.

    @property (nonatomic, assign) NSTimeInterval currentTime;
    
The current time offset (in seconds) of the sound file. This value is readwrite, so you can (for example) set it to zero to rewind the sound.
    
    @property (nonatomic, readonly, getter = isPlaying) BOOL playing;
    
Returns YES if the sound is currently playing and NO if it isn't (read only).
    
    @property (nonatomic, assign, getter = isLooping) BOOL looping;
    
Returns YES if the sound has been set to loop, and NO if it hasn't.
    
    @property (nonatomic, copy) SoundCompletionHandler completionHandler;
    
A callback block that will be called when the sound finishes playing, or is stopped. Only one completionHandler block can be set on any given Sound instance, but if you need multiple objects to track the Sound's status, you can add observers for the `SoundDidFinishPlayingNotification` notification instead. 
    
    @property (nonatomic, assign) float baseVolume;
    
The maximum volume of the sound. Some sounds are louder than others and it can be annoying trying to manage the volumes of different sounds in your app individually in code. The baseVolume property allows you to equalise the volumes of different sounds on creation, then you can adjust their volumes consistently from that point on.
    
    @property (nonatomic, assign) float volume;
    
The sound volume. This is multiplied by the baseVolume property to get the actual volume. Defaults to 1.0 (maximum).

    @property (nonatomic, assign) float pan;
    
The left/right stereo pan of the file. Value ranges from -1.0 to 1.0 and can be used to shift the location of the sound in space. Has no effect on Mac OS 10.6.


Sound methods
-------------------

    + (Sound *)soundNamed:(NSString *)name;
    
This is a handy shorthand constructor method that returns a sound based on the name of a file in the application bundle. If the file extension is omitted, it is assumed to be a .caf file. If you pass a fully-qualified path to this method then it behaves the same way as `soundWithContentsOfFile:`.
    
    + (Sound *)soundWithContentsOfFile:(NSString *)path;
    - (Sound *)initWithContentsOfFile:(NSString *)path;
    + (Sound *)soundWithContentsOfURL:(NSURL *)URL;
    - (Sound *)initWithContentsOfURL:(NSURL *)URL;
    
These methods create a new Sound instance from a file path or URL.

    - (void)fadeTo:(float)volume duration:(NSTimeInterval)duration;
    
This method fades a sound from it's current volume to the specified volume over the specified time period. Note that this method will not play the sound, so you will need to call `play` prior to calling this method, unless the sound is already playing.
    
    - (void)fadeIn:(NSTimeInterval)duration;
    
Fades the sound volume from 0.0 to 1.0 over the specified duration. The sound volume will be set to zero if it not already. See the caveat above about sounds that aren't playing.
    
    - (void)fadeOut:(NSTimeInterval)duration;
    
Fades the sound from it's current volume to 0.0 over the specified duration. When the sound volume reaches zero, the sound's stop method is automatically called.
    
    - (void)play;
    
Plays the sound. Has no effect if the sound is already playing.
    
    - (void)stop;

Stops the sound. Has no effect if the sound is not already playing. Stopping the sound does not reset the currentTime, so playing a stopeed sound will resume from the last played time.


SoundManager properties
--------------------------

	@property (nonatomic, readonly, getter = isPlayingMusic) BOOL playingMusic;

This readonly property reports if the SoundManager is currently playing music.

	@property (nonatomic, assign) BOOL allowsBackgroundMusic;

This property is used to control the audio session on the iPhone to allow iPod music to be played in the background. It defaults to NO, so it should be set to YES before you attempt to play any sound or music if you do not want the iPod music to be interrupted. It does nothing on Mac OS currently.

	@property (nonatomic, assign) float soundVolume;

Sets the sound volume. Affects all currently playing sounds as well as any sounds played subsequently. Should be in the range 0 - 1.

	@property (nonatomic, assign) float musicVolume;

Sets the music volume. Affects currently playing music track as well as any music tracks played subsequently. Should be in the range 0 - 1.

	@property (nonatomic, assign) NSTimeInterval musicFadeDuration;

The fade in/out and crossfade duration for music tracks (defaults to 1 second).

	@property (nonatomic, assign) NSTimeInterval soundFadeDuration;

The fade out time for sounds when stopSound is called (defaults to 1 second).


SoundManager methods
------------------------

	+ (SoundManager *)sharedManager;

This class method returns a shared singleton instance of the SoundManager.

	- (void)prepareToPlay;

The `prepareToPlay` method preloads a random sound from your application bundle, which initialises the audio playback. It should be called before you attempt to play any audio, ideally during the startup sequence, to eliminate the delay when you first play a sound or music track. *Note:* this will only work if at least one sound file is included in the root of your application bundle. If all of your sound files are in folders, consider adding an additional short, silent sound file for initialisation purposes, or use the `prepareToPlayWithSound:` method instead.

    - (void)prepareToPlayWithSound:(id)soundOrName;

If your sounds are not located in the root of the application bundle (or even in the bundles at all) then the standard `prepareToPlay` method won't work. In this case you can use the `prepareToPlayWithSound:` method instead and specify a particular sound to use for initialisation. The parameter can be a filename, path (either relative or absolute) or an instance of the Sound class.

    - (void)playSound:(id)soundOrName looping:(BOOL)looping fadeIn:(BOOL)fadeIn;
    - (void)playSound:(id)soundOrName looping:(BOOL)looping;
	- (void)playSound:(id)soundOrName;

The play method will play a sound. The parameter can be either a previously created Sound instance, or a name or path for a sound file to be loaded. You can include the file extension in the name, or omit it, in which case the SoundManager will look for a matching file with the .caf file extension. If the looping argument is YES, the sound will continue to play until stopSound: is called. If the fadeIn argument is YES, the sound will fade in from zero to full volume over the time specified by the `soundFadeDuration` property of the SoundManager class. If omitted, looping and fadeIn both default to NO.

	- (void)stopSound:(id)soundOrName fadeOut:(BOOL)fadeOut;
    - (void)stopSound:(id)soundOrName;

This method will either stop the sound immediately, or fade it out over the period specified by `soundFadeDuration`, depending on the fadeOut argument (defaults to YES). The soundOrName parameter can be either a previously created Sound instance, or a name or path. If there are multiple instances of the sound playing then they will all be stopped.

    - (void)stopAllSounds:(BOOL)fadeOut;
	- (void)stopAllSounds;

This method will stop and/or fade out all currently-playing sounds, but not music. It is equivalent to calling `stopSound` for each sound that is playing.

	- (void)playMusic:(id)soundOrName looping:(BOOL)looping fadeIn:(BOOL)fadeIn;
    - (void)playMusic:(id)soundOrName looping:(BOOL)looping;
    - (void)playMusic:(id)soundOrName;

This method plays a music track. If the fadeIn argument is YES, the music will fade in from silent to the volume specified by the musicVolume property over a period of time specified by `musicFadeDuration` (defaults to YES if omitted). The sound manager only allows one music track to be played at a time, so if an existing track is playing it will be faded out. If the looping argument is YES, the music will continue to play until `stopMusic` is called (defaults to YES if omitted).

    - (void)stopMusic:(BOOL)fadeOut;
	- (void)stopMusic;

This will stop and/or fade out the currently playing music track over the period specified by `musicFadeDuration`.


Notifications
---------------

	SoundDidFinishPlayingNotification

This notification is fired (via NSNotificationCenter) whenever a sound finishes playing, either due to it ending naturally, or because the stop method was called. The notification object is an instance of the Sound class, which is used internally by SoundManager to play sound and music files. You can access the Sound class's `name` property to find out which sound has finished.


Supported Formats
-------------------

The iPhone can be quite picky about which sounds it will play. For best results, 
use .caf files, which you can generate using the afconvert command line tool. Here are some common configurations:

For background music (mono):

	/usr/bin/afconvert -f caff -d aac -c 1 {input_file_name} {output_file_name}.caf

For background music (stereo):

	/usr/bin/afconvert -f caff -d aac {input_file_name} {output_file_name}.caf

For sound effects (mono):

	/usr/bin/afconvert -f caff -d ima4 -c 1 {input_file_name} {output_file_name}.caf

For sound effects (stereo):

	/usr/bin/afconvert -f caff -d ima4 {input_file_name} {output_file_name}.caf
	
	
Release Notes
-------------------

Version 1.4.2

- Fixed import error in Xcode 6

Version 1.4.1

- SoundCompletionHandler block no longer returns NO for didFinish when sound finished playing correctly
- Now conforms to -Weverything warning level

Version 1.4

- Added duration and currentTime properties
- Added pan property
- Fixed crash due to modifying array during enumeration
- stopMusic method now respects the fadeOut property
- Now requires ARC
- Now requires a 64 bit processor on Mac OS
- Now conforms to -Wall and -Wextra warning levels
- Added podspec

Version 1.3.1

- For Mac OS projects with a deployment target of Mac OS 10.7 (Lion) or above, SoundManager now uses AVAudioPlayer instead of NSSound

Version 1.3

- Added block-based completion handler callback for Sound class
- Sound manager can now play sounds either by name or by object reference
- Extended SoundManager class with additional fading options
- Can now preload sounds that are not in the root application bundle

Version 1.2.1

- The `prepareToPlay` method no longer crashes if the project includes no sound files

Version 1.2

- Added automatic support for ARC compile targets
- Now requires Apple LLVM 3.0 compiler target
- playing, looping and playingMusic properties now use more standard getter names
- Sound class initialisers refactored to match iOS conventions
- Sound name method now returns name including file extension

Version 1.1.3

- Fixed bug where preloading only worked with .caf files.
- Renamed `FILE_EXTENSION` to `DEFAULT_FILE_EXTENSION` to avoid confusion.

Version 1.1.2

- Fixed occasional crash due to accessing sound after it is released
- Sound manager will now log a warning to the console when passed a non-existent sound file instead of crashing
- Sound names can now include directory separators. This means that sounds in subfolders of the resource folder can be played using the standard play functions.

Version 1.1.1

- Fixed bugs with music fading
- Changed default music fade/crossfade duration to 1 seconds
- Exposed looping property on Sound class
- Changed documentation and licence to markdown format

Version 1.1

- Added looping argument to play methods
- Added stopSound and stopAllSounds methods
- Implemented preloading for Mac OS

Version 1.0

- Initial release