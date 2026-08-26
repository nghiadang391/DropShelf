import SwiftUI
import AppKit

public struct ShelfItemThumbnailView: View {
    public let item: ShelfItem
    public let onDelete: () -> Void
    
    @State private var isHovered: Bool = false
    
    public var body: some View {
        VStack(spacing: 4) {
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(nsColor: .controlBackgroundColor).opacity(0.8))
                    .frame(width: 68, height: 68)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.primary.opacity(isHovered ? 0.35 : 0.1), lineWidth: isHovered ? 1.5 : 1)
                    )
                
                thumbnailContent
                    .frame(width: 56, height: 56)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .padding(6)
                
                if isHovered {
                    Button(action: onDelete) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                    .offset(x: 4, y: -4)
                }
            }
            
            Text(item.name)
                .font(.system(size: 11, weight: .medium))
                .lineLimit(1)
                .truncationMode(.middle)
                .frame(width: 68)
                .foregroundColor(.primary)
        }
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovered = hovering
            }
        }
        .onTapGesture(count: 2) {
            if let url = item.url {
                NSWorkspace.shared.open(url)
            }
        }
        .onDrag {
            if let url = item.url {
                return NSItemProvider(object: url as NSURL)
            } else if let text = item.stringContent {
                return NSItemProvider(object: text as NSString)
            } else {
                return NSItemProvider(object: item.name as NSString)
            }
        }
        .help(item.url?.path ?? item.name)
    }
    
    @ViewBuilder
    private var thumbnailContent: some View {
        if item.isImage, let url = item.url, let nsImage = NSImage(contentsOf: url) {
            Image(nsImage: nsImage)
                .resizable()
                .scaledToFill()
        } else if let url = item.url {
            let icon = NSWorkspace.shared.icon(forFile: url.path)
            Image(nsImage: icon)
                .resizable()
                .scaledToFit()
        } else if item.type == .url {
            Image(systemName: "link.circle.fill")
                .resizable()
                .scaledToFit()
                .foregroundColor(.blue)
        } else {
            Image(systemName: "doc.text.fill")
                .resizable()
                .scaledToFit()
                .foregroundColor(.orange)
        }
    }
}
