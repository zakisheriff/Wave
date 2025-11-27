import AVFoundation
import SwiftUI
import Combine

class ThumbnailGenerator: ObservableObject {
    private var generator: AVAssetImageGenerator?
    @Published var currentThumbnail: NSImage?
    
    func load(asset: AVAsset) {
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        generator.requestedTimeToleranceBefore = .zero
        generator.requestedTimeToleranceAfter = .zero
        self.generator = generator
    }
    
    func generateThumbnail(for time: Double) {
        guard let generator = generator else { return }
        
        let cmTime = CMTime(seconds: time, preferredTimescale: 600)
        
        // Cancel previous request if needed (not exposed in simple API, but we just fire new ones)
        
        Task {
            do {
                let (cgImage, _) = try await generator.image(at: cmTime)
                let nsImage = NSImage(cgImage: cgImage, size: NSSize(width: cgImage.width, height: cgImage.height))
                DispatchQueue.main.async {
                    self.currentThumbnail = nsImage
                }
            } catch {
                // Ignore errors (e.g. cancellation or out of bounds)
            }
        }
    }
}
