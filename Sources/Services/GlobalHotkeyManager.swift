import Foundation
import AppKit
import Carbon

public class GlobalHotkeyManager {
    public static let shared = GlobalHotkeyManager()
    
    private var eventHandler: EventHandlerRef?
    public var onHotkeyPressed: (() -> Void)?
    
    private init() {}
    
    public func registerDefaultHotkey() {
        // Register Option + Space (Key code 49 = Space, modifier = optionKey)
        let hotKeyID = EventHotKeyID(signature: OSType(0x4453484C), id: 1) // 'DSHL', 1
        var hotKeyRef: EventHotKeyRef?
        
        let modifiers = UInt32(optionKey)
        let keyCode = UInt32(kVK_Space)
        
        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
        
        let status = InstallEventHandler(GetApplicationEventTarget(), { (handler, event, userData) -> OSStatus in
            GlobalHotkeyManager.shared.onHotkeyPressed?()
            return noErr
        }, 1, &eventType, nil, &eventHandler)
        
        if status == noErr {
            RegisterEventHotKey(keyCode, modifiers, hotKeyID, GetApplicationEventTarget(), 0, &hotKeyRef)
        }
    }
}
