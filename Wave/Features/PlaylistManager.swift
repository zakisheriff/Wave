import Foundation
import Combine
import SwiftUI

struct MediaItem: Identifiable, Hashable {
    let id = UUID()
    let url: URL
    var title: String {
        url.lastPathComponent
    }
    var duration: Double = 0.0
}

class PlaylistManager: ObservableObject {
    @Published var items: [MediaItem] = []
    @Published var currentItemIndex: Int?
    
    func addItem(url: URL) {
        let item = MediaItem(url: url)
        items.append(item)
    }
    
    func removeItem(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
    }
    
    func moveItem(from source: IndexSet, to destination: Int) {
        items.move(fromOffsets: source, toOffset: destination)
    }
    
    func nextItem() -> MediaItem? {
        guard let index = currentItemIndex, index + 1 < items.count else { return nil }
        currentItemIndex = index + 1
        return items[currentItemIndex!]
    }
    
    func previousItem() -> MediaItem? {
        guard let index = currentItemIndex, index - 1 >= 0 else { return nil }
        currentItemIndex = index - 1
        return items[currentItemIndex!]
    }
}
