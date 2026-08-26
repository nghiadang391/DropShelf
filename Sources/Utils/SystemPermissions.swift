import Foundation
import AppKit

public enum SystemPermissions {
    public static var isAccessibilityGranted: Bool {
        AXIsProcessTrusted()
    }
    
    public static func requestAccessibility() {
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
        AXIsProcessTrustedWithOptions(options)
    }
}
