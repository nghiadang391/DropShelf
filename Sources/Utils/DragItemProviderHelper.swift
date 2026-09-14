import Foundation
import AppKit
import UniformTypeIdentifiers

public enum DragItemProviderHelper {
    public static func makeItemProvider(for items: [ShelfItem]) -> NSItemProvider {
        guard !items.isEmpty else { return NSItemProvider() }
        
        let provider = NSItemProvider()
        let fileURLs = items.compactMap { $0.url?.standardizedFileURL }
        
        if !fileURLs.isEmpty {
            let filePaths = fileURLs.map { $0.path }
            
            // 1. Register NSFilenamesPboardType for multi-file Finder / Desktop drag & drop
            if let plistData = try? PropertyListSerialization.data(fromPropertyList: filePaths, format: .xml, options: 0) {
                provider.registerDataRepresentation(forTypeIdentifier: "NSFilenamesPboardType", visibility: .all) { completion in
                    completion(plistData, nil)
                    return nil
                }
            }
            
            // 2. Register first file URL as standard file-url
            if let firstURL = fileURLs.first {
                provider.registerItem(forTypeIdentifier: UTType.fileURL.identifier) { (completionHandler, _, _) in
                    completionHandler?(firstURL as NSURL, nil)
                }
            }
            
            // 3. Register newline-separated paths as plain text (for Terminal, TextEdit, Chat, etc.)
            let combinedPaths = filePaths.joined(separator: "\n")
            provider.registerItem(forTypeIdentifier: UTType.utf8PlainText.identifier) { (completionHandler, _, _) in
                completionHandler?(combinedPaths as NSString, nil)
            }
            provider.registerItem(forTypeIdentifier: UTType.plainText.identifier) { (completionHandler, _, _) in
                completionHandler?(combinedPaths as NSString, nil)
            }
        } else {
            // Text or URL items
            let strings = items.compactMap { item -> String? in
                if let url = item.url {
                    return url.absoluteString
                }
                return item.stringContent ?? item.name
            }
            let combined = strings.joined(separator: "\n")
            
            provider.registerItem(forTypeIdentifier: UTType.utf8PlainText.identifier) { (completionHandler, _, _) in
                completionHandler?(combined as NSString, nil)
            }
            if let firstURL = items.first?.url {
                provider.registerItem(forTypeIdentifier: UTType.url.identifier) { (completionHandler, _, _) in
                    completionHandler?(firstURL as NSURL, nil)
                }
            }
        }
        
        return provider
    }
}
