# JustTheDogs

## Project Overview

**JustTheDogs** is a minimalist macOS menu bar application that delivers instant dog photos. It has been modernized to use SwiftUI's `MenuBarExtra`, efficient buffering, and a "Pure Dog" UI philosophy.

**Key Features:**
*   **Instant Gratification:** Images are buffered in the background, so the next dog is always ready 0ms after clicking.
*   **Pure Dog UI:** No buttons, no chrome. The window creates a borderless frame around the dog.
*   **User Control:**
    *   **Tap** the dog to refresh.
    *   **Right-Click** for Context Menu (Copy, Save to Downloads, Preferences, Quit).
    *   **Preferences:** Choose default window size (Small, Medium, Large) and toggle **Launch at Login**.
*   **Stealth Mode:** Runs as a pure menu bar accessory, hidden from the Dock.
*   **Responsive:** The window dynamically resizes to fit the dog's aspect ratio perfectly.

## Architecture & Technologies

*   **Language:** Swift 5.9+
*   **Frameworks:** SwiftUI, Observation Framework.
*   **Pattern:** MVVM (via `DogManager` and `@Observable`).
    *   `DogManager`: Handles buffering (`currentImage`, `nextImage`) and efficient network fetching.
    *   `ContentView`: The main UI. Handles layout calculations (`calculateFrame`), context menus, and lifecycle triggers.
    *   `SettingsView`: Manages user preferences via `@AppStorage`.
    *   `JustTheDogsApp`: The app entry point using `MenuBarExtra`.

## Building and Running

**Prerequisites:**
*   Xcode 15+ (Swift 5.9+)
*   macOS 14.0+ (Recommended for best `MenuBarExtra` support, supports 15.5)

**Via Xcode:**
1.  Open `JustTheDogs.xcodeproj`.
2.  Select the `JustTheDogs` scheme.
3.  Press `Cmd + R` to build and run.

**Manual Icon Note:**
Due to build system quirks, the App Icon is manually managed. If it disappears after a clean build:
1.  Run `swift make_icns.swift` to generate the `.iconset` folder.
2.  Run `iconutil -c icns build/AppIcon.iconset`.
3.  Copy `build/AppIcon.icns` to `JustTheDogs.app/Contents/Resources/`.
4.  Update `Info.plist` to set `CFBundleIconFile` to `AppIcon`.

## Development Conventions

*   **State:** Use `@Observable` for data models.
*   **Layout:** Allow the image to dictate window size via `calculateFrame`. Avoid fixed window sizes.
*   **Lifecycle:** Use `.onDisappear` to trigger background refreshes (`advanceToNextDog`).