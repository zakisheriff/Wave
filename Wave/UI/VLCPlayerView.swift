import SwiftUI
import VLCKitSPM
import AVKit

/// SwiftUI wrapper for VLCKit's video player view with native-style controls
struct VLCPlayerView: View {
    @ObservedObject var player: MediaPlayer
    @State private var isDragging = false
    @State private var dragValue: Double = 0
    @State private var showControls = true
    @State private var hideTimer: Timer?
    @State private var isHovering = false
    
    var body: some View {
        ZStack {
            // VLC video rendering
            VLCVideoViewRepresentable(player: player)
            
            // Custom controls overlay matching AVPlayer style
            if showControls {
                VStack {
                    Spacer()
                    
                    HStack(spacing: 16) {
                        // Play/Pause
                        Button(action: { player.togglePlayPause() }) {
                            Image(systemName: player.isPlaying ? "pause.fill" : "play.fill")
                                .font(.title2)
                                .foregroundColor(.white)
                        }
                        .buttonStyle(.plain)
                        
                        // Time
                        Text(formatTime(isDragging ? dragValue : player.currentTime))
                            .font(.caption)
                            .foregroundColor(.white)
                            .monospacedDigit()
                        
                        // Slider with smooth seeking
                        Slider(value: Binding(
                            get: { isDragging ? dragValue : player.currentTime },
                            set: { newValue in
                                dragValue = newValue
                                if !isDragging {
                                    isDragging = true
                                }
                            }
                        ), in: 0...(player.duration > 0 ? player.duration : 1), onEditingChanged: { editing in
                            if !editing {
                                // Only seek once when drag ends
                                player.seek(to: dragValue)
                                isDragging = false
                            }
                        })
                        .tint(.white)
                        
                        // Duration
                        Text(formatTime(player.duration))
                            .font(.caption)
                            .foregroundColor(.white)
                            .monospacedDigit()
                        
                        // Volume
                        HStack(spacing: 8) {
                            Image(systemName: volumeIcon)
                                .font(.caption)
                                .foregroundColor(.white)
                            
                            Slider(value: $player.volume, in: 0...1)
                                .frame(width: 80)
                                .tint(.white)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(.ultraThinMaterial)
                    .cornerRadius(10)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
        .onHover { hovering in
            isHovering = hovering
            if hovering {
                withAnimation(.easeInOut(duration: 0.2)) {
                    showControls = true
                }
                resetHideTimer()
            }
        }
        .onAppear {
            showControls = true
            resetHideTimer()
        }
        .onDisappear {
            hideTimer?.invalidate()
        }
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    withAnimation(.easeInOut(duration: 0.2)) {
                        showControls = true
                    }
                    resetHideTimer()
                }
        )
    }
    
    func resetHideTimer() {
        hideTimer?.invalidate()
        hideTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { _ in
            if !isHovering && !isDragging {
                withAnimation(.easeInOut(duration: 0.3)) {
                    showControls = false
                }
            }
        }
    }
    
    var volumeIcon: String {
        if player.volume == 0 {
            return "speaker.slash.fill"
        } else if player.volume < 0.5 {
            return "speaker.wave.1.fill"
        } else {
            return "speaker.wave.2.fill"
        }
    }
    
    func formatTime(_ seconds: Double) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.zeroFormattingBehavior = .pad
        return formatter.string(from: seconds) ?? "0:00"
    }
}

/// Internal representable for VLC video rendering
struct VLCVideoViewRepresentable: NSViewRepresentable {
    @ObservedObject var player: MediaPlayer
    
    func makeNSView(context: Context) -> VLCVideoView {
        let view = VLCVideoView()
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.black.cgColor
        
        // Set the VLC media player if available
        if let vlcPlayer = player.vlcPlayer {
            view.mediaPlayer = vlcPlayer
        }
        
        return view
    }
    
    func updateNSView(_ nsView: VLCVideoView, context: Context) {
        // Update the media player if it changed
        if let vlcPlayer = player.vlcPlayer, nsView.mediaPlayer !== vlcPlayer {
            nsView.mediaPlayer = vlcPlayer
        }
    }
    
    /// Custom VLC video view with proper sizing
    class VLCVideoView: NSView {
        var mediaPlayer: VLCMediaPlayer? {
            didSet {
                mediaPlayer?.drawable = self
            }
        }
        
        override init(frame frameRect: NSRect) {
            super.init(frame: frameRect)
            wantsLayer = true
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func layout() {
            super.layout()
            // Ensure proper layout when view size changes
            mediaPlayer?.drawable = self
        }
    }
}
