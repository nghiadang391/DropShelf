import SwiftUI
import AppKit

public struct WindowDragArea: NSViewRepresentable {
    public init() {}
    
    public func makeNSView(context: Context) -> WindowDragNSView {
        let view = WindowDragNSView()
        return view
    }
    
    public func updateNSView(_ nsView: WindowDragNSView, context: Context) {}
}

public class WindowDragNSView: NSView {
    public override func mouseDown(with event: NSEvent) {
        window?.performDrag(with: event)
    }
}
