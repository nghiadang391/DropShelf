import SwiftUI
import AppKit

public struct ShelfActionMenuView: View {
    @ObservedObject var shelf: ShelfModel
    public let onDismiss: () -> Void
    
    @State private var ocrCopiedNotification: Bool = false
    
    public var body: some View {
        Menu {
            
            Section("Quick Actions") {
                Button {
                    QuickActionService.copyToClipboard(items: shelf.items)
                } label: {
                    Label("Copy All to Clipboard", systemImage: "doc.on.doc")
                }
                
                Button {
                    let folder = URL(fileURLWithPath: NSTemporaryDirectory())
                    if let zipUrl = QuickActionService.zipItems(items: shelf.items, destinationFolder: folder) {
                        let zipItem = ShelfItem.from(url: zipUrl)
                        shelf.clear()
                        shelf.addItem(zipItem)
                    }
                } label: {
                    Label("Compress to Zip", systemImage: "archivebox")
                }
                
                if shelf.items.contains(where: { $0.isImage }) {
                    Menu("Vision & Image Tools") {
                        Button {
                            extractOCRText()
                        } label: {
                            Label("Extract Text (OCR) to Clipboard", systemImage: "text.viewfinder")
                        }
                        
                        Button {
                            removeBackgrounds()
                        } label: {
                            Label("Remove Background (Cutout)", systemImage: "person.and.background.dotted")
                        }
                        
                        Button {
                            stripPhotoMetadata()
                        } label: {
                            Label("Strip EXIF & Location Data", systemImage: "eye.slash")
                        }
                    }
                    
                    Menu("Convert Images") {
                        Button("Convert to PNG") {
                            convertImages(format: .png, ext: "png")
                        }
                        Button("Convert to JPEG") {
                            convertImages(format: .jpeg, ext: "jpg")
                        }
                    }
                    
                    Menu("Resize Images") {
                        Button("Resize to 50%") {
                            resizeImages(scale: 0.5)
                        }
                        Button("Resize to 25%") {
                            resizeImages(scale: 0.25)
                        }
                    }
                }
            }
            
            Divider()
            
            Button(role: .destructive) {
                shelf.clear()
            } label: {
                Label("Clear Shelf", systemImage: "trash")
            }
            
            Button {
                onDismiss()
            } label: {
                Label("Close Shelf", systemImage: "xmark")
            }
        } label: {
            Image(systemName: "chevron.down")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(Color.white.opacity(0.7))
                .frame(width: 26, height: 26)
                .background(Color.white.opacity(0.12))
                .clipShape(Circle())
        }
        .menuStyle(.borderlessButton)
        .frame(width: 26, height: 26)
    }
    
    private func extractOCRText() {
        for item in shelf.items where item.isImage {
            if let url = item.url {
                QuickActionService.extractText(from: url) { text in
                    if text != nil {
                        SoundService.playDrop()
                    }
                }
            }
        }
    }
    
    private func removeBackgrounds() {
        var newItems: [ShelfItem] = []
        for item in shelf.items {
            if item.isImage, let url = item.url {
                if let cutoutURL = QuickActionService.removeBackground(at: url) {
                    newItems.append(ShelfItem.from(url: cutoutURL))
                } else {
                    newItems.append(item)
                }
            } else {
                newItems.append(item)
            }
        }
        shelf.items = newItems
        SoundService.playDrop()
    }
    
    private func stripPhotoMetadata() {
        var newItems: [ShelfItem] = []
        for item in shelf.items {
            if item.isImage, let url = item.url {
                if let cleanURL = QuickActionService.stripMetadata(at: url) {
                    newItems.append(ShelfItem.from(url: cleanURL))
                } else {
                    newItems.append(item)
                }
            } else {
                newItems.append(item)
            }
        }
        shelf.items = newItems
        SoundService.playDrop()
    }
    
    private func convertImages(format: NSBitmapImageRep.FileType, ext: String) {
        var newItems: [ShelfItem] = []
        for item in shelf.items {
            if item.isImage, let url = item.url {
                if let convertedURL = QuickActionService.convertImage(at: url, to: format, fileExtension: ext) {
                    newItems.append(ShelfItem.from(url: convertedURL))
                } else {
                    newItems.append(item)
                }
            } else {
                newItems.append(item)
            }
        }
        shelf.items = newItems
        SoundService.playDrop()
    }
    
    private func resizeImages(scale: CGFloat) {
        var newItems: [ShelfItem] = []
        for item in shelf.items {
            if item.isImage, let url = item.url {
                if let resizedURL = QuickActionService.resizeImage(at: url, scale: scale) {
                    newItems.append(ShelfItem.from(url: resizedURL))
                } else {
                    newItems.append(item)
                }
            } else {
                newItems.append(item)
            }
        }
        shelf.items = newItems
        SoundService.playDrop()
    }
}
