import SwiftUI
import AppKit

public struct PreferencesView: View {
    @AppStorage("shakeSensitivity") private var shakeSensitivity: Double = 1.0
    @AppStorage("autoCatchDownloads") private var autoCatchDownloads: Bool = false
    @AppStorage("autoCatchScreenshots") private var autoCatchScreenshots: Bool = false
    @AppStorage("defaultColorId") private var defaultColorId: String = "blue"
    @AppStorage("enableSoundEffects") private var enableSoundEffects: Bool = true
    
    public init() {}
    
    public var body: some View {
        Form {
            Section("Trigger Settings") {
                Toggle("Shake cursor while dragging to open shelf", isOn: .constant(true))
                    .disabled(true)
                
                HStack {
                    Text("Global Shortcut:")
                    Spacer()
                    Text("⌥ + Space")
                        .font(.system(.body, design: .monospaced))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.secondary.opacity(0.15))
                        .cornerRadius(4)
                }
            }
            
            Section("Audio & Feedback") {
                Toggle("Play sound effects on shelf spawn & drop", isOn: $enableSoundEffects)
            }
            
            Section("Folder Monitoring (Pro)") {
                Toggle("Auto-catch new Downloads", isOn: $autoCatchDownloads)
                    .onChange(of: autoCatchDownloads) { enabled in
                        if enabled, let downloads = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first {
                            FolderMonitorService.shared.startMonitoring(folderURL: downloads)
                        } else if !autoCatchScreenshots {
                            FolderMonitorService.shared.stopMonitoring()
                        }
                    }
                
                Toggle("Auto-catch new Screenshots on Desktop", isOn: $autoCatchScreenshots)
            }
        }
        .padding(20)
        .frame(width: 420, height: 240)
    }
}
