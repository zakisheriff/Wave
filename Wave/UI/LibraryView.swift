import SwiftUI

struct LibraryView: View {
    @EnvironmentObject var appState: AppState
    @ObservedObject var libraryManager: LibraryManager
    @Binding var selection: SidebarView.SidebarItem?
    @State private var searchText = ""
    @State private var sortOption: SortOption = .name
    
    let columns = [
        GridItem(.adaptive(minimum: 160, maximum: 200), spacing: 20)
    ]
    
    var filteredItems: [MediaItem] {
        let categoryItems: [MediaItem]
        
        switch selection {
        case .videos:
            categoryItems = libraryManager.items.filter { libraryManager.category(for: $0) == .video }
        case .music:
            categoryItems = libraryManager.items.filter { libraryManager.category(for: $0) == .music }
        case .images:
            categoryItems = libraryManager.items.filter { libraryManager.category(for: $0) == .image }
        default:
            categoryItems = libraryManager.items
        }
        
        let sorted = libraryManager.sortItems(categoryItems, by: sortOption)
        
        if searchText.isEmpty {
            return sorted
        } else {
            return sorted.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        ScrollView {
            if libraryManager.isScanning {
                ProgressView("Scanning Library...")
                    .padding()
            } else if filteredItems.isEmpty {
                ContentUnavailableView("No Media Found", systemImage: "magnifyingglass", description: Text("Try changing your search or category."))
            } else {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(filteredItems) { item in
                        VStack {
                            ZStack {
                                Rectangle()
                                    .fill(.ultraThinMaterial)
                                    .aspectRatio(16/9, contentMode: .fit)
                                    .cornerRadius(12)
                                    .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                                
                                if let thumbnail = libraryManager.thumbnails[item.id] {
                                    Image(nsImage: thumbnail)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                                        .clipped()
                                        .cornerRadius(12)
                                } else {
                                    Image(systemName: icon(for: item))
                                        .font(.system(size: 40))
                                        .foregroundStyle(.white.opacity(0.5))
                                }
                                
                                if libraryManager.category(for: item) == .video || libraryManager.category(for: item) == .music {
                                    Image(systemName: "play.circle.fill")
                                        .font(.system(size: 40))
                                        .foregroundStyle(.white.opacity(0.9))
                                        .shadow(radius: 2)
                                }
                            }
                            
                            Text(item.title)
                                .lineLimit(1)
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundStyle(.secondary)
                        }
                        .padding(8)
                        .background(.ultraThinMaterial)
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                        .onTapGesture {
                            appState.currentMedia = item.url
                        }
                    }
                }
                .padding()
            }
        }
        .searchable(text: $searchText, placement: .toolbar)
        .navigationTitle(title(for: selection))
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Picker("Sort By", selection: $sortOption) {
                        ForEach(SortOption.allCases, id: \.self) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                } label: {
                    Label("Sort", systemImage: "arrow.up.arrow.down")
                }
            }
            
            ToolbarItem(placement: .primaryAction) {
                Button(action: { libraryManager.scanLibrary() }) {
                    Label("Scan Library", systemImage: "arrow.clockwise")
                }
            }
        }
        .onAppear {
            if libraryManager.items.isEmpty {
                libraryManager.scanLibrary()
            }
        }
        .background(Color.clear)
    }
    
    func icon(for item: MediaItem) -> String {
        switch libraryManager.category(for: item) {
        case .video: return "film"
        case .music: return "music.note"
        case .image: return "photo"
        default: return "doc"
        }
    }
    
    func title(for selection: SidebarView.SidebarItem?) -> String {
        switch selection {
        case .videos: return "Videos"
        case .music: return "Music"
        case .images: return "Images"
        default: return "Library"
        }
    }
}
