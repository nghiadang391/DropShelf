import Foundation
import AppKit

public enum MenuBarIconHelper {
    public static func createCleanMenuBarIcon() -> NSImage {
        let size = NSSize(width: 18, height: 18)
        let image = NSImage(size: size)
        image.lockFocus()
        
        guard let ctx = NSGraphicsContext.current?.cgContext else {
            image.unlockFocus()
            return image
        }
        
        ctx.setAllowsAntialiasing(true)
        ctx.setShouldAntialias(true)
        
        // Draw a clean, minimalist rounded shelf container with a floating drop indicator
        let shelfRect = CGRect(x: 2.5, y: 3.5, width: 13, height: 9)
        let shelfPath = CGPath(roundedRect: shelfRect, cornerWidth: 3, cornerHeight: 3, transform: nil)
        
        ctx.setLineWidth(1.6)
        ctx.setStrokeColor(NSColor.black.cgColor)
        ctx.addPath(shelfPath)
        ctx.strokePath()
        
        // Subtle top shelf ledge / notch line
        let ledgePath = CGMutablePath()
        ledgePath.move(to: CGPoint(x: 5.5, y: 12.5))
        ledgePath.addLine(to: CGPoint(x: 12.5, y: 12.5))
        ctx.addPath(ledgePath)
        ctx.strokePath()
        
        // Inner centered dot / indicator
        let dotRect = CGRect(x: 7.5, y: 6.5, width: 3, height: 3)
        ctx.setFillColor(NSColor.black.cgColor)
        ctx.fillEllipse(in: dotRect)
        
        image.unlockFocus()
        image.isTemplate = true
        return image
    }
}
