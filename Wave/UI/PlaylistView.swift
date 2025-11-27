import SwiftUI

struct PlaylistView: View {
    @ObservedObject var playlistManager: PlaylistManager
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        Table(playlistManager.items) {
            TableColumn("Title", value: \.title)
            TableColumn("Duration") { item in
                Text(formatTime(item.duration))
                    .monospacedDigit()
            }
        }
        .contextMenu(forSelectionType: MediaItem.ID.self) { selection in
            Button("Play") {
                // Play logic
            }
            Button("Remove") {
                // Remove logic
            }
        } primaryAction: { selection in
             if let id = selection.first, let item = playlistManager.items.first(where: { $0.id == id }) {
                 appState.currentMedia = item.url
             }
        }
        .navigationTitle("Playlist")
    }
    
    func formatTime(_ seconds: Double) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.zeroFormattingBehavior = .pad
        return formatter.string(from: seconds) ?? "0:00"
    }
}
