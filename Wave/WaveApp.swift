import SwiftUI
import AVFoundation
import Combine

@main
struct WaveApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .background(VisualEffectView(material: .sidebar, blendingMode: .behindWindow))
        }
        .windowStyle(.hiddenTitleBar)
        .commands {
            SidebarCommands()
            CommandGroup(replacing: .newItem) {
                Button("Open File...") {
                    appState.openFile()
                }
                .keyboardShortcut("o", modifiers: .command)
                
                Button("Open Network Stream...") {
                    appState.openNetworkStream()
                }
                .keyboardShortcut("n", modifiers: .command)
            }
        }
    }
}

// Global App State
class AppState: ObservableObject {
    @Published var currentMedia: URL?
    @Published var isPlaying: Bool = false
    
    func openFile() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.movie, .audio]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        
        if panel.runModal() == .OK {
            self.currentMedia = panel.url
        }
    }
    
    func openNetworkStream() {
        let alert = NSAlert()
        alert.messageText = "Open Network Stream"
        alert.informativeText = "Enter the URL of the stream you want to play:"
        alert.addButton(withTitle: "Open")
        alert.addButton(withTitle: "Cancel")
        
        let input = NSTextField(frame: NSRect(x: 0, y: 0, width: 300, height: 24))
        input.placeholderString = "https://example.com/stream.m3u8"
        alert.accessoryView = input
        
        if alert.runModal() == .alertFirstButtonReturn {
            if let url = URL(string: input.stringValue), !input.stringValue.isEmpty {
                self.currentMedia = url
            }
        }
    }
}

// Native Visual Effect View for "Liquid Glass" look
struct VisualEffectView: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode
    
    func makeNSView(context: Context) -> NSVisualEffectView {
        let visualEffectView = NSVisualEffectView()
        visualEffectView.material = material
        visualEffectView.blendingMode = blendingMode
        visualEffectView.state = .active
        return visualEffectView
    }
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
    }
}
