import Foundation
import AppKit
import CoreGraphics

public class MouseShakeDetector {
    public static let shared = MouseShakeDetector()
    
    private var trackingTimer: Timer?
    public var onShakeDetected: ((NSPoint) -> Void)?
    
    private var positionHistory: [(point: NSPoint, time: TimeInterval)] = []
    private var lastTriggerTime: TimeInterval = 0
    private var hasTriggeredInCurrentDrag: Bool = false
    private let cooldown: TimeInterval = 1.0
    
    private init() {}
    
    public func startMonitoring() {
        stopMonitoring()
        
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
        let isLeftDown = CGEventSource.buttonState(.hidSystemState, button: .left) ||
                         CGEventSource.buttonState(.combinedSessionState, button: .left) ||
                         (NSEvent.pressedMouseButtons & 1) != 0
        
        guard isLeftDown else {
            // Drag ended: reset drag state
            if !positionHistory.isEmpty {
                positionHistory.removeAll()
            }
            hasTriggeredInCurrentDrag = false
            return
        }
        
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
            lastTriggerTime = now
            hasTriggeredInCurrentDrag = true
            positionHistory.removeAll()
            DispatchQueue.main.async { [weak self] in
                self?.onShakeDetected?(currentPoint)
            }
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
