import Foundation
import AppKit
import SwiftUI

public class MenuBarManager: NSObject {
    public static let shared = MenuBarManager()
    
    private var statusItem: NSStatusItem?
    private var preferencesWindow: NSWindow?
    
    public func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        
        if let button = statusItem?.button {
            button.image = MenuBarIconHelper.createCleanMenuBarIcon()
            button.action = #selector(statusBarButtonClicked(_:))
            button.target = self
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
    }
    
    @objc private func statusBarButtonClicked(_ sender: NSStatusBarButton) {
        guard let event = NSApp.currentEvent else { return }
        
        if event.type == .rightMouseUp || (event.modifierFlags.contains(.control)) {
            showContextMenu()
        } else {
            let mouseLoc = NSEvent.mouseLocation
            ShelfWindowManager.shared.createShelf(at: mouseLoc)
        }
    }
    
    private func showContextMenu() {
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "New Shelf (⌥ + Space)", action: #selector(newShelfClicked), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Close All Shelves", action: #selector(closeAllShelvesClicked), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Settings...", action: #selector(openPreferences), keyEquivalent: ","))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit DropShelf", action: #selector(quitApp), keyEquivalent: "q"))
        
        for item in menu.items {
            item.target = self
        }
        
        statusItem?.menu = menu
        statusItem?.button?.performClick(nil)
        statusItem?.menu = nil
    }
    
    @objc private func newShelfClicked() {
        ShelfWindowManager.shared.createShelf()
    }
    
    @objc private func closeAllShelvesClicked() {
        ShelfWindowManager.shared.closeAllShelves()
    }
    
    @objc public func openPreferences() {
        if preferencesWindow == nil {
            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 440, height: 320),
                styleMask: [.titled, .closable],
                backing: .buffered,
                defer: false
            )
            window.title = "DropShelf Settings"
            window.center()
            window.contentView = NSHostingView(rootView: PreferencesView())
            preferencesWindow = window
        }
        preferencesWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    @objc private func quitApp() {
        NSApplication.shared.terminate(nil)
    }
}
