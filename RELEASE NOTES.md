Version 1.1.3

- Fixed bug where preloading only worked with .caf files.
- Renamed FILE_EXTENSION to DEFAULT_FILE_EXTENSION to avoid confusion.

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