import SwiftUI
import AVFoundation

// Custom AVPlayerView without built-in controls
struct AVPlayerView: NSViewRepresentable {
    @ObservedObject var player: MediaPlayer
    
    func makeNSView(context: Context) -> PlayerView {
        let view = PlayerView()
        view.player = player.player
        return view
    }
    
    func updateNSView(_ nsView: PlayerView, context: Context) {
        if nsView.player !== player.player {
            nsView.player = player.player
        }
    }
    
    class PlayerView: NSView {
        var playerLayer: AVPlayerLayer?
        
        var player: AVPlayer? {
            didSet {
                playerLayer?.player = player
            }
        }
        
        override init(frame frameRect: NSRect) {
            super.init(frame: frameRect)
            wantsLayer = true
            
            let layer = AVPlayerLayer()
            layer.videoGravity = .resizeAspect
            self.layer = layer
            self.playerLayer = layer
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func layout() {
            super.layout()
            playerLayer?.frame = bounds
        }
    }
}
