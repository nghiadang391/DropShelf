import Foundation
import AppKit

public class FolderMonitorService {
    public static let shared = FolderMonitorService()
    
    public typealias NewFilesHandler = ([URL]) -> Void
    private var source: DispatchSourceFileSystemObject?
    private var fileDescriptor: CInt = -1
    private var monitoredURL: URL?
    private var knownFiles: Set<String> = []
    
    public var onNewFilesDetected: NewFilesHandler?
    
    private init() {}
    
    public func startMonitoring(folderURL: URL) {
        stopMonitoring()
        self.monitoredURL = folderURL
        
        let path = folderURL.path
        fileDescriptor = open(path, O_EVTONLY)
        guard fileDescriptor >= 0 else { return }
        
        if let contents = try? FileManager.default.contentsOfDirectory(atPath: path) {
            knownFiles = Set(contents)
        }
        
        let source = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: fileDescriptor,
            eventMask: .write,
            queue: DispatchQueue.global(qos: .utility)
        )
        
        source.setEventHandler { [weak self] in
            self?.handleFolderChanged()
        }
        
        source.setCancelHandler { [weak self] in
            if let fd = self?.fileDescriptor, fd >= 0 {
                close(fd)
                self?.fileDescriptor = -1
            }
        }
        
        self.source = source
        source.resume()
    }
    
    public func stopMonitoring() {
        source?.cancel()
        source = nil
    }
    
    private func handleFolderChanged() {
        guard let url = monitoredURL else { return }
        guard let contents = try? FileManager.default.contentsOfDirectory(atPath: url.path) else { return }
        
        let currentFiles = Set(contents.filter { !$0.hasPrefix(".") && !$0.hasSuffix(".download") && !$0.hasSuffix(".crdownload") })
        let newFileNames = currentFiles.subtracting(knownFiles)
        knownFiles = currentFiles
        
        guard !newFileNames.isEmpty else { return }
        
        let newURLs = newFileNames.map { url.appendingPathComponent($0) }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            let validURLs = newURLs.filter { FileManager.default.fileExists(atPath: $0.path) }
            if !validURLs.isEmpty {
                self?.onNewFilesDetected?(validURLs)
            }
        }
    }
}
