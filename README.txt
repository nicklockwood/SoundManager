Purpose
--------------

SoundManager is a simple class for playing sound and music in iPhone or Mac app store apps.


Installation
--------------

To use the SoundManager class in an app, just drag the class files into your project. For iOS apps you will also need to add the AVFoundation framework.


Classes
-------------

The SoundManager package defines two classes, the SoundManager class itself, which is documented below, and the Sound class, which is used as a wrapper around each sound file being played. The Sound class is not documented in this file as it is not intended to be used independently of the SoundManager, however its interface is fairly straightforward if you do wish to make use of it directly.


Configuration
--------------

FILE_EXTENSION - the default file extension for sounds when not specified.


Properties
--------------

@property (nonatomic, readonly) BOOL playingMusic;

This readonly property reports if the SoundManager is currently playing music.

@property (nonatomic, assign) BOOL allowsBackgroundMusic;

This property is used to control the audio session on the iPhone to allow iPod music to be played in the background. It defaults to NO, so it should be set to YES before you attempt to play any sound or music if you do not want the iPod music to be interrupted. It does nothing on Mac OS currently.

@property (nonatomic, assign) float soundVolume;

Sets the sound volume. Affects all currently playing sounds as well as any sounds played subsequently. Should be in the range 0 - 1.

@property (nonatomic, assign) float musicVolume;

Sets the music volume. Affects currently playing music track as well as any music tracks played subsequently. Should be in the range 0 - 1.

@property (nonatomic, assign) NSTimeInterval musicFadeDuration;

The fade in/out and crossfade duration for music tracks.

@property (nonatomic, assign) NSTimeInterval soundFadeDuration;

The fade out time for sounds when stopSound is called.


Methods
--------------

+ (SoundManager *)sharedManager;

This class method returns a shared singleton instance of the SoundManager.

- (void)prepareToPlay;

The prepareToPlay method preloads a random sound from your application bundle, which initialises the audio playback. It should be called before you attempt to play any audio, ideally during the startup sequence, to eliminate the delay when you first play a sound or music track.

- (void)playSound:(NSString *)name looping:(BOOL)looping;

The play method will load and play a sound from the application bundle whose filename matches the name passed. You can include the file extension in the name, or omit it, in which case the SoundManager will look for a matching file with the extension specified in the FILE_EXTENSION constant (defaults to .caf). If the looping argument is YES, the sound will continue to play until stopSound: is called.

- (void)stopSound:(NSString *)name;

This method will fade out the named sound over the period specified by soundFadeDuration. If there are multiple instances of the sound playing then they will all be stopped.

- (void)stopAllSounds;

This method will fade out all currently-playing sounds, but not music. It is equivalent to calling stopSound for each sound that is playing.

- (void)playMusic:(NSString *)name looping:(BOOL)looping;

This method plays a music track. The music will fade in from silent to the  volume specified by the musicVolume property over a period of time specified by musicFadeDuration. The sound manager only allows one music track to be played at a time, so if an existing track is playing it will be faded out. If the looping argument is YES, the music will continue to play until stopMusic is called.

- (void)stopMusic;

This will fade out the currently playing music track over the period specified by musicFadeDuration.


Notifications
---------------

SoundFinishedPlayingNotification

This notification is fired (via NSNotificationCenter) whenever a sound finishes playing, either due to it ending naturally, or because the stop method was called. The notification object is an instance of the Sound class, which is used internally by SoundManager to play sound and music files. You can access the Sound class's name property to find out which sound has finished.


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