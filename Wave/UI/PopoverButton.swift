import SwiftUI

struct PopoverButton<Content: View>: View {
    let icon: String
    let title: String
    let content: () -> Content
    @State private var isPresented = false
    
    var body: some View {
        Button(action: { isPresented.toggle() }) {
            Label(title, systemImage: icon)
        }
        .popover(isPresented: $isPresented, arrowEdge: .bottom) {
            content()
                .padding()
        }
    }
}
