import Foundation
import AppKit
import SwiftUI

public class ShelfWindowManager: ObservableObject {
    public static let shared = ShelfWindowManager()
    
    private var activePanels: [UUID: FloatingShelfPanel] = [:]
    
    private init() {}
    
    public func createShelf(at point: NSPoint? = nil, with items: [ShelfItem] = []) {
        let mousePoint = point ?? NSEvent.mouseLocation
        
        // If creating an empty shelf and there is already an unpinned empty shelf, reuse and reposition it!
        if items.isEmpty {
            if let existingEmpty = activePanels.values.first(where: { $0.shelfModel.items.isEmpty && !$0.shelfModel.isPinned }) {
                existingEmpty.setFrameOrigin(NSPoint(x: mousePoint.x - 140, y: mousePoint.y - 70))
                existingEmpty.makeKeyAndOrderFront(nil)
                existingEmpty.orderFrontRegardless()
                existingEmpty.scheduleAutoDismissIfEmpty()
                SoundService.playSpawn()
                return
            }
        }
        
        let shelfModel = ShelfModel(items: items)
        let panel = FloatingShelfPanel(shelfModel: shelfModel, initialPosition: mousePoint)
        
        activePanels[shelfModel.id] = panel
        panel.makeKeyAndOrderFront(nil)
        panel.orderFrontRegardless()
        
        SoundService.playSpawn()
    }
    
    public func removePanel(id: UUID) {
        activePanels.removeValue(forKey: id)
    }
    
    public func closeShelf(id: UUID) {
        if let panel = activePanels[id] {
            panel.dismissWithFade()
        }
    }
    
    public func closeAllShelves() {
        for (_, panel) in activePanels {
            panel.dismissWithFade()
        }
    }
    
    public var activeShelfCount: Int {
        activePanels.count
    }
}
