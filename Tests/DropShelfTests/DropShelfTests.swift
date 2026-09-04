import XCTest
import AppKit
import SwiftUI
@testable import DropShelf

final class DropShelfTests: XCTestCase {
    
    func testShelfItemCreationFromFileURL() {
        let tempURL = URL(fileURLWithPath: "/tmp/test_file.txt")
        let item = ShelfItem.from(url: tempURL)
        
        XCTAssertEqual(item.name, "test_file.txt")
        XCTAssertEqual(item.type, .file)
        XCTAssertFalse(item.isImage)
    }
    
    func testShelfItemImageDetection() {
        let imgURL = URL(fileURLWithPath: "/tmp/sample.png")
        let item = ShelfItem.from(url: imgURL)
        
        XCTAssertEqual(item.name, "sample.png")
        XCTAssertEqual(item.type, .image)
        XCTAssertTrue(item.isImage)
    }
    
    func testShelfItemFormattedSize() {
        let item = ShelfItem(name: "BigFile.zip", type: .file, fileSizeBytes: 1024 * 1024 * 5) // 5 MB
        XCTAssertFalse(item.formattedSize.isEmpty)
        XCTAssertTrue(item.formattedSize.contains("MB") || item.formattedSize.contains("5"))
    }
    
    func testShelfItemFromWebURL() {
        let item = ShelfItem.from(text: "https://github.com/nghiadang391/DropShelf")
        
        XCTAssertEqual(item.type, .url)
        XCTAssertEqual(item.name, "github.com")
        XCTAssertNotNil(item.url)
    }
    
    func testShelfModelAddAndRemove() {
        let model = ShelfModel()
        XCTAssertEqual(model.items.count, 0)
        
        let item1 = ShelfItem(name: "File 1", type: .file)
        let item2 = ShelfItem(name: "File 2", type: .file)
        
        model.addItem(item1)
        model.addItem(item2)
        XCTAssertEqual(model.items.count, 2)
        
        model.removeItem(id: item1.id)
        XCTAssertEqual(model.items.count, 1)
        XCTAssertEqual(model.items.first?.id, item2.id)
        
        model.clear()
        XCTAssertEqual(model.items.count, 0)
    }
    
    func testFloatingShelfPanelWindowDragConfig() {
        // Critical regression test: Verify isMovableByWindowBackground is FALSE
        // so that item onDrag gestures are never intercepted by AppKit window moving.
        let model = ShelfModel()
        let panel = FloatingShelfPanel(shelfModel: model, initialPosition: NSPoint(x: 100, y: 100))
        
        XCTAssertFalse(panel.isMovableByWindowBackground, "FloatingShelfPanel must have isMovableByWindowBackground = false to prevent item drag blocking")
        XCTAssertTrue(panel.isFloatingPanel)
        XCTAssertTrue(panel.collectionBehavior.contains(.canJoinAllSpaces))
    }
    
    func testZipCompressionService() {
        let tempDir = URL(fileURLWithPath: NSTemporaryDirectory())
        let testFile = tempDir.appendingPathComponent("test_archive_input.txt")
        try? "DropShelf Unit Test Data".write(to: testFile, atomically: true, encoding: .utf8)
        
        let item = ShelfItem.from(url: testFile)
        let zipURL = QuickActionService.zipItems(items: [item], destinationFolder: tempDir, zipName: "UnitTestArchive.zip")
        
        XCTAssertNotNil(zipURL)
        if let zipURL = zipURL {
            XCTAssertTrue(FileManager.default.fileExists(atPath: zipURL.path))
            try? FileManager.default.removeItem(at: zipURL)
        }
        try? FileManager.default.removeItem(at: testFile)
    }
    
    func testHistoryManager() {
        let manager = HistoryManager.shared
        manager.clearHistory()
        
        let items = [
            ShelfItem(name: "Hist 1", type: .text),
            ShelfItem(name: "Hist 2", type: .text)
        ]
        manager.recordItems(items)
        
        let exp = expectation(description: "History async insert")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertGreaterThanOrEqual(manager.recentItems.count, 2)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    func testWindowDragAreaViewCreation() {
        let view = WindowDragNSView()
        XCTAssertNotNil(view)
        XCTAssertTrue(view.isKind(of: NSView.self))
    }
    
    func testLaunchAtLoginHelper() {
        // Verify helper property access without crash
        let isEnabled = LaunchAtLoginHelper.isEnabled
        XCTAssertNotNil(isEnabled)
    }
}
