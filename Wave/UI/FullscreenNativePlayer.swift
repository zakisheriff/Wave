import SwiftUI
import AVKit

// Fullscreen Native Player
struct FullscreenNativePlayer: View {
    @ObservedObject var player: MediaPlayer
    @ObservedObject var appState: AppState
    @Binding var isFullscreen: Bool
    @Binding var showControls: Bool
    @State private var mouseMovementTimer: Timer?
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            // Video Player (No Built-in Controls)
            AVPlayerView(player: player)
                .ignoresSafeArea()
            
            // Controls Overlay
            if showControls {
                VStack {
                    // Top Bar
                    HStack {
                        Button(action: {
                            withAnimation {
                                isFullscreen = false
                            }
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "chevron.left")
                                Text("Exit Fullscreen")
                            }
                            .font(.headline)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(.ultraThinMaterial.opacity(0.6))
                            .cornerRadius(20)
                        }
                        .buttonStyle(.plain)
                        
                        Spacer()
                        
                        if let url = player.currentURL {
                            Text(url.deletingPathExtension().lastPathComponent)
                                .font(.headline)
                                .foregroundStyle(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(.ultraThinMaterial.opacity(0.6))
                                .cornerRadius(20)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            player.pause()
                            appState.currentMedia = nil
                            isFullscreen = false
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "xmark.circle.fill")
                                Text("Close")
                            }
                            .font(.headline)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(.ultraThinMaterial.opacity(0.6))
                            .cornerRadius(20)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(20)
                    
                    Spacer()
                    
                    // Bottom Controls
                    NativePlayerControls(
                        player: player,
                        isFullscreen: $isFullscreen,
                        onClose: {
                            player.pause()
                            appState.currentMedia = nil
                            isFullscreen = false
                        }
                    )
                    .padding(.horizontal, 40)
                    .padding(.bottom, 40)
                }
                .transition(.opacity)
            }
        }
        .onHover { hovering in
            if hovering {
                withAnimation {
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
            mouseMovementTimer?.invalidate()
        }
        .onKeyPress(.escape) {
            if isFullscreen {
                isFullscreen = false
                return .handled
            }
            return .ignored
        }
    }
    
    func resetHideTimer() {
        mouseMovementTimer?.invalidate()
        mouseMovementTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { _ in
            withAnimation {
                showControls = false
            }
        }
    }
}
