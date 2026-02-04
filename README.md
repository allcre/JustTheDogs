# JustTheDogs

A macOS menu bar application for displaying random dog images.

<img width="1440" height="900" alt="JustTheDogs Screenshot" src="https://github.com/user-attachments/assets/6e801fb4-0f27-4465-b0ad-2f0bd2274f56" />

## Features

- **MenuBarExtra Integration:** Operates as a background accessory app without a Dock icon.
- **Image Buffering:** Pre-fetches the next image in the background to ensure immediate display on interaction.
- **Dynamic Layout:** The window dimensions adjust to match the source image aspect ratio.
- **User Interactions:**
    - Click image: Refresh content.
    - Right-click image: Context menu (Copy to clipboard, Save to Downloads, Preferences, Quit).
- **Settings:** Persistent window size configuration (Small, Medium, Large) and "Launch at Login" support.
- **Onboarding:** Displays a one-time overlay explaining controls and credits.

## Tech Stack

- **Swift 5.9+ / SwiftUI**
- **Observation Framework** for state management.
- **ServiceManagement (SMAppService)** for login item registration.
- **Dog CEO API** for image sourcing.

## Installation

### Download App
1.  Go to the [Releases](https://github.com/yourusername/JustTheDogs/releases) page.
2.  Download `JustTheDogs.zip`.
3.  Unzip and drag `JustTheDogs.app` to your Applications folder.
4.  **Note:** Since this app is not notarized by Apple, you may need to right-click the app and select **Open** the first time you run it.

## Development

### Requirements
- Xcode 15+
- macOS 14.0+

### Building via Xcode
1. Open `JustTheDogs.xcodeproj`.
2. Run the `JustTheDogs` scheme (`Cmd + R`).

### Building via CLI
```bash
xcodebuild -project JustTheDogs.xcodeproj -scheme JustTheDogs -configuration Debug -derivedDataPath ./build
```

**Note:** Clean builds will overwrite the app icon. To restore it, run:
```bash
./fix_app_icon.sh
```

### Packaging for Distribution
To create a distributable `.zip` file:
```bash
# 1. Build Release Version
xcodebuild -project JustTheDogs.xcodeproj -scheme JustTheDogs -configuration Release -derivedDataPath ./build clean build

# 2. Patch Icon
./fix_app_icon.sh Release

# 3. Zip it
cd build/Build/Products/Release
zip -r ../../../JustTheDogs.zip JustTheDogs.app
```

## Credits
Uses the [Dog CEO API](https://dog.ceo/dog-api/).
