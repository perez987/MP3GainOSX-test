MP3GainOSX-test
==========

MP3Gain Express for macOS.

## Credits

Based on:

- MP3Gain by *Glen Sawyer* with AACGain by *David Lasker*
- mp3gainOSX (macOS Express version) by *Paul Kratt*

## Test repository

This is a repository for testing GitHub releases updater.

Instead of the widely used Sparkle, it is completely replaced with a minimal custom updater that calls the GitHub versioning API and opens the browser for manual download.

### Approach

- No auto-install: the checker opens `github.com/perez987/MP3GainOSX-test/releases/latest` in the browser when the user clicks "Download Update"
- No framework dependency: uses only NSURLSession, NSAlert, and NSWorkspace (zero third-party code).
