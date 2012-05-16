Purpose
--------------

SoundManager is a simple class for playing sound and music in iOS or Mac apps.


Supported OS & SDK Versions
-----------------------------

* Supported build target - iOS 5.1 / Mac OS 10.7 (Xcode 4.3, Apple LLVM compiler 3.1)
* Earliest supported deployment target - iOS 4.3 / Mac OS 10.6
* Earliest compatible deployment target - iOS 3.0 / Mac OS 10.6

NOTE: 'Supported' means that the library has been tested with this version. 'Compatible' means that the library should work on this iOS version (i.e. it doesn't rely on any unavailable SDK features) but is no longer being tested for compatibility and may require tweaking or bug fixes to run correctly.


ARC Compatibility
------------------

As of version 1.2, SoundManager automatically works with both ARC and non-ARC projects through conditional compilation. There is no need to exclude SoundManager files from the ARC validation process, or to convert SoundManager using the ARC conversion tool.


Installation
--------------

To use the SoundManager class in an app, just drag the class files into your project. For iOS apps you will also need to add the AVFoundation framework.


Classes
-------------

The SoundManager package defines two classes, the SoundManager class itself, which is documented below, and the Sound class, which is used as a wrapper around each sound file being played. The Sound class can be used either directly or with the SoundManager class.


Sound properties
-------------------

    @property (nonatomic, readonly, copy) NSString *name;
    
The name of the sound. This is either the name that was passed to the `soundNamed:` constructor method, or the last path component of the sound file.
    
    @property (nonatomic, readonly, strong) NSURL *url;
    
The absolute URL of the sound file.
    
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


Sound methods
-------------------

    + (Sound *)soundNamed:(NSString *)name;
    
This is a handy shorthand constructor method that returns a sound based on the name of a file in the application bundle. If the file extension is omitted, it is assumed to be a .caf file. If you pass a fully-qualified path to this method then it behaves the same way as `soundWithContentsOfFile:`.
    
    + (Sound *)soundWithContentsOfFile:(NSString *)path;
    - (Sound *)initWithContentsOfFile:(NSString *)path;
    + (Sound *)soundWithContentsOfURL:(NSURL *)url;
    - (Sound *)initWithContentsOfURL:(NSURL *)url;
    
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

Stops the sound. Has no effect if the sound is not already playing.


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