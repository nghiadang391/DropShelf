import Foundation
import AppKit

public class AppDelegate: NSObject, NSApplicationDelegate {
    public func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        
        // Setup menu bar icon
        MenuBarManager.shared.setupMenuBar()
        
        // Register global hotkey (Option + Space)
        GlobalHotkeyManager.shared.onHotkeyPressed = {
            ShelfWindowManager.shared.createShelf()
        }
        GlobalHotkeyManager.shared.registerDefaultHotkey()
        
        // Start high-performance mouse shake detector
        MouseShakeDetector.shared.onShakeDetected = { mousePosition in
            ShelfWindowManager.shared.createShelf(at: mousePosition)
        }
        MouseShakeDetector.shared.startMonitoring()
        
        // Setup folder monitor callback
        FolderMonitorService.shared.onNewFilesDetected = { urls in
            let items = urls.map { ShelfItem.from(url: $0) }
            ShelfWindowManager.shared.createShelf(with: items)
        }
        
    }
    
    public func applicationWillTerminate(_ notification: Notification) {
        MouseShakeDetector.shared.stopMonitoring()
        FolderMonitorService.shared.stopMonitoring()
    }
}
