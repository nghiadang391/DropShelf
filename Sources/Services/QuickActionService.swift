import Foundation
import AppKit
import Vision
import CoreImage
import ImageIO

public enum QuickActionService {
    
    // MARK: - OCR Text Extraction (Vision)
    public static func extractText(from url: URL, completion: @escaping (String?) -> Void) {
        guard let cgImage = NSImage(contentsOf: url)?.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            completion(nil)
            return
        }
        
        let request = VNRecognizeTextRequest { request, error in
            guard let observations = request.results as? [VNRecognizedTextObservation], error == nil else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            
            let recognizedStrings = observations.compactMap { observation in
                observation.topCandidates(1).first?.string
            }
            
            let fullText = recognizedStrings.joined(separator: "\n")
            DispatchQueue.main.async {
                if !fullText.isEmpty {
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(fullText, forType: .string)
                    completion(fullText)
                } else {
                    completion(nil)
                }
            }
        }
        
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                DispatchQueue.main.async { completion(nil) }
            }
        }
    }
    
    // MARK: - Strip EXIF & GPS Metadata
    public static func stripMetadata(at url: URL) -> URL? {
        guard let source = CGImageSourceCreateWithURL(url as CFURL, nil) else { return nil }
        guard let cgImage = CGImageSourceCreateImageAtIndex(source, 0, nil) else { return nil }
        
        let baseName = url.deletingPathExtension().lastPathComponent
        let ext = url.pathExtension
        let destURL = url.deletingLastPathComponent().appendingPathComponent("\(baseName)_no_meta.\(ext)")
        
        guard let uti = CGImageSourceGetType(source),
              let destination = CGImageDestinationCreateWithURL(destURL as CFURL, uti, 1, nil) else {
            return nil
        }
        
        // Write without Exif / GPS dictionary
        CGImageDestinationAddImage(destination, cgImage, nil)
        if CGImageDestinationFinalize(destination) {
            return destURL
        }
        return nil
    }
    
    // MARK: - Remove Image Background
    public static func removeBackground(at url: URL) -> URL? {
        guard let nsImage = NSImage(contentsOf: url),
              let cgImage = nsImage.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            return nil
        }
        
        let ciImage = CIImage(cgImage: cgImage)
        
        // Check for macOS 14+ Vision Foreground Mask
        if #available(macOS 14.0, *) {
            let request = VNGenerateForegroundInstanceMaskRequest()
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try handler.perform([request])
                if let result = request.results?.first,
                   let maskPixelBuffer = try? result.generateScaledMaskForImage(forInstances: result.allInstances, from: handler) {
                    let maskImage = CIImage(cvPixelBuffer: maskPixelBuffer)
                    let blendFilter = CIFilter(name: "CIBlendWithMask")
                    blendFilter?.setValue(ciImage, forKey: kCIInputImageKey)
                    blendFilter?.setValue(CIImage.empty(), forKey: kCIInputBackgroundImageKey)
                    blendFilter?.setValue(maskImage, forKey: kCIInputMaskImageKey)
                    
                    if let outputCIImage = blendFilter?.outputImage {
                        let rep = NSCIImageRep(ciImage: outputCIImage)
                        let resultNSImage = NSImage(size: rep.size)
                        resultNSImage.addRepresentation(rep)
                        
                        if let tiffData = resultNSImage.tiffRepresentation,
                           let bitmap = NSBitmapImageRep(data: tiffData),
                           let pngData = bitmap.representation(using: .png, properties: [:]) {
                            let baseName = url.deletingPathExtension().lastPathComponent
                            let destURL = url.deletingLastPathComponent().appendingPathComponent("\(baseName)_cutout.png")
                            try? pngData.write(to: destURL)
                            return destURL
                        }
                    }
                }
            } catch {}
        }
        
        // Fallback: Save transparent PNG copy
        return convertImage(at: url, to: .png, fileExtension: "png")
    }
    
    // MARK: - Image Resize
    public static func resizeImage(at url: URL, scale: CGFloat) -> URL? {
        guard let sourceImage = NSImage(contentsOf: url) else { return nil }
        guard let rep = sourceImage.representations.first else { return nil }
        
        let newWidth = CGFloat(rep.pixelsWide) * scale
        let newHeight = CGFloat(rep.pixelsHigh) * scale
        guard newWidth > 0 && newHeight > 0 else { return nil }
        
        let newSize = NSSize(width: newWidth, height: newHeight)
        let targetImage = NSImage(size: newSize)
        targetImage.lockFocus()
        sourceImage.draw(in: NSRect(origin: .zero, size: newSize),
                         from: NSRect(origin: .zero, size: sourceImage.size),
                         operation: .copy,
                         fraction: 1.0)
        targetImage.unlockFocus()
        
        guard let tiffData = targetImage.tiffRepresentation,
              let bitmapRep = NSBitmapImageRep(data: tiffData),
              let pngData = bitmapRep.representation(using: .png, properties: [:]) else {
            return nil
        }
        
        let baseName = url.deletingPathExtension().lastPathComponent
        let ext = url.pathExtension
        let destName = "\(baseName)_\(Int(scale * 100))%.\(ext)"
        let destURL = url.deletingLastPathComponent().appendingPathComponent(destName)
        
        do {
            try pngData.write(to: destURL)
            return destURL
        } catch {
            return nil
        }
    }
    
    // MARK: - Image Format Conversion
    public static func convertImage(at url: URL, to format: NSBitmapImageRep.FileType, fileExtension: String) -> URL? {
        guard let sourceImage = NSImage(contentsOf: url),
              let tiffData = sourceImage.tiffRepresentation,
              let bitmapRep = NSBitmapImageRep(data: tiffData),
              let convertedData = bitmapRep.representation(using: format, properties: [:]) else {
            return nil
        }
        
        let baseName = url.deletingPathExtension().lastPathComponent
        let destURL = url.deletingLastPathComponent().appendingPathComponent("\(baseName).\(fileExtension)")
        
        do {
            try convertedData.write(to: destURL)
            return destURL
        } catch {
            return nil
        }
    }
    
    // MARK: - Zip Archive
    public static func zipItems(items: [ShelfItem], destinationFolder: URL, zipName: String = "Archive.zip") -> URL? {
        let fileURLs = items.compactMap { $0.url }
        guard !fileURLs.isEmpty else { return nil }
        
        var destination = destinationFolder.appendingPathComponent(zipName)
        var counter = 1
        while FileManager.default.fileExists(atPath: destination.path) {
            destination = destinationFolder.appendingPathComponent("Archive_\(counter).zip")
            counter += 1
        }
        
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/zip")
        
        var arguments = ["-r", "-q", destination.path]
        for file in fileURLs {
            arguments.append(file.path)
        }
        process.arguments = arguments
        
        do {
            try process.run()
            process.waitUntilExit()
            if process.terminationStatus == 0 {
                return destination
            }
        } catch {
            return nil
        }
        return nil
    }
    
    // MARK: - Clipboard Export
    public static func copyToClipboard(items: [ShelfItem]) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        
        let fileURLs = items.compactMap { $0.url }
        if !fileURLs.isEmpty {
            pasteboard.writeObjects(fileURLs as [NSPasteboardWriting])
        } else {
            let texts = items.compactMap { $0.stringContent ?? $0.name }
            if !texts.isEmpty {
                pasteboard.setString(texts.joined(separator: "\n"), forType: .string)
            }
        }
    }
}
