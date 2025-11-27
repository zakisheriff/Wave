import SwiftUI

// Native macOS Tahoe-style Player Controls
struct NativePlayerControls: View {
    @ObservedObject var player: MediaPlayer
    @Binding var isFullscreen: Bool
    let onClose: () -> Void
    
    @State private var isDragging = false
    @State private var dragValue: Double = 0
    
    var body: some View {
        VStack(spacing: 12) {
            // Time Slider
            let duration = player.duration
            VStack(spacing: 6) {
                // Native macOS slider
                FluidSlider(
                    value: Binding(
                        get: { isDragging ? dragValue : player.currentTime },
                        set: { newValue in
                            if !isDragging {
                                player.seek(to: newValue)
                            } else {
                                dragValue = newValue
                            }
                        }
                    ),
                    range: 0...(duration > 0 ? duration : 1),
                    onEditingChanged: { editing in
                        isDragging = editing
                    }
                )
                .frame(height: 24)
                .onChange(of: isDragging) { _, dragging in
                    if !dragging && dragValue > 0 {
                        player.seek(to: dragValue)
                    }
                }
                
                // Time labels
                HStack {
                    Text(formatTime(isDragging ? dragValue : player.currentTime))
                        .monospacedDigit()
                    Spacer()
                    Text(formatTime(duration))
                        .monospacedDigit()
                }
                .font(.caption)
                .foregroundStyle(.white.opacity(0.9))
            }
            
            // Control Buttons
            HStack(spacing: 24) {
                // Rewind
                GlassButton(systemImage: "gobackward.10", size: .title2) {
                    player.seek(to: max(0, player.currentTime - 10))
                }
                .keyboardShortcut(.leftArrow, modifiers: [])
                
                // Play/Pause
                GlassButton(systemImage: player.isPlaying ? "pause.circle.fill" : "play.circle.fill", size: .system(size: 44)) {
                    player.togglePlayPause()
                }
                .keyboardShortcut(.space, modifiers: [])
                
                // Forward
                GlassButton(systemImage: "goforward.10", size: .title2) {
                    player.seek(to: min(duration, player.currentTime + 10))
                }
                .keyboardShortcut(.rightArrow, modifiers: [])
                
                Spacer()
                
                // Volume
                HStack(spacing: 8) {
                    Image(systemName: volumeIcon)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.9))
                    
                    Slider(value: $player.volume, in: 0...1)
                        .frame(width: 80)
                        .tint(.white)
                }
                
                // Fullscreen
                GlassButton(systemImage: "arrow.up.left.and.arrow.down.right", size: .title3) {
                    isFullscreen.toggle()
                }
                .keyboardShortcut("f", modifiers: [])
                
                // Close
                GlassButton(systemImage: "xmark.circle.fill", size: .title3, action: onClose)
            }
        }
        .padding(20)
        .background(
            ZStack {
                // Base glass layer
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                
                // Gradient overlay for depth
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.black.opacity(0.3),
                                Color.black.opacity(0.1)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                
                // Top highlight
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.15),
                                Color.clear
                            ],
                            startPoint: .top,
                            endPoint: .center
                        )
                    )
                
                // Subtle border
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.2),
                                Color.white.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
        )
        .shadow(color: .black.opacity(0.4), radius: 25, x: 0, y: 12)
        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
        .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 2)
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
