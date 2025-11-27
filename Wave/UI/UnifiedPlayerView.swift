import SwiftUI
import AVKit
import VLCKitSPM

/// Unified player view for both AVPlayer and VLC with identical controls
struct UnifiedPlayerView: View {
    @ObservedObject var player: MediaPlayer
    @State private var isDragging = false
    @State private var dragValue: Double = 0
    @State private var showControls = true
    @State private var hideTimer: Timer?
    @State private var isHovering = false
    
    var body: some View {
        ZStack {
            // Black background - no transparent borders
            Color.black
                .ignoresSafeArea()
            
            // Video rendering layer
            if player.playerType == .native {
                // AVPlayer rendering
                AVPlayerViewRepresentable(player: player)
            } else {
                // VLC rendering
                VLCVideoViewRepresentable(player: player)
            }
            
            // Unified controls overlay
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
                        
                        // Slider with live preview
                        Slider(value: Binding(
                            get: { isDragging ? dragValue : player.currentTime },
                            set: { newValue in
                                dragValue = newValue
                                if !isDragging {
                                    isDragging = true
                                }
                                // Live preview during drag
                                player.seek(to: newValue)
                            }
                        ), in: 0...(player.duration > 0 ? player.duration : 1), onEditingChanged: { editing in
                            isDragging = editing
                            if !editing {
                                // Final seek when drag ends
                                player.seek(to: dragValue)
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

/// AVPlayer video rendering
struct AVPlayerViewRepresentable: NSViewRepresentable {
    @ObservedObject var player: MediaPlayer
    
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.black.cgColor
        
        if let avPlayer = player.player {
            let playerLayer = AVPlayerLayer(player: avPlayer)
            playerLayer.videoGravity = .resizeAspect
            playerLayer.frame = view.bounds
            playerLayer.autoresizingMask = [.layerWidthSizable, .layerHeightSizable]
            view.layer?.addSublayer(playerLayer)
            view.layer = playerLayer
        }
        
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {
        if let playerLayer = nsView.layer as? AVPlayerLayer,
           let avPlayer = player.player,
           playerLayer.player !== avPlayer {
            playerLayer.player = avPlayer
        }
    }
}
