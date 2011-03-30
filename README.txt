Purpose
--------------

SoundManager is a simple class for playing sound and music in iPhone or Mac app store apps.


Installation
--------------

To use the SoundManager class in an app, just drag the class files into your project. For iOS apps you will also need to add the AVFoundation framework.


Configuration
--------------

The SoundManager class has the following configuration constants:

FILE_EXTENSION - the default file extension for sounds when not specified.
CROSSFADE_DURATION - the crossfade duration between music tracks.
MUSIC_VOLUME - the volume at which to play music tracks.
SOUND_VOLUME - the volume at which to play sounds.


Properties
--------------

@property (nonatomic, readonly) BOOL playingMusic;

This readonly property reports if the SoundManager is currently playing music.

@property (nonatomic, assign) BOOL allowsBackgroundMusic;

This property is used to control the audio session on the iPhone to allow iPod music to be played in the background. It defaults to NO, so it should be set to YES before you attempt to play any sound or music if you do not want the iPod music to be interrupted. It does nothing on Mac OS currently.


Methods
--------------

+ (SoundManager *)sharedManager;

This class method returns a singleton instance of the SoundManager.

- (void)prepareToPlay;

The prepareToPlay method preloads a random sound from your application bundle, which initialises the AVAudioPlayer. It should be called before you attempt to play any audio, ideally during the startup sequence, to eliminate the delay when you first play a sound or music track. This method currently does nothing on Mac OS.

- (void)playSound:(NSString *)name;

The play method will load and play a sound from the application bundle whose filename matches the name passed. You can include the file extension in the name, or omit it, in which case the SoundManager will look for a matching file with the extension specified in the FILE_EXTENSION constant (defaults to .caf).

- (void)playMusic:(NSString *)name;

This method plays a music track. The music will fade in from silent to the  volume specified in MUSIC_VOLUME over a period of time specified by CROSSFADE_DURATION. The sound manager only allows one music track to be played at a time, so if an existing track is playing it will be faded out.

- (void)stopMusic;

This will fade out the currently playing music track over the period specified by CROSSFADE_DURATION.


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