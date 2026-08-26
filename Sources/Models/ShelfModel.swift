import Foundation
import AppKit
import SwiftUI

public struct ShelfColor: Identifiable, Hashable {
    public let id: String
    public let name: String
    public let color: Color

    public static let presets: [ShelfColor] = [
        ShelfColor(id: "blue", name: "Classic Blue", color: Color.blue),
        ShelfColor(id: "purple", name: "Violet", color: Color.purple),
        ShelfColor(id: "indigo", name: "Indigo", color: Color.indigo),
        ShelfColor(id: "orange", name: "Sunset Orange", color: Color.orange),
        ShelfColor(id: "green", name: "Emerald", color: Color.green),
        ShelfColor(id: "gray", name: "Graphite", color: Color.gray)
    ]
}

public class ShelfModel: ObservableObject, Identifiable {
    public let id: UUID
    @Published public var title: String
    @Published public var items: [ShelfItem]
    @Published public var isPinned: Bool
    @Published public var isCollapsed: Bool
    @Published public var accentColorId: String
    @Published public var createdAt: Date

    public init(
        id: UUID = UUID(),
        title: String = "Shelf",
        items: [ShelfItem] = [],
        isPinned: Bool = false,
        isCollapsed: Bool = false,
        accentColorId: String = "blue",
        createdAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.items = items
        self.isPinned = isPinned
        self.isCollapsed = isCollapsed
        self.accentColorId = accentColorId
        self.createdAt = createdAt
    }

    public var accentColor: Color {
        ShelfColor.presets.first(where: { $0.id == accentColorId })?.color ?? .blue
    }

    public func addItem(_ item: ShelfItem) {
        if !items.contains(where: { $0.id == item.id || ($0.url != nil && $0.url == item.url) }) {
            items.append(item)
        }
    }

    public func addItems(_ newItems: [ShelfItem]) {
        for item in newItems {
            addItem(item)
        }
    }

    public func removeItem(id: UUID) {
        items.removeAll { $0.id == id }
    }

    public func clear() {
        items.removeAll()
    }
}
