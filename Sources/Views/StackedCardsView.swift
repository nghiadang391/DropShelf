import SwiftUI
import AppKit

public struct StackedCardsView: View {
    @ObservedObject var shelf: ShelfModel
    
    public var body: some View {
        ZStack {
            let count = shelf.items.count
            if count > 0 {
                // Show up to 3 cards in the stack
                let displayItems = Array(shelf.items.prefix(3).reversed())
                
                ForEach(Array(displayItems.enumerated()), id: \.element.id) { index, item in
                    let isTop = (index == displayItems.count - 1)
                    let rotation = cardRotation(for: index, total: displayItems.count)
                    let offset = cardOffset(for: index, total: displayItems.count)
                    
                    cardView(for: item, isTop: isTop)
                        .rotationEffect(.degrees(rotation))
                        .offset(x: offset.x, y: offset.y)
                        .shadow(color: Color.black.opacity(isTop ? 0.35 : 0.15), radius: isTop ? 8 : 4, x: 0, y: isTop ? 4 : 2)
                }
            }
        }
        .frame(width: 140, height: 140)
        .contentShape(Rectangle())
        .onDrag {
            let currentItems = shelf.items
            HistoryManager.shared.recordItems(currentItems)
            ShelfWindowManager.shared.handleItemDragInitiated(for: shelf.id, items: currentItems)
            
            let itemProviders = currentItems.compactMap { item -> NSItemProvider? in
                if let url = item.url {
                    return NSItemProvider(object: url as NSURL)
                } else if let text = item.stringContent {
                    return NSItemProvider(object: text as NSString)
                }
                return nil
            }
            
            DispatchQueue.main.async {
                shelf.clear()
            }
            
            return itemProviders.first ?? NSItemProvider()
        }
    }
    
    private func cardRotation(for index: Int, total: Int) -> Double {
        guard total > 1 else { return 0 }
        let posFromTop = (total - 1) - index
        switch posFromTop {
        case 0: return 0.0
        case 1: return 6.0
        case 2: return -8.0
        default: return Double(index * 3)
        }
    }
    
    private func cardOffset(for index: Int, total: Int) -> CGPoint {
        guard total > 1 else { return .zero }
        let posFromTop = (total - 1) - index
        switch posFromTop {
        case 0: return CGPoint(x: 0, y: 0)
        case 1: return CGPoint(x: 4, y: -4)
        case 2: return CGPoint(x: -6, y: -7)
        default: return CGPoint(x: 0, y: 0)
        }
    }
    
    @ViewBuilder
    private func cardView(for item: ShelfItem, isTop: Bool) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(nsColor: .windowBackgroundColor))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.18), lineWidth: 1)
                )
            
            if item.isImage, let url = item.url, let nsImage = NSImage(contentsOf: url) {
                Image(nsImage: nsImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            } else if let url = item.url {
                VStack(spacing: 6) {
                    let icon = NSWorkspace.shared.icon(forFile: url.path)
                    Image(nsImage: icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 48, height: 48)
                    
                    Text(item.name)
                        .font(.system(size: 10, weight: .medium))
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.primary)
                        .padding(.horizontal, 4)
                }
                .padding(8)
            } else if item.type == .url {
                VStack(spacing: 6) {
                    Image(systemName: "link.circle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.blue)
                    Text(item.name)
                        .font(.system(size: 10, weight: .medium))
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 4)
                }
                .padding(8)
            } else {
                VStack(spacing: 6) {
                    Image(systemName: "doc.text.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.orange)
                    Text(item.name)
                        .font(.system(size: 10, weight: .medium))
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 4)
                }
                .padding(8)
            }
        }
        .frame(width: 106, height: 126)
    }
}
