import Foundation
import AppKit
import SwiftUI

public class FloatingShelfPanel: NSPanel {
    public let shelfModel: ShelfModel
    private var autoDismissWorkItem: DispatchWorkItem?
    
    public init(shelfModel: ShelfModel, initialPosition: NSPoint) {
        self.shelfModel = shelfModel
        
        super.init(
            contentRect: NSRect(x: initialPosition.x - 100, y: initialPosition.y - 115, width: 280, height: 280),
            styleMask: [.nonactivatingPanel, .fullSizeContentView, .borderless],
            backing: .buffered,
            defer: false
        )
        
        self.isFloatingPanel = true
        self.level = .floating
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        self.backgroundColor = .clear
        self.isOpaque = false
        self.hasShadow = true
        self.isMovableByWindowBackground = true
        self.animationBehavior = .utilityWindow
        
        let hostingView = NSHostingView(
            rootView: ShelfView(shelf: shelfModel) { [weak self] in
                self?.dismissWithFade()
            }
        )
        self.contentView = hostingView
        
        scheduleAutoDismissIfEmpty()
    }
    
    public func scheduleAutoDismissIfEmpty() {
        cancelAutoDismiss()
        guard shelfModel.items.isEmpty && !shelfModel.isPinned else { return }
        
        let workItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            if self.shelfModel.items.isEmpty && !self.shelfModel.isPinned {
                self.dismissWithFade()
            }
        }
        self.autoDismissWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 6.0, execute: workItem)
    }
    
    public func cancelAutoDismiss() {
        autoDismissWorkItem?.cancel()
        autoDismissWorkItem = nil
    }
    
    public func dismissWithFade() {
        cancelAutoDismiss()
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.2
            self.animator().alphaValue = 0.0
        }, completionHandler: { [weak self] in
            guard let self = self else { return }
            self.close()
            ShelfWindowManager.shared.removePanel(id: self.shelfModel.id)
            SoundService.playDismiss()
        })
    }
}
