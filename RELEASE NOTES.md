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