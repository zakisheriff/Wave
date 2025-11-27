import SwiftUI

struct AudioEffectsView: View {
    @ObservedObject var player: MediaPlayer
    @State private var eqBands: [Float] = Array(repeating: 0.0, count: 10)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Audio Effects")
                .font(.headline)
            
            // Volume Boost
            VStack(alignment: .leading) {
                Text("Preamp / Volume Boost")
                Slider(value: $player.volume, in: 0...1) // Native AVPlayer limit
            }
            
            Divider()
            
            Text("Equalizer (10-Band)")
                .font(.subheadline)
            
            HStack(spacing: 8) {
                ForEach(0..<10) { index in
                    VStack {
                        Slider(value: $eqBands[index], in: -12...12)
                            .rotationEffect(.degrees(-90))
                            .frame(width: 20, height: 100)
                        
                        Text(bandLabel(index))
                            .font(.system(size: 8))
                            .monospacedDigit()
                    }
                }
            }
            .frame(height: 140)
            
            Divider()
            
            Toggle("Spatial Audio", isOn: .constant(false))
                .disabled(true) // Requires specific hardware/content
        }
        .frame(width: 300)
        .padding()
    }
    
    func bandLabel(_ index: Int) -> String {
        let labels = ["32", "64", "125", "250", "500", "1K", "2K", "4K", "8K", "16K"]
        return labels[index]
    }
}
