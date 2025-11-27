import Foundation

/// Utility for detecting video/audio formats and determining which player to use
enum FormatDetector {
    
    // Formats natively supported by AVPlayer
    static let nativeFormats: Set<String> = [
        // Video
        "mp4", "mov", "m4v", "qt",
        // Audio
        "mp3", "m4a", "aac", "wav", "aiff", "caf"
    ]
    
    // Formats requiring VLC player
    static let vlcFormats: Set<String> = [
        // Video
        "mkv", "webm", "avi", "flv", "wmv", "ogv", "3gp", "mpg", "mpeg",
        "vob", "ts", "mts", "m2ts", "divx", "xvid",
        // Audio
        "flac", "ogg", "opus", "wma", "ape", "mka"
    ]
    
    /// Determines if a file requires VLC player based on its extension
    /// - Parameter url: The file URL to check
    /// - Returns: True if VLC is required, false if native AVPlayer can handle it
    static func requiresVLC(for url: URL) -> Bool {
        let ext = url.pathExtension.lowercased()
        
        // Check if it's a VLC-only format
        if vlcFormats.contains(ext) {
            return true
        }
        
        // Check if it's a native format
        if nativeFormats.contains(ext) {
            return false
        }
        
        // Unknown format - default to VLC for better compatibility
        return true
    }
    
    /// Returns a user-friendly description of the format
    /// - Parameter url: The file URL
    /// - Returns: Format description string
    static func formatDescription(for url: URL) -> String {
        let ext = url.pathExtension.uppercased()
        
        if nativeFormats.contains(url.pathExtension.lowercased()) {
            return "\(ext) (Native)"
        } else if vlcFormats.contains(url.pathExtension.lowercased()) {
            return "\(ext) (VLC)"
        } else {
            return "\(ext) (Unknown)"
        }
    }
}
