import Foundation
import AppKit

public enum SoundService {
    public static var isSoundEnabled: Bool {
        get {
            UserDefaults.standard.object(forKey: "enableSoundEffects") as? Bool ?? true
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "enableSoundEffects")
        }
    }
    
    public static func playSpawn() {
        guard isSoundEnabled else { return }
        NSSound(named: "Pop")?.play()
    }
    
    public static func playDrop() {
        guard isSoundEnabled else { return }
        NSSound(named: "Tink")?.play()
    }
    
    public static func playDismiss() {
        guard isSoundEnabled else { return }
        NSSound(named: "Blow")?.play()
    }
}
