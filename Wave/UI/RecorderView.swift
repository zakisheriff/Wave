import SwiftUI
import ScreenCaptureKit

struct RecorderView: View {
    @StateObject private var recorder = Recorder()
    @State private var selectedDisplay: SCDisplay?
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Screen & Camera Recorder")
                .font(.largeTitle)
            
            HStack(spacing: 40) {
                // Screen Capture
                VStack {
                    Image(systemName: "display")
                        .font(.system(size: 50))
                    Text("Screen")
                    
                    Picker("Display", selection: $selectedDisplay) {
                        Text("Select Display").tag(nil as SCDisplay?)
                        ForEach(recorder.availableDisplays, id: \.displayID) { display in
                            Text("Display \(display.displayID)").tag(display as SCDisplay?)
                        }
                    }
                    .frame(width: 150)
                    
                    Button(recorder.isRecording ? "Stop" : "Record Screen") {
                        if recorder.isRecording {
                            recorder.stopRecording()
                        } else if let display = selectedDisplay {
                            recorder.startScreenRecording(display: display)
                        }
                    }
                    .disabled(selectedDisplay == nil)
                    .controlSize(.large)
                }
                .padding()
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(12)
                
                // Camera Capture
                VStack {
                    Image(systemName: "camera")
                        .font(.system(size: 50))
                    Text("Camera")
                    
                    Button(recorder.isRecording ? "Stop" : "Record Camera") {
                        if recorder.isRecording {
                            recorder.stopRecording()
                        } else {
                            recorder.startCameraRecording()
                        }
                    }
                    .controlSize(.large)
                }
                .padding()
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(12)
            }
        }
        .padding()
        .onAppear {
            Task {
                await recorder.refreshContent()
                selectedDisplay = recorder.availableDisplays.first
            }
        }
    }
}
