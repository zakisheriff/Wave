import Foundation
import Combine
import QuickLookThumbnailing
import AppKit

enum MediaCategory: String, CaseIterable {
    case all = "All"
    case video = "Video"
    case music = "Music"
    case image = "Image"
}

enum SortOption: String, CaseIterable {
    case name = "Name"
    case date = "Date"
    case size = "Size"
}

class LibraryManager: ObservableObject {
    @Published var items: [MediaItem] = []
    @Published var isScanning: Bool = false
    @Published var thumbnails: [UUID: NSImage] = [:]
    
    private let fileManager = FileManager.default
    
    // Restrict to natively supported formats to avoid playback issues
    private let videoExtensions = ["mp4", "mov", "m4v", "mkv", "avi", "webm"]
    private let audioExtensions = ["mp3", "m4a", "wav", "flac", "aac"]
    private let imageExtensions = ["jpg", "jpeg", "png", "gif", "heic"]
    
    func scanLibrary() {
        isScanning = true
        
        Task {
            var newItems: [MediaItem] = []
            
            let directories: [FileManager.SearchPathDirectory] = [.moviesDirectory, .musicDirectory, .downloadsDirectory, .picturesDirectory]
            
            for directory in directories {
                if let url = fileManager.urls(for: directory, in: .userDomainMask).first {
                    let items = scanDirectory(at: url)
                    newItems.append(contentsOf: items)
                }
            }
            
            DispatchQueue.main.async {
                self.items = newItems.sorted(by: { $0.title < $1.title })
                self.isScanning = false
                self.generateThumbnails(for: newItems)
            }
        }
    }
    
    private func scanDirectory(at url: URL) -> [MediaItem] {
        var items: [MediaItem] = []
        
        guard let enumerator = fileManager.enumerator(at: url, includingPropertiesForKeys: [.isRegularFileKey, .contentModificationDateKey, .fileSizeKey], options: [.skipsHiddenFiles, .skipsPackageDescendants]) else {
            return []
        }
        
        for case let fileURL as URL in enumerator {
            let ext = fileURL.pathExtension.lowercased()
            if videoExtensions.contains(ext) || audioExtensions.contains(ext) || imageExtensions.contains(ext) {
                items.append(MediaItem(url: fileURL))
            }
        }
        
        return items
    }
    
    func category(for item: MediaItem) -> MediaCategory {
        let ext = item.url.pathExtension.lowercased()
        if videoExtensions.contains(ext) { return .video }
        if audioExtensions.contains(ext) { return .music }
        if imageExtensions.contains(ext) { return .image }
        return .all
    }
    
    private func generateThumbnails(for items: [MediaItem]) {
        let size = CGSize(width: 320, height: 180)
        let scale = NSScreen.main?.backingScaleFactor ?? 2.0
        
        Task.detached(priority: .background) {
            var batch: [UUID: NSImage] = [:]
            var count = 0
            
            for item in items {
                let request = QLThumbnailGenerator.Request(fileAt: item.url, size: size, scale: scale, representationTypes: .thumbnail)
                
                do {
                    let thumbnail = try await QLThumbnailGenerator.shared.generateBestRepresentation(for: request)
                    batch[item.id] = thumbnail.nsImage
                    count += 1
                    
                    // Update UI in batches of 5 or every few items to keep it smooth but responsive
                    if count % 5 == 0 {
                        let currentBatch = batch
                        batch.removeAll()
                        await MainActor.run {
                            for (id, image) in currentBatch {
                                self.thumbnails[id] = image
                            }
                        }
                        // Small sleep to yield to main thread if needed, though MainActor.run handles it
                        try? await Task.sleep(nanoseconds: 10_000_000) // 10ms
                    }
                } catch {
                    print("Failed to generate thumbnail for \(item.url.lastPathComponent): \(error)")
                }
            }
            
            // Flush remaining
            if !batch.isEmpty {
                let finalBatch = batch
                await MainActor.run {
                    for (id, image) in finalBatch {
                        self.thumbnails[id] = image
                    }
                }
            }
        }
    }
    
    func sortItems(_ items: [MediaItem], by option: SortOption) -> [MediaItem] {
        switch option {
        case .name:
            return items.sorted { $0.title < $1.title }
        case .date:
            return items.sorted {
                let date1 = (try? $0.url.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate) ?? Date.distantPast
                let date2 = (try? $1.url.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate) ?? Date.distantPast
                return date1 > date2
            }
        case .size:
            return items.sorted {
                let size1 = (try? $0.url.resourceValues(forKeys: [.fileSizeKey]).fileSize) ?? 0
                let size2 = (try? $1.url.resourceValues(forKeys: [.fileSizeKey]).fileSize) ?? 0
                return size1 > size2
            }
        }
    }
}
