import AppKit

// Draws the PortHole app icon — a ship's porthole with a terminal `>_` prompt
// through the glass — and writes every size an .iconset needs.
// Usage: swift tools/GenerateIcon.swift <output.iconset dir>

func color(_ hex: String, alpha: CGFloat = 1) -> NSColor {
    var h = hex; if h.hasPrefix("#") { h.removeFirst() }
    let v = UInt32(h, radix: 16) ?? 0
    return NSColor(srgbRed: CGFloat((v >> 16) & 0xff) / 255,
                   green: CGFloat((v >> 8) & 0xff) / 255,
                   blue: CGFloat(v & 0xff) / 255, alpha: alpha)
}

/// Draws the icon into the current graphics context, sized to `px` pixels.
/// Coordinates are authored on a 128-unit grid (native y-up: higher y = top).
func drawIcon(px: CGFloat) {
    let f = px / 128.0
    func P(_ x: CGFloat, _ y: CGFloat) -> NSPoint { NSPoint(x: x * f, y: y * f) }

    let squircle = NSBezierPath(roundedRect: NSRect(x: 6 * f, y: 6 * f, width: 116 * f, height: 116 * f),
                                xRadius: 28 * f, yRadius: 28 * f)

    // Background gradient (light top → dark bottom).
    NSGradient(starting: color("#0a5787"), ending: color("#1fb4dc"))?
        .draw(in: squircle, angle: 90)

    // Soft top gloss.
    NSGraphicsContext.saveGraphicsState()
    squircle.setClip()
    color("#ffffff", alpha: 0.15).setFill()
    NSBezierPath(rect: NSRect(x: 6 * f, y: 64 * f, width: 116 * f, height: 58 * f)).fill()
    NSGraphicsContext.restoreGraphicsState()

    // Steel ring.
    let ring = NSBezierPath(ovalIn: NSRect(x: 23 * f, y: 23 * f, width: 82 * f, height: 82 * f))
    NSGradient(starting: color("#9cafbe"), ending: color("#f6f9fb"))?.draw(in: ring, angle: 90)

    // Glass.
    let glass = NSBezierPath(ovalIn: NSRect(x: 33 * f, y: 33 * f, width: 62 * f, height: 62 * f))
    NSGradient(starting: color("#e2f6ff"), ending: color("#6fc1e6"))?
        .draw(in: glass, relativeCenterPosition: NSPoint(x: -0.25, y: 0.3))

    // Glass highlight (drawn before the glyph so the prompt stays crisp on top).
    color("#ffffff", alpha: 0.35).setFill()
    NSBezierPath(ovalIn: NSRect(x: 42 * f, y: 74 * f, width: 26 * f, height: 12 * f)).fill()

    // Rivets around the ring.
    color("#ffffff", alpha: 0.92).setFill()
    let rivets: [(CGFloat, CGFloat)] = [
        (100, 64), (89.5, 89.5), (64, 100), (38.5, 89.5),
        (28, 64), (38.5, 38.5), (64, 28), (89.5, 38.5),
    ]
    for (x, y) in rivets {
        NSBezierPath(ovalIn: NSRect(x: (x - 2.2) * f, y: (y - 2.2) * f, width: 4.4 * f, height: 4.4 * f)).fill()
    }

    // Terminal prompt `>_` through the glass.
    color("#083f5c").setStroke()
    let chevron = NSBezierPath()
    chevron.lineWidth = 5.5 * f
    chevron.lineCapStyle = .round
    chevron.lineJoinStyle = .round
    chevron.move(to: P(50, 74))
    chevron.line(to: P(61, 64))
    chevron.line(to: P(50, 54))
    chevron.stroke()

    let underscore = NSBezierPath()
    underscore.lineWidth = 5.5 * f
    underscore.lineCapStyle = .round
    underscore.move(to: P(66, 52))
    underscore.line(to: P(80, 52))
    underscore.stroke()
}

func renderPNG(px: Int) -> Data {
    let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: px, pixelsHigh: px,
                               bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
                               colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
    rep.size = NSSize(width: px, height: px)
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
    drawIcon(px: CGFloat(px))
    NSGraphicsContext.restoreGraphicsState()
    return rep.representation(using: .png, properties: [:])!
}

// MARK: - Write the iconset

let outputDir = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "AppIcon.iconset"
let targets: [(name: String, px: Int)] = [
    ("icon_16x16", 16), ("icon_16x16@2x", 32),
    ("icon_32x32", 32), ("icon_32x32@2x", 64),
    ("icon_128x128", 128), ("icon_128x128@2x", 256),
    ("icon_256x256", 256), ("icon_256x256@2x", 512),
    ("icon_512x512", 512), ("icon_512x512@2x", 1024),
]

try? FileManager.default.createDirectory(atPath: outputDir, withIntermediateDirectories: true)
for target in targets {
    let data = renderPNG(px: target.px)
    let path = "\(outputDir)/\(target.name).png"
    try! data.write(to: URL(fileURLWithPath: path))
}
print("Wrote \(targets.count) images to \(outputDir)")
