//
//  ContentView.swift
//  Wave
//
//  Created by Zaki Sheriff on 2025-11-26.
//

import SwiftUI
import UniformTypeIdentifiers
import AVKit

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var player = MediaPlayer()
    @State private var isFullscreen: Bool = false
    @State private var showControls: Bool = true
    @State private var controlsTimer: Timer?
    @State private var isDraggingOver: Bool = false
    
    var body: some View {
        ZStack {
            if !player.hasActivePlayer {
                // Empty State - Liquid Glass Design
                ZStack {
                    // Multi-layer glass background
                    VisualEffectView(material: .underWindowBackground, blendingMode: .behindWindow)
                        .ignoresSafeArea()
                    
                    // Subtle gradient overlay
                    LinearGradient(
                        colors: [
                            Color.accentColor.opacity(0.03),
                            Color.clear,
                            Color.accentColor.opacity(0.05)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()
                    
                    VStack(spacing: 60) {
                        Spacer()
                        
                        // App Logo with Glass Container
                        ZStack {
                            // Outer glow
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: [
                                            Color.accentColor.opacity(0.2),
                                            Color.clear
                                        ],
                                        center: .center,
                                        startRadius: 60,
                                        endRadius: 100
                                    )
                                )
                                .frame(width: 200, height: 200)
                                .blur(radius: 20)
                            
                            // Glass container
                            Circle()
                                .fill(.ultraThinMaterial)
                                .frame(width: 160, height: 160)
                                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                                .shadow(color: .black.opacity(0.05), radius: 20, x: 0, y: 10)
                            
                            // Inner gradient
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(0.1),
                                            Color.clear
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 160, height: 160)
                            
                            // App Logo
                            Image("AppLogo")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 100, height: 100)
                                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                        }
                        .scaleEffect(isDraggingOver ? 1.1 : 1.0)
                        .animation(.spring(response: 0.4, dampingFraction: 0.6), value: isDraggingOver)
                        
                        // Title and Subtitle
                        VStack(spacing: 18) {
                            Text("Wave")
                                .font(.system(size: 48, weight: .bold, design: .rounded))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.primary, .primary.opacity(0.8)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                            
                            Text("Drop a video or audio file to play")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(.secondary)
                        }
                        
                        // Glass Button
                        Button(action: selectFile) {
                            HStack(spacing: 10) {
                                Image(systemName: "folder")
                                    .font(.system(size: 16, weight: .semibold))
                                Text("Choose File")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            .foregroundStyle(.white)
                            .padding(.horizontal, 32)
                            .padding(.vertical, 14)
                            .background(
                                ZStack {
                                    // Glass background
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(.ultraThinMaterial)
                                    
                                    // Accent gradient overlay
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(
                                            LinearGradient(
                                                colors: [
                                                    Color.accentColor.opacity(0.8),
                                                    Color.accentColor
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                    
                                    // Top highlight
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(
                                            LinearGradient(
                                                colors: [
                                                    Color.white.opacity(0.3),
                                                    Color.clear
                                                ],
                                                startPoint: .top,
                                                endPoint: .center
                                            )
                                        )
                                }
                            )
                            .shadow(color: Color.accentColor.opacity(0.3), radius: 15, x: 0, y: 8)
                            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                        }
                        .buttonStyle(.plain)
                        .scaleEffect(isDraggingOver ? 1.08 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isDraggingOver)
                        
                        Spacer()
                        
                        // Supported Formats - Glass Pills
                        VStack(spacing: 16) {
                            Text("Supported Formats")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(.tertiary)
                                .textCase(.uppercase)
                                .tracking(1.5)
                            
                            HStack(spacing: 12) {
                                GlassFormatBadge(text: "MP4")
                                GlassFormatBadge(text: "MOV")
                                GlassFormatBadge(text: "MKV")
                                GlassFormatBadge(text: "WebM")
                                GlassFormatBadge(text: "MP3")
                                GlassFormatBadge(text: "M4A")
                            }
                        }
                        .padding(.bottom, 70)
                    }
                    
                    // Animated Glass Drop Zone Indicator
                    if isDraggingOver {
                        RoundedRectangle(cornerRadius: 24)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [
                                        Color.accentColor.opacity(0.8),
                                        Color.accentColor.opacity(0.4),
                                        Color.accentColor.opacity(0.8)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                style: StrokeStyle(lineWidth: 4, dash: [15, 8])
                            )
                            .background(
                                RoundedRectangle(cornerRadius: 24)
                                    .fill(Color.accentColor.opacity(0.05))
                                    .blur(radius: 10)
                            )
                            .padding(40)
                            .shadow(color: Color.accentColor.opacity(0.3), radius: 20, x: 0, y: 0)
                            .allowsHitTesting(false)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
            } else {
                // Playing State - Unified custom player for both
                UnifiedPlayerView(player: player)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
            }
        }
        .onDrop(of: [.fileURL], isTargeted: $isDraggingOver) { providers in
            handleDrop(providers: providers)
        }
        .onChange(of: appState.currentMedia) { _, newURL in
            if let url = newURL {
                player.load(url: url)
                player.play()
            }
        }
    }
    
    func selectFile() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowedContentTypes = [
            .movie, .video, .audio, .mpeg4Movie, .quickTimeMovie,
            .mpeg4Audio, .mp3, .wav, .aiff
        ]
        // Add custom types for MKV, WebM, etc.
        panel.allowsOtherFileTypes = true
        
        panel.begin { response in
            if response == .OK, let url = panel.url {
                appState.currentMedia = url
            }
        }
    }
    
    func handleDrop(providers: [NSItemProvider]) -> Bool {
        guard let provider = providers.first else { return false }
        
        _ = provider.loadObject(ofClass: URL.self) { url, error in
            guard let url = url, error == nil else { return }
            
            let videoExtensions = ["mp4", "mov", "m4v", "avi", "mkv", "webm", "flv", "wmv", "ogv", "3gp"]
            let audioExtensions = ["mp3", "m4a", "aac", "wav", "aiff", "flac"]
            let ext = url.pathExtension.lowercased()
            
            if videoExtensions.contains(ext) || audioExtensions.contains(ext) {
                DispatchQueue.main.async {
                    appState.currentMedia = url
                }
            }
        }
        
        return true
    }
    
    func resetControlsTimer() {
        controlsTimer?.invalidate()
        controlsTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { _ in
            withAnimation(.easeInOut(duration: 0.2)) {
                showControls = false
            }
        }
    }
    
    func setupMouseTracking() {
        // Auto-hide controls after 3 seconds of inactivity
        NSEvent.addLocalMonitorForEvents(matching: .mouseMoved) { event in
            if player.player != nil {
                showControls = true
                resetControlsTimer()
            }
            return event
        }
    }
}

// Glass Format Badge - Liquid Glass Design
struct GlassFormatBadge: View {
    let text: String
    @State private var isHovered = false
    
    var body: some View {
        Text(text)
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(.primary)
            .padding(.horizontal, 14)
            .padding(.vertical, 7)
            .background(
                ZStack {
                    // Glass base
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.ultraThinMaterial)
                    
                    // Subtle gradient
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.1),
                                    Color.clear
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    // Border
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(Color.primary.opacity(0.1), lineWidth: 0.5)
                }
            )
            .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 2)
            .shadow(color: .black.opacity(0.03), radius: 8, x: 0, y: 4)
            .scaleEffect(isHovered ? 1.05 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isHovered)
            .onHover { hovering in
                isHovered = hovering
            }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState())
}
