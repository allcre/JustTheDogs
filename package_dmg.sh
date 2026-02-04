#!/bin/bash
set -e

APP_NAME="JustTheDogs"
APP_BUNDLE="./build/Build/Products/Release/$APP_NAME.app"
DMG_NAME="$APP_NAME.dmg"

# 1. Check if Release build exists
if [ ! -d "$APP_BUNDLE" ]; then
    echo "Error: Release build not found. Please run build command first."
    exit 1
fi

# 2. Cleanup old DMG

rm -f "$DMG_NAME"



# 3. Generate Background

echo "Generating DMG background..."

swift generate_dmg_background.swift



# 4. Create DMG using create-dmg
echo "Creating polished $DMG_NAME..."

create-dmg --volname "$APP_NAME" --volicon "build/AppIcon.icns" --background "build/dmg_background.png" --window-pos 200 120 --window-size 600 400 --icon-size 100 --icon "$APP_NAME.app" 150 200 --hide-extension "$APP_NAME.app" --app-drop-link 450 200 "$DMG_NAME" "$APP_BUNDLE"

echo "✅ DMG Created: $DMG_NAME"
