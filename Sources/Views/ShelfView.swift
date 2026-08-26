import SwiftUI
import AppKit
import UniformTypeIdentifiers

public struct ShelfView: View {
    @ObservedObject var shelf: ShelfModel
    public let onClose: () -> Void
    
    @State private var isExpanded: Bool = false
    @State private var isTargetedForDrop: Bool = false
    
    public var body: some View {
        VStack(spacing: 12) {
            // Header Bar
            headerBar
            
            // Main Content Area
            if shelf.items.isEmpty {
                emptyDropTarget
            } else if isExpanded {
                ExpandedItemsGridView(shelf: shelf)
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
            } else {
                StackedCardsView(shelf: shelf)
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }
            
            // Bottom Expand / Collapse Pill
            if !shelf.items.isEmpty {
                bottomExpandPill
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .frame(
            width: isExpanded ? 280 : 200,
            height: isExpanded ? 280 : 230
        )
        .background(
            ZStack {
                VisualEffectBackground()
                Color(nsColor: .windowBackgroundColor).opacity(0.25)
            }
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(
                        isTargetedForDrop ? Color.blue.opacity(0.8) : Color.white.opacity(0.12),
                        lineWidth: isTargetedForDrop ? 2 : 1
                    )
            )
            .shadow(color: Color.black.opacity(0.35), radius: 16, x: 0, y: 8)
        )
        .onDrop(of: [.fileURL, .text, .url, .utf8PlainText], isTargeted: $isTargetedForDrop) { providers in
            handleDrop(providers: providers)
            return true
        }
        .onChange(of: shelf.items) { items in
            if items.isEmpty && !shelf.isPinned {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    if shelf.items.isEmpty && !shelf.isPinned {
                        onClose()
                    }
                }
            }
        }
        .animation(.spring(response: 0.32, dampingFraction: 0.8), value: isExpanded)
    }
    
    @ViewBuilder
    private var headerBar: some View {
        HStack {
            // Close Button
            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(Color.white.opacity(0.7))
                    .frame(width: 26, height: 26)
                    .background(Color.white.opacity(0.12))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            
            Spacer()
            
            // Center Grabber Pill
            Capsule()
                .fill(Color.white.opacity(0.2))
                .frame(width: 32, height: 4)
            
            Spacer()
            
            // Action Menu
            ShelfActionMenuView(shelf: shelf, onDismiss: onClose)
        }
    }
    
    @ViewBuilder
    private var emptyDropTarget: some View {
        VStack(spacing: 8) {
            Image(systemName: "arrow.down.circle")
                .font(.system(size: 34, weight: .light))
                .foregroundColor(Color.white.opacity(0.6))
            
            Text("Drop files here")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(Color.white.opacity(0.8))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.vertical, 20)
    }
    
    @ViewBuilder
    private var bottomExpandPill: some View {
        Button {
            withAnimation {
                isExpanded.toggle()
            }
        } label: {
            HStack(spacing: 4) {
                Text("\(shelf.items.count) File\(shelf.items.count == 1 ? "" : "s")")
                    .font(.system(size: 12, weight: .semibold))
                
                Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(Color.white.opacity(0.7))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 14)
            .padding(.vertical, 6)
            .background(Color.white.opacity(0.14))
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .onDrag {
            HistoryManager.shared.recordItems(shelf.items)
            let itemProviders = shelf.items.compactMap { item -> NSItemProvider? in
                if let url = item.url {
                    return NSItemProvider(object: url as NSURL)
                } else if let text = item.stringContent {
                    return NSItemProvider(object: text as NSString)
                }
                return nil
            }
            
            if !shelf.isPinned {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    shelf.clear()
                }
            }
            
            return itemProviders.first ?? NSItemProvider()
        }
    }
    
    private func handleDrop(providers: [NSItemProvider]) {
        for provider in providers {
            if provider.hasItemConformingToTypeIdentifier(UTType.fileURL.identifier) {
                _ = provider.loadObject(ofClass: URL.self) { url, _ in
                    guard let url = url else { return }
                    DispatchQueue.main.async {
                        let item = ShelfItem.from(url: url)
                        self.shelf.addItem(item)
                        SoundService.playDrop()
                    }
                }
            } else if provider.hasItemConformingToTypeIdentifier(UTType.text.identifier) {
                _ = provider.loadObject(ofClass: String.self) { text, _ in
                    guard let text = text else { return }
                    DispatchQueue.main.async {
                        let item = ShelfItem.from(text: text)
                        self.shelf.addItem(item)
                        SoundService.playDrop()
                    }
                }
            }
        }
    }
}

public struct VisualEffectBackground: NSViewRepresentable {
    public func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.blendingMode = .behindWindow
        view.state = .active
        view.material = .hudWindow
        return view
    }
    
    public func updateNSView(_ nsView: NSVisualEffectView, context: Context) {}
}
