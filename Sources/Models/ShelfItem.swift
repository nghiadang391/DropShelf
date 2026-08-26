import Foundation
import AppKit
import UniformTypeIdentifiers

public enum ShelfItemType: String, Codable {
    case file
    case image
    case text
    case url
}

public struct ShelfItem: Identifiable, Equatable, Hashable {
    public let id: UUID
    public var name: String
    public var type: ShelfItemType
    public var url: URL?
    public var stringContent: String?
    public var fileSizeBytes: Int64
    public var dateAdded: Date
    public var customThumbnail: NSImage?

    public init(
        id: UUID = UUID(),
        name: String,
        type: ShelfItemType,
        url: URL? = nil,
        stringContent: String? = nil,
        fileSizeBytes: Int64 = 0,
        dateAdded: Date = Date(),
        customThumbnail: NSImage? = nil
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.url = url
        self.stringContent = stringContent
        self.fileSizeBytes = fileSizeBytes
        self.dateAdded = dateAdded
        self.customThumbnail = customThumbnail
    }

    public static func == (lhs: ShelfItem, rhs: ShelfItem) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public var formattedSize: String {
        guard fileSizeBytes > 0 else { return "" }
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useAll]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: fileSizeBytes)
    }

    public var isImage: Bool {
        if type == .image { return true }
        guard let url = url else { return false }
        let ext = url.pathExtension.lowercased()
        return ["png", "jpg", "jpeg", "webp", "heic", "gif", "tiff", "svg", "bmp"].contains(ext)
    }

    public static func from(url: URL) -> ShelfItem {
        let name = url.lastPathComponent
        var size: Int64 = 0
        var isDir: ObjCBool = false

        if FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir) {
            if !isDir.boolValue, let attrs = try? FileManager.default.attributesOfItem(atPath: url.path) {
                size = (attrs[.size] as? NSNumber)?.int64Value ?? 0
            }
        }

        let ext = url.pathExtension.lowercased()
        let isImg = ["png", "jpg", "jpeg", "webp", "heic", "gif", "tiff", "svg", "bmp"].contains(ext)
        let itemType: ShelfItemType = isImg ? .image : (url.isFileURL ? .file : .url)

        return ShelfItem(
            name: name.isEmpty ? url.absoluteString : name,
            type: itemType,
            url: url,
            fileSizeBytes: size
        )
    }

    public static func from(text: String) -> ShelfItem {
        if let linkUrl = URL(string: text.trimmingCharacters(in: .whitespacesAndNewlines)),
           linkUrl.scheme == "http" || linkUrl.scheme == "https" {
            return ShelfItem(
                name: linkUrl.host ?? "Web Link",
                type: .url,
                url: linkUrl,
                stringContent: text
            )
        }
        let preview = text.prefix(30).replacingOccurrences(of: "\n", with: " ")
        return ShelfItem(
            name: preview.isEmpty ? "Snippet" : String(preview),
            type: .text,
            stringContent: text
        )
    }
}
