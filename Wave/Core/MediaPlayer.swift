import Foundation
import AVFoundation
import Combine
import VLCKitSPM

enum PlayerType {
    case native  // AVPlayer
    case vlc     // VLCMediaPlayer
}

class MediaPlayer: ObservableObject {
    @Published var isPlaying: Bool = false
    @Published var duration: Double = 0.0
    @Published var currentTime: Double = 0.0
    @Published var currentURL: URL?
    @Published var volume: Float = 1.0 {
        didSet {
            player?.volume = volume
            vlcPlayer?.audio?.volume = Int32(volume * 100)
        }
    }
    
    // Video Effects
    @Published var brightness: Float = 0.0
    @Published var contrast: Float = 1.0
    @Published var saturation: Float = 1.0
    @Published var hue: Float = 0.0
    @Published var isNoiseReductionEnabled: Bool = false
    @Published var isToneMappingEnabled: Bool = false
    
    // Player type tracking
    @Published var playerType: PlayerType = .native
    
    // AVPlayer instance (for native formats)
    var player: AVPlayer?
    var playerItem: AVPlayerItem?
    private var timeObserver: Any?
    private var cancellables = Set<AnyCancellable>()
    
    // VLC player instance (for non-native formats)
    var vlcPlayer: VLCMediaPlayer?
    private var vlcTimeTimer: Timer?
    
    // Computed property to check if any player is loaded
    var hasActivePlayer: Bool {
        return player != nil || vlcPlayer != nil
    }
    
    init() {}
    
    func load(url: URL) {
        self.currentURL = url
        
        // Determine which player to use based on format
        let useVLC = FormatDetector.requiresVLC(for: url)
        playerType = useVLC ? .vlc : .native
        
        // Clean up both players
        cleanupPlayers()
        
        if useVLC {
            loadWithVLC(url: url)
        } else {
            loadWithAVPlayer(url: url)
        }
    }
    
    private func loadWithAVPlayer(url: URL) {
        // Create new player item and player
        playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)
        player?.volume = volume
        
        // Observe player item status
        playerItem?.publisher(for: \.status)
            .sink { [weak self] status in
                guard let self = self else { return }
                if status == .readyToPlay {
                    self.duration = self.playerItem?.duration.seconds ?? 0
                }
            }
            .store(in: &cancellables)
        
        // Add time observer
        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self = self else { return }
            self.currentTime = time.seconds
        }
    }
    
    private func loadWithVLC(url: URL) {
        // Create VLC media player
        vlcPlayer = VLCMediaPlayer()
        vlcPlayer?.audio?.volume = Int32(volume * 100)
        
        // Create VLC media
        let media = VLCMedia(url: url)
        vlcPlayer?.media = media
        
        // Parse media to get duration
        media.parse(options: [])
        
        // Set up time tracking
        vlcTimeTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            guard let self = self, let vlcPlayer = self.vlcPlayer else { return }
            
            // Update current time
            if vlcPlayer.isPlaying {
                let time = vlcPlayer.time
                self.currentTime = Double(time.intValue) / 1000.0
                
                // Update duration if available
                if let media = vlcPlayer.media, media.length.intValue > 0 {
                    self.duration = Double(media.length.intValue) / 1000.0
                }
            }
        }
    }
    
    private func cleanupPlayers() {
        // Clean up AVPlayer
        if let observer = timeObserver {
            player?.removeTimeObserver(observer)
            timeObserver = nil
        }
        player?.pause()
        player = nil
        playerItem = nil
        cancellables.removeAll()
        
        // Clean up VLC player
        vlcTimeTimer?.invalidate()
        vlcTimeTimer = nil
        vlcPlayer?.stop()
        vlcPlayer = nil
    }
    
    func play() {
        if playerType == .native {
            player?.play()
        } else {
            vlcPlayer?.play()
        }
        isPlaying = true
    }
    
    func pause() {
        if playerType == .native {
            player?.pause()
        } else {
            vlcPlayer?.pause()
        }
        isPlaying = false
    }
    
    func togglePlayPause() {
        if isPlaying {
            pause()
        } else {
            play()
        }
    }
    
    func seek(to time: Double) {
        if playerType == .native {
            let cmTime = CMTime(seconds: time, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
            // Optimistic update to prevent slider jumping back
            self.currentTime = time
            // Precise seek for better accuracy
            player?.seek(to: cmTime, toleranceBefore: .zero, toleranceAfter: .zero)
        } else {
            // VLC uses milliseconds
            let vlcTime = VLCTime(int: Int32(time * 1000))
            vlcPlayer?.time = vlcTime
        }
    }
    
    func resetEffects() {
        brightness = 0.0
        contrast = 1.0
        saturation = 1.0
        hue = 0.0
        isNoiseReductionEnabled = false
        isToneMappingEnabled = false
    }
    
    deinit {
        cleanupPlayers()
    }
}
