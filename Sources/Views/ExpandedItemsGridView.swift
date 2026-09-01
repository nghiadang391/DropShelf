import SwiftUI
import AppKit

public struct ExpandedItemsGridView: View {
    @ObservedObject var shelf: ShelfModel
    
    private let columns = [
        GridItem(.adaptive(minimum: 76, maximum: 90), spacing: 10)
    ]
    
    public var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(shelf.items) { item in
                    ShelfItemThumbnailView(
                        item: item,
                        onDragStart: {
                            ShelfWindowManager.shared.handleItemDragInitiated(for: shelf.id)
                            DispatchQueue.main.async {
                                shelf.removeItem(id: item.id)
                            }
                        },
                        onDelete: {
                            shelf.removeItem(id: item.id)
                        }
                    )
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 8)
        }
        .frame(maxHeight: 180)
    }
}
