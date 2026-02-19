# Multi-Language Support

MP3Gain Express now supports multiple languages with automatic detection based on macOS system language preferences.

## Supported Languages

- **English (en)** - Base language
- **Spanish (es)** - Español

## How It Works

The application automatically detects the user's preferred language from macOS System Preferences. No language selector is needed within the application.

### Language Selection Priority

1. The app checks the user's language preferences in macOS (System Preferences > Language & Region)
2. If the preferred language is one of the supported languages, the app uses that language
3. If the preferred language is not supported, the app falls back to English (the base language)

### Testing Different Languages

To test the application in different languages:

1. Go to **System Preferences** > **Language & Region**
2. Add the desired language to the list if not already present
3. Drag the language to the top of the list to make it the preferred language
4. Restart the application

The application will automatically load the appropriate translations.

## Technical Implementation

### File Structure

```
MP3GainExpress/
├── en.lproj/
│   ├── Localizable.strings  (English translations)
│   └── MainMenu.xib         (Interface file)
├── es.lproj/
    ├── Localizable.strings  (Spanish translations)
    └── MainMenu.strings     (Spanish UI translations)
```

### Localization Keys

All user-facing strings in the application use `NSLocalizedString()` for programmatic strings and are defined in the `Localizable.strings` files.

UI elements defined in the XIB files are localized using the `MainMenu.strings` files in each `.lproj` directory.

### Info.plist Configuration

The `Info.plist` file includes:

- `CFBundleDevelopmentRegion`: Set to "en" (English as default)
- `CFBundleLocalizations`: Array listing all supported language codes

This ensures macOS properly recognizes all available localizations.

### Xcode Project Configuration

The MainMenu.strings files must be properly registered in the Xcode project file (`project.pbxproj`) as variants of the MainMenu.xib resource:

1. Each MainMenu.strings file is added as a `PBXFileReference`
2. These references are added to the `PBXVariantGroup` for MainMenu.xib
3. This allows the build system to properly package the localizations

Without this configuration, the MainMenu.strings files would exist on disk but wouldn't be used at runtime, causing the main window and preferences window to remain in English regardless of the system language.

## Adding New Languages

To add support for a new language:

1. Create a new `.lproj` directory (e.g., `fr.lproj` for French)
2. Create `Localizable.strings` with all translated strings
3. Create `MainMenu.strings` with UI element translations
4. Update `MP3GainExpress-Info.plist` to include the new language code in `CFBundleLocalizations`
5. Update the Xcode project file (`project.pbxproj`):
   - Add a `PBXFileReference` for both the new `Localizable.strings` and `MainMenu.strings`
   - Add these references to their respective `PBXVariantGroup` sections
   - Add the language code to `knownRegions`
6. Build and test in Xcode to verify the localization works correctly

## Fallback Behavior

If a translation is missing for a specific string in the user's selected language, the application will fall back to the English translation. This ensures that no text appears untranslated or as a raw key.
