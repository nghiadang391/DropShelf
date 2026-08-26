import Foundation
import AppKit
import QuickLookUI

public enum QuickLookHelper {
    public static func preview(url: URL) {
        NSWorkspace.shared.open(url)
    }
}
