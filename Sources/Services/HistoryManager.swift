import Foundation
import AppKit

public class HistoryManager: ObservableObject {
    public static let shared = HistoryManager()
    
    @Published public private(set) var recentItems: [ShelfItem] = []
    private let maxHistoryCount = 50
    
    private init() {}
    
    public func recordItems(_ items: [ShelfItem]) {
        DispatchQueue.main.async {
            for item in items {
                if !self.recentItems.contains(where: { $0.id == item.id || ($0.url != nil && $0.url == item.url) }) {
                    self.recentItems.insert(item, at: 0)
                }
            }
            if self.recentItems.count > self.maxHistoryCount {
                self.recentItems = Array(self.recentItems.prefix(self.maxHistoryCount))
            }
        }
    }
    
    public func clearHistory() {
        DispatchQueue.main.async {
            self.recentItems.removeAll()
        }
    }
}
