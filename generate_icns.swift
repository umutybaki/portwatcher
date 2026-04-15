import AppKit
import Foundation

let svgPath = "logo.svg"
let iconsetName = "AppIcon.iconset"
let outputPath = "AppIcon.icns"

guard let svgImage = NSImage(contentsOfFile: svgPath) else {
    print("Error: Could not load \(svgPath)")
    exit(1)
}

let fileManager = FileManager.default
try? fileManager.removeItem(atPath: iconsetName)
try? fileManager.createDirectory(atPath: iconsetName, withIntermediateDirectories: true)

let sizes = [16, 32, 64, 128, 256, 512, 1024]

for size in sizes {
    let scale1x = CGFloat(size)
    let scale2x = CGFloat(size * 2)
    
    saveImage(svgImage, size: scale1x, name: "icon_\(size)x\(size).png")
    if size * 2 <= 1024 {
        saveImage(svgImage, size: scale2x, name: "icon_\(size)x\(size)@2x.png")
    }
}

func saveImage(_ image: NSImage, size: CGFloat, name: String) {
    let destSize = NSSize(width: size, height: size)
    let newImage = NSImage(size: destSize)
    
    newImage.lockFocus()
    image.draw(in: NSRect(origin: .zero, size: destSize), from: .zero, operation: .copy, fraction: 1.0)
    newImage.unlockFocus()
    
    guard let tiffData = newImage.tiffRepresentation,
          let bitmapRep = NSBitmapImageRep(data: tiffData),
          let pngData = bitmapRep.representation(using: .png, properties: [:]) else {
        return
    }
    
    let path = "\(iconsetName)/\(name)"
    try? pngData.write(to: URL(fileURLWithPath: path))
}

let process = Process()
process.executableURL = URL(fileURLWithPath: "/usr/bin/iconutil")
process.arguments = ["-c", "icns", iconsetName, "-o", outputPath]

do {
    try process.run()
    process.waitUntilExit()
    print("Success: Generated \(outputPath)")
    try? fileManager.removeItem(atPath: iconsetName)
} catch {
    print("Error running iconutil: \(error)")
}
