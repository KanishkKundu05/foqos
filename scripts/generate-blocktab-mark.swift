// Generates the Blocktab vector mark as PNG for Apple's icon and image catalogs.
// Run from the repository root: swift scripts/generate-blocktab-mark.swift
import AppKit

let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
let size = NSSize(width: 1024, height: 1024)
let image = NSImage(size: size)
image.lockFocus()
NSColor(calibratedRed: 0.87, green: 0.87, blue: 0.83, alpha: 1).setFill()
NSBezierPath(
  roundedRect: NSRect(x: 120, y: 120, width: 784, height: 784), xRadius: 180, yRadius: 180
).fill()
NSColor(calibratedRed: 0.4, green: 0.45, blue: 0.33, alpha: 1).setStroke()
let border = NSBezierPath(
  roundedRect: NSRect(x: 155, y: 155, width: 714, height: 714), xRadius: 150, yRadius: 150)
border.lineWidth = 8
border.stroke()
let paragraph = NSMutableParagraphStyle()
paragraph.alignment = .center
let attributes: [NSAttributedString.Key: Any] = [
  .font: NSFont.systemFont(ofSize: 135, weight: .bold),
  .foregroundColor: NSColor(calibratedRed: 0.28, green: 0.32, blue: 0.24, alpha: 1),
  .paragraphStyle: paragraph,
]
("Blocktab" as NSString).draw(
  in: NSRect(x: 130, y: 390, width: 764, height: 180), withAttributes: attributes)
NSColor(calibratedRed: 0.4, green: 0.45, blue: 0.33, alpha: 1).setFill()
NSBezierPath(roundedRect: NSRect(x: 435, y: 300, width: 154, height: 20), xRadius: 10, yRadius: 10)
  .fill()
image.unlockFocus()
let bitmap = NSBitmapImageRep(data: image.tiffRepresentation!)!
let png = bitmap.representation(using: .png, properties: [:])!
let destinations = [
  "Foqos/foqos-icon.icon/Assets/foqos-logo.png",
  "Foqos/Assets.xcassets/FoqosStickerLogo.imageset/foqos-logo.png",
  "Foqos/Assets.xcassets/AppIconDefaultPreview.imageset/app-icon-default-preview.png",
  "FoqosWidget/Assets.xcassets/FoqosStickerLogo.imageset/foqos-logo.png",
  "FoqosWidget/Assets.xcassets/FoqosStickerLogo.imageset/foqos-logo@2x.png",
  "FoqosWidget/Assets.xcassets/FoqosStickerLogo.imageset/foqos-logo@3x.png",
]
for path in destinations { try png.write(to: root.appendingPathComponent(path)) }
