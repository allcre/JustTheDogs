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
2.  Download `JustTheDogs.dmg`.
3.  Open the DMG and drag **JustTheDogs** into the **Applications** folder.

### "Unverified Developer" Warning?
Because this app is open-source and not signed with a $99/year Apple ID, macOS might block it. To open it:
1.  **Right-click** (or Control-click) the app in your Applications folder.
2.  Select **Open**.
3.  Click **Open** in the dialog box.
*(You only need to do this once.)*

### Still Blocked? ("App is damaged")
If macOS says the app is damaged or refuses to open, run this command in Terminal to remove the quarantine attribute:
```bash
xattr -cr /Applications/JustTheDogs.app
```

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
To create a distributable `.dmg` installer:
```bash
# 1. Build Release Version
xcodebuild -project JustTheDogs.xcodeproj -scheme JustTheDogs -configuration Release -derivedDataPath ./build clean build

# 2. Patch Icon
./fix_app_icon.sh Release

# 3. Create DMG
./package_dmg.sh
```

## Credits
Developed by Allison.
Uses the [Dog CEO API](https://dog.ceo/dog-api/).
