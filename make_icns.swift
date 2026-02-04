import Foundation

let fileManager = FileManager.default
let sourceDir = "JustTheDogs/Assets.xcassets/AppIcon.appiconset"
let iconsetDir = "build/AppIcon.iconset"

try? fileManager.removeItem(atPath: iconsetDir)
try? fileManager.createDirectory(atPath: iconsetDir, withIntermediateDirectories: true)

// Map existing files to iconset names
let mapping = [
    "icon_16.png": "icon_16x16.png",
    "icon_32.png": "icon_16x16@2x.png", // 32 is 16@2x
    // "icon_32.png": "icon_32x32.png", // duplicate? No, copy again.
    "icon_64.png": "icon_32x32@2x.png",
    "icon_128.png": "icon_128x128.png",
    "icon_256.png": "icon_128x128@2x.png",
    // "icon_256.png": "icon_256x256.png",
    "icon_512.png": "icon_256x256@2x.png",
    // "icon_512.png": "icon_512x512.png",
    "icon_1024.png": "icon_512x512@2x.png"
]

// Also need standard sizes
let extraMapping = [
    "icon_32.png": "icon_32x32.png",
    "icon_256.png": "icon_256x256.png",
    "icon_512.png": "icon_512x512.png"
]

for (src, dest) in mapping {
    let srcPath = "\(sourceDir)/\(src)"
    let destPath = "\(iconsetDir)/\(dest)"
    try? fileManager.copyItem(atPath: srcPath, toPath: destPath)
}
for (src, dest) in extraMapping {
    let srcPath = "\(sourceDir)/\(src)"
    let destPath = "\(iconsetDir)/\(dest)"
    try? fileManager.copyItem(atPath: srcPath, toPath: destPath)
}

print("Created iconset at \(iconsetDir)")
