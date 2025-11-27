import SwiftUI

struct SidebarView: View {
    @Binding var selection: SidebarItem?
    
    enum SidebarItem: Hashable {
        case all
        case videos
        case music
        case images
        case playlist
        case network
        case recorder
    }
    
    var body: some View {
        List(selection: $selection) {
            Section(header: Text("Library")) {
                Label("All Media", systemImage: "square.grid.2x2")
                    .tag(SidebarItem.all)
                Label("Videos", systemImage: "film")
                    .tag(SidebarItem.videos)
                Label("Music", systemImage: "music.note")
                    .tag(SidebarItem.music)
                Label("Images", systemImage: "photo")
                    .tag(SidebarItem.images)
                Label("Network", systemImage: "globe")
                    .tag(SidebarItem.network)
            }
            
            Section(header: Text("Playlists")) {
                Label("Current Playlist", systemImage: "music.note.list")
                    .tag(SidebarItem.playlist)
            }
            
            Section(header: Text("Tools")) {
                Label("Recorder", systemImage: "record.circle")
                    .tag(SidebarItem.recorder)
            }
        }
        .listStyle(.sidebar)
        .scrollContentBackground(.hidden)
    }
}
