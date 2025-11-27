import Foundation
import AVFoundation
import ScreenCaptureKit
import Combine

class Recorder: NSObject, ObservableObject {
    @Published var isRecording = false
    @Published var availableDisplays: [SCDisplay] = []
    @Published var availableWindows: [SCWindow] = []
    
    private var stream: SCStream?
    private var captureSession: AVCaptureSession?
    private var movieOutput: AVCaptureMovieFileOutput?
    
    override init() {
        super.init()
        Task {
            await refreshContent()
        }
    }
    
    func refreshContent() async {
        do {
            let content = try await SCShareableContent.excludingDesktopWindows(false, onScreenWindowsOnly: true)
            DispatchQueue.main.async {
                self.availableDisplays = content.displays
                self.availableWindows = content.windows
            }
        } catch {
            print("Failed to fetch shareable content: \(error)")
        }
    }
    
    func startScreenRecording(display: SCDisplay) {
        let filter = SCContentFilter(display: display, excludingWindows: [])
        let config = SCStreamConfiguration()
        config.width = display.width
        config.height = display.height
        config.showsCursor = true
        
        do {
            let stream = SCStream(filter: filter, configuration: config, delegate: nil)
            try stream.addStreamOutput(self, type: .screen, sampleHandlerQueue: .global())
            stream.startCapture()
            self.stream = stream
            self.isRecording = true
        } catch {
            print("Failed to start screen capture: \(error)")
        }
    }
    
    func stopRecording() {
        if let stream = stream {
            stream.stopCapture()
            self.stream = nil
        }
        if let session = captureSession {
            session.stopRunning()
            self.captureSession = nil
        }
        self.isRecording = false
    }
    
    // Camera Recording
    func startCameraRecording() {
        let session = AVCaptureSession()
        session.sessionPreset = .high
        
        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device) else { return }
        
        if session.canAddInput(input) {
            session.addInput(input)
        }
        
        let output = AVCaptureMovieFileOutput()
        if session.canAddOutput(output) {
            session.addOutput(output)
        }
        self.movieOutput = output
        
        Task {
            session.startRunning()
            self.captureSession = session
            
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension("mov")
            output.startRecording(to: tempURL, recordingDelegate: self)
            
            DispatchQueue.main.async {
                self.isRecording = true
            }
        }
    }
}

extension Recorder: SCStreamOutput {
    func stream(_ stream: SCStream, didOutputSampleBuffer sampleBuffer: CMSampleBuffer, of type: SCStreamOutputType) {
        // Handle screen capture frames (encode to file)
        // For brevity, we are just capturing frames here. 
        // In a real app, we'd use AVAssetWriter to write these to disk.
    }
}

extension Recorder: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        print("Finished recording to: \(outputFileURL)")
        // Move to user selected location
    }
}
