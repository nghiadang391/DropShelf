import SwiftUI
import AppKit

public struct MultiItemDragSourceView<Content: View>: View {
    public let items: [ShelfItem]
    public let onClick: (() -> Void)?
    public let onDragStarted: () -> Void
    public let onDragEnded: (Bool) -> Void
    public let content: () -> Content
    
    public init(
        items: [ShelfItem],
        onClick: (() -> Void)? = nil,
        onDragStarted: @escaping () -> Void,
        onDragEnded: @escaping (Bool) -> Void,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.items = items
        self.onClick = onClick
        self.onDragStarted = onDragStarted
        self.onDragEnded = onDragEnded
        self.content = content
    }
    
    public var body: some View {
        content()
            .overlay(
                MultiItemDragOverlayRepresentable(
                    items: items,
                    onClick: onClick,
                    onDragStarted: onDragStarted,
                    onDragEnded: onDragEnded
                )
            )
    }
}

public struct MultiItemDragOverlayRepresentable: NSViewRepresentable {
    public let items: [ShelfItem]
    public let onClick: (() -> Void)?
    public let onDragStarted: () -> Void
    public let onDragEnded: (Bool) -> Void
    
    public func makeNSView(context: Context) -> MultiItemDragOverlayNSView {
        let view = MultiItemDragOverlayNSView()
        view.items = items
        view.onClick = onClick
        view.onDragStarted = onDragStarted
        view.onDragEnded = onDragEnded
        return view
    }
    
    public func updateNSView(_ nsView: MultiItemDragOverlayNSView, context: Context) {
        nsView.items = items
        nsView.onClick = onClick
        nsView.onDragStarted = onDragStarted
        nsView.onDragEnded = onDragEnded
    }
}

public class MultiItemDragOverlayNSView: NSView, NSDraggingSource {
    public var items: [ShelfItem] = []
    public var onClick: (() -> Void)?
    public var onDragStarted: (() -> Void)?
    public var onDragEnded: ((Bool) -> Void)?
    
    private var mouseDownEvent: NSEvent?
    private var isDraggingSessionActive = false
    
    public override func acceptsFirstMouse(for event: NSEvent?) -> Bool {
        return true
    }
    
    public override func mouseDown(with event: NSEvent) {
        mouseDownEvent = event
    }
    
    public override func mouseDragged(with event: NSEvent) {
        guard let downEvent = mouseDownEvent else { return }
        let distance = hypot(event.locationInWindow.x - downEvent.locationInWindow.x,
                             event.locationInWindow.y - downEvent.locationInWindow.y)
        guard distance > 3.0 else { return }
        mouseDownEvent = nil
        
        guard !items.isEmpty else { return }
        
        isDraggingSessionActive = true
        onDragStarted?()
        
        let fileURLs = items.compactMap { $0.url?.standardizedFileURL }
        var draggingItems: [NSDraggingItem] = []
        
        if !fileURLs.isEmpty {
            for (index, url) in fileURLs.enumerated() {
                let dragItem = NSDraggingItem(pasteboardWriter: url as NSURL)
                let icon = NSWorkspace.shared.icon(forFile: url.path)
                let itemSize: CGFloat = 56
                let offset = CGFloat(min(index * 6, 24))
                let frame = NSRect(
                    x: (bounds.width - itemSize) / 2 + offset,
                    y: (bounds.height - itemSize) / 2 - offset,
                    width: itemSize,
                    height: itemSize
                )
                dragItem.setDraggingFrame(frame, contents: icon)
                draggingItems.append(dragItem)
            }
        } else {
            for item in items {
                let str = (item.stringContent ?? item.name) as NSString
                let dragItem = NSDraggingItem(pasteboardWriter: str)
                dragItem.setDraggingFrame(NSRect(x: 0, y: 0, width: 48, height: 48), contents: nil)
                draggingItems.append(dragItem)
            }
        }
        
        self.beginDraggingSession(with: draggingItems, event: event, source: self)
    }
    
    public override func mouseUp(with event: NSEvent) {
        if mouseDownEvent != nil && !isDraggingSessionActive {
            mouseDownEvent = nil
            if event.clickCount == 2 {
                if let url = items.first?.url {
                    NSWorkspace.shared.open(url)
                }
            } else {
                onClick?()
            }
        }
        mouseDownEvent = nil
    }
    
    // MARK: - NSDraggingSource
    
    public func draggingSession(_ session: NSDraggingSession, sourceOperationMaskFor context: NSDraggingContext) -> NSDragOperation {
        return [.copy, .move, .generic]
    }
    
    public func draggingSession(_ session: NSDraggingSession, endedAt screenPoint: NSPoint, operation: NSDragOperation) {
        isDraggingSessionActive = false
        let isInsideWindow = window?.frame.contains(screenPoint) ?? false
        let isCancelled = (operation == []) || isInsideWindow
        
        DispatchQueue.main.async { [weak self] in
            self?.onDragEnded?(!isCancelled)
        }
    }
}
