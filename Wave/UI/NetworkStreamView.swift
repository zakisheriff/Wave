import SwiftUI

struct NetworkStreamView: View {
    @EnvironmentObject var appState: AppState
    @State private var urlString: String = ""
    @State private var recentStreams: [String] = []
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Open Network Stream")
                .font(.title2)
            
            HStack {
                TextField("Enter URL (http, https, hls)...", text: $urlString)
                    .textFieldStyle(.roundedBorder)
                
                Button("Play") {
                    if let url = URL(string: urlString) {
                        appState.currentMedia = url
                        addToRecents(urlString)
                    }
                }
                .disabled(urlString.isEmpty)
            }
            .frame(maxWidth: 500)
            
            if !recentStreams.isEmpty {
                List {
                    Section(header: Text("Recent Streams")) {
                        ForEach(recentStreams, id: \.self) { stream in
                            Text(stream)
                                .onTapGesture {
                                    urlString = stream
                                }
                        }
                    }
                }
                .frame(maxWidth: 500)
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("Network")
    }
    
    func addToRecents(_ stream: String) {
        if !recentStreams.contains(stream) {
            recentStreams.insert(stream, at: 0)
        }
    }
}
