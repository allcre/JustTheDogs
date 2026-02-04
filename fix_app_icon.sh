#!/bin/bash
set -e

CONFIG=${1:-Debug}
APP_PATH="./build/Build/Products/$CONFIG/JustTheDogs.app"
ICONSET_DIR="build/AppIcon.iconset"
ICNS_PATH="build/AppIcon.icns"

echo "🐶 JustTheDogs Icon Fixer 🐶"
echo "Targeting configuration: $CONFIG"

# 1. Generate the images using Swift
echo "Generating icon images..."
cat <<EOF > generate_icon_images.swift
import Cocoa

let fileManager = FileManager.default
let iconsetDir = "$ICONSET_DIR"

try? fileManager.removeItem(atPath: iconsetDir)
try? fileManager.createDirectory(atPath: iconsetDir, withIntermediateDirectories: true)

// Draw the dog icon
let size = CGSize(width: 1024, height: 1024)
let image = NSImage(size: size)
image.lockFocus()

// Background (White Squircle)
let rect = NSRect(origin: .zero, size: size)
let path = NSBezierPath(roundedRect: rect, xRadius: 200, yRadius: 200)
NSColor.white.setFill()
path.fill()

// Dog Symbol
if let symbol = NSImage(systemSymbolName: "dog.fill", accessibilityDescription: nil) {
    let tintColor = NSColor.darkGray
    let symbolConfig = NSImage.SymbolConfiguration(pointSize: 600, weight: .regular)
    let scaledSymbol = symbol.withSymbolConfiguration(symbolConfig) ?? symbol
    
    let dogSize = scaledSymbol.size
    let dogRect = NSRect(
        x: (size.width - dogSize.width) / 2,
        y: (size.height - dogSize.height) / 2,
        width: dogSize.width,
        height: dogSize.height
    )
    tintColor.set()
    let imageRect = NSRect(origin: .zero, size: dogSize)
    scaledSymbol.draw(in: dogRect, from: imageRect, operation: .sourceOver, fraction: 1.0)
}
image.unlockFocus()

// Save sizes
let sizes = [
    (16, "icon_16x16.png"),
    (32, "icon_16x16@2x.png"),
    (32, "icon_32x32.png"),
    (64, "icon_32x32@2x.png"),
    (128, "icon_128x128.png"),
    (256, "icon_128x128@2x.png"),
    (256, "icon_256x256.png"),
    (512, "icon_256x256@2x.png"),
    (512, "icon_512x512.png"),
    (1024, "icon_512x512@2x.png")
]

for (dim, name) in sizes {
    let newSize = CGSize(width: dim, height: dim)
    let newImage = NSImage(size: newSize)
    newImage.lockFocus()
    image.draw(in: NSRect(origin: .zero, size: newSize), from: NSRect(origin: .zero, size: size), operation: .copy, fraction: 1.0)
    newImage.unlockFocus()
    
    if let data = newImage.tiffRepresentation,
       let bitmap = NSBitmapImageRep(data: data),
       let png = bitmap.representation(using: .png, properties: [:]) {
        try? png.write(to: URL(fileURLWithPath: iconsetDir + "/" + name))
    }
}
EOF

swift generate_icon_images.swift
rm generate_icon_images.swift

# 2. Convert to ICNS
echo "Converting to ICNS..."
iconutil -c icns "$ICONSET_DIR"

# 3. Inject into App
echo "Injecting into $APP_PATH..."
if [ ! -d "$APP_PATH" ]; then
    echo "Error: App not found at $APP_PATH. Please build first."
    exit 1
fi

cp "$ICNS_PATH" "$APP_PATH/Contents/Resources/"

# 4. Update Info.plist
echo "Updating Info.plist..."
plutil -replace CFBundleIconFile -string "AppIcon" "$APP_PATH/Contents/Info.plist"
# Force Hide Dock Icon (LSUIElement)
plutil -replace LSUIElement -bool true "$APP_PATH/Contents/Info.plist"

# 5. Re-sign App (Crucial fix for crash)
echo "Re-signing application..."
codesign --force --deep --sign - "$APP_PATH"

echo "✅ Done! Icon injected and app re-signed."
echo "Try running: open $APP_PATH"
