import Cocoa

let size = CGSize(width: 600, height: 400)
let image = NSImage(size: size)

image.lockFocus()

// 1. Background Color (Light Gray / White)
NSColor(white: 0.95, alpha: 1.0).setFill()
NSBezierPath(rect: NSRect(origin: .zero, size: size)).fill()

// 2. Draw Text "Drag to Applications"
let text = "Drag to Applications" as NSString
let font = NSFont.systemFont(ofSize: 24, weight: .bold)
let attrs: [NSAttributedString.Key: Any] = [
    .font: font,
    .foregroundColor: NSColor.darkGray
]
let textSize = text.size(withAttributes: attrs)
let textRect = NSRect(
    x: (size.width - textSize.width) / 2,
    y: size.height - 120, // Position near top
    width: textSize.width,
    height: textSize.height
)
text.draw(in: textRect, withAttributes: attrs)

// 3. Draw Arrow
// Simple arrow pointing right
let arrowPath = NSBezierPath()
let startX: CGFloat = 260
let startY: CGFloat = 200
let arrowLen: CGFloat = 80
let arrowHead: CGFloat = 15

NSColor.gray.setStroke()
arrowPath.lineWidth = 4
arrowPath.move(to: NSPoint(x: startX, y: startY))
arrowPath.line(to: NSPoint(x: startX + arrowLen, y: startY))
arrowPath.stroke()

let arrowHeadPath = NSBezierPath()
NSColor.gray.setFill()
arrowHeadPath.move(to: NSPoint(x: startX + arrowLen, y: startY))
arrowHeadPath.line(to: NSPoint(x: startX + arrowLen - arrowHead, y: startY + arrowHead/2))
arrowHeadPath.line(to: NSPoint(x: startX + arrowLen - arrowHead, y: startY - arrowHead/2))
arrowHeadPath.close()
arrowHeadPath.fill()

image.unlockFocus()

// Save
if let tiff = image.tiffRepresentation,
   let bitmap = NSBitmapImageRep(data: tiff),
   let png = bitmap.representation(using: .png, properties: [:]) {
    let url = URL(fileURLWithPath: "build/dmg_background.png")
    try? png.write(to: url)
    print("Generated DMG background at \(url.path)")
}
