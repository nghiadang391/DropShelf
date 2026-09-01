import Foundation
import AppKit
import SwiftUI

public class ShelfWindowManager: ObservableObject {
    public static let shared = ShelfWindowManager()
    
    private var activePanels: [UUID: FloatingShelfPanel] = [:]
    private var stagedDragSessions: [UUID: [ShelfItem]] = [:]
    
    private init() {
        MouseShakeDetector.shared.onMouseRelease = { [weak self] releasePoint in
            self?.handleMouseRelease(at: releasePoint)
        }
    }
    
    private func handleMouseRelease(at point: NSPoint) {
        // Check shelves that had items dragged out
        for (shelfId, items) in stagedDragSessions {
            if let panel = activePanels[shelfId] {
                if panel.frame.contains(point) {
                    // Mouse released over the shelf -> User dragged back or cancelled!
                    DispatchQueue.main.async {
                        withAnimation(.spring(response: 0.32, dampingFraction: 0.78)) {
                            panel.shelfModel.addItems(items)
                        }
                    }
                    SoundService.playDrop()
                } else {
                    // Mouse released outside -> Drop/paste completed elsewhere!
                    if panel.shelfModel.items.isEmpty && !panel.shelfModel.isPinned {
                        panel.dismissWithFade()
                    }
                }
            }
        }
        stagedDragSessions.removeAll()
        
        // Also dismiss any other empty unpinned shelves when mouse is released
        for (_, panel) in activePanels {
            if panel.shelfModel.items.isEmpty && !panel.shelfModel.isPinned {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    if panel.shelfModel.items.isEmpty && !panel.shelfModel.isPinned {
                        panel.dismissWithFade()
                    }
                }
            }
        }
    }
    
    public func createShelf(at point: NSPoint? = nil, with items: [ShelfItem] = []) {
        guard !MouseShakeDetector.shared.isDraggingFromShelf else { return }
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
    
    public func panel(for id: UUID) -> FloatingShelfPanel? {
        activePanels[id]
    }
    
    public func handleItemDragInitiated(for shelfId: UUID, items: [ShelfItem] = []) {
        MouseShakeDetector.shared.isDraggingFromShelf = true
        if !items.isEmpty {
            stagedDragSessions[shelfId] = items
        }
    }
    
    public var activeShelfCount: Int {
        activePanels.count
    }
}
