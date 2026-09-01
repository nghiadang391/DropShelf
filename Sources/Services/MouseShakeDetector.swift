import Foundation
import AppKit
import CoreGraphics

public class MouseShakeDetector {
    public static let shared = MouseShakeDetector()
    
    private var trackingTimer: Timer?
    public var onShakeDetected: ((NSPoint) -> Void)?
    public var onMouseRelease: ((NSPoint) -> Void)?
    
    private var positionHistory: [(point: NSPoint, time: TimeInterval)] = []
    public var isDraggingFromShelf: Bool = false
    private var wasLeftDown: Bool = false
    private var lastIdleDragChangeCount: Int = 0
    private var lastTriggerTime: TimeInterval = 0
    private var hasTriggeredInCurrentDrag: Bool = false
    private let cooldown: TimeInterval = 1.0
    
    private init() {
        lastIdleDragChangeCount = NSPasteboard(name: .drag).changeCount
    }
    
    public func startMonitoring() {
        stopMonitoring()
        lastIdleDragChangeCount = NSPasteboard(name: .drag).changeCount
        
        // 60Hz polling of hardware cursor & button state
        trackingTimer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { [weak self] _ in
            self?.tick()
        }
        RunLoop.main.add(trackingTimer!, forMode: .common)
    }
    
    public func stopMonitoring() {
        trackingTimer?.invalidate()
        trackingTimer = nil
    }
    
    private func tick() {
        let isLeftDown = CGEventSource.buttonState(.hidSystemState, button: .left)
        
        if wasLeftDown && !isLeftDown {
            // Hardware mouse release transition detected (zero permission required)
            wasLeftDown = false
            hasTriggeredInCurrentDrag = false
            isDraggingFromShelf = false
            positionHistory.removeAll()
            lastIdleDragChangeCount = NSPasteboard(name: .drag).changeCount
            let releasePoint = NSEvent.mouseLocation
            DispatchQueue.main.async { [weak self] in
                self?.onMouseRelease?(releasePoint)
            }
            return
        }
        
        wasLeftDown = isLeftDown
        
        guard isLeftDown else {
            // While idle (mouse up), update the baseline drag changeCount
            lastIdleDragChangeCount = NSPasteboard(name: .drag).changeCount
            return
        }
        
        // Do not trigger shake if mouse is dragging an item OUT from our shelf
        guard !isDraggingFromShelf else { return }
        
        // If already triggered once in this drag session, don't spam duplicate shelves
        guard !hasTriggeredInCurrentDrag else { return }
        
        let currentPoint = NSEvent.mouseLocation
        let now = Date().timeIntervalSince1970
        
        if now - lastTriggerTime < cooldown {
            return
        }
        
        positionHistory.append((point: currentPoint, time: now))
        
        // Sliding window of past 350ms
        positionHistory.removeAll { now - $0.time > 0.35 }
        
        if positionHistory.count < 4 { return }
        
        if detectShake() {
            // Verify that a genuine drag session began after the mouse was clicked
            let currentDragCount = NSPasteboard(name: .drag).changeCount
            guard currentDragCount > lastIdleDragChangeCount else {
                return
            }
            guard isDragPayloadActive() else { return }
            
            lastTriggerTime = now
            hasTriggeredInCurrentDrag = true
            positionHistory.removeAll()
            DispatchQueue.main.async { [weak self] in
                self?.onShakeDetected?(currentPoint)
            }
        }
    }
    
    private func isDragPayloadActive() -> Bool {
        let pboard = NSPasteboard(name: .drag)
        guard let types = pboard.types, !types.isEmpty else { return false }
        
        let validTypes = [
            NSPasteboard.PasteboardType.fileURL,
            NSPasteboard.PasteboardType.URL,
            NSPasteboard.PasteboardType.string,
            NSPasteboard.PasteboardType.rtf,
            NSPasteboard.PasteboardType.html,
            NSPasteboard.PasteboardType.png,
            NSPasteboard.PasteboardType.tiff,
            NSPasteboard.PasteboardType.pdf,
            NSPasteboard.PasteboardType("NSFilenamesPboardType"),
            NSPasteboard.PasteboardType("public.file-url"),
            NSPasteboard.PasteboardType("public.url"),
            NSPasteboard.PasteboardType("public.utf8-plain-text")
        ]
        
        return types.contains { type in
            validTypes.contains(type) ||
            type.rawValue.contains("url") ||
            type.rawValue.contains("file") ||
            type.rawValue.contains("image")
        }
    }
    
    private func detectShake() -> Bool {
        guard positionHistory.count >= 4 else { return false }
        
        var directionChanges = 0
        var lastDx: CGFloat = 0
        let minStep: CGFloat = 8.0
        
        for i in 1..<positionHistory.count {
            let dx = positionHistory[i].point.x - positionHistory[i-1].point.x
            
            if abs(dx) >= minStep {
                if (dx > 0 && lastDx < 0) || (dx < 0 && lastDx > 0) {
                    directionChanges += 1
                }
                lastDx = dx
            }
        }
        
        return directionChanges >= 2
    }
}
