# <div align="center">Wave</div>

<div align="center">
<strong>The Next-Generation Native Media Player for macOS</strong>
</div>

<br />

<div align="center">

<img src="https://img.shields.io/badge/macOS-26%20Tahoe-blue?style=for-the-badge&logo=apple" height="50" />
<img src="https://img.shields.io/badge/Swift-5.9+-orange?style=for-the-badge&logo=swift" height="50" />
<img src="https://img.shields.io/badge/License-MIT-green?style=for-the-badge" height="50" />

</div>

<br />

> **"It feels like the future of macOS media playback."**
>
> Wave isn't just a media player; it's a visual masterpiece.  
> Designed with the fluid, glassy aesthetics of **macOS 26 Tahoe**, it brings your videos and music to life with elegance, power, and zero compromises.

---

## 🌟 Vision

Wave's purpose is to be:

- **A next-generation native media player** for macOS
- **A beautifully crafted SwiftUI application** showcasing true Apple-level design
- **A powerful, versatile alternative** to bloated, outdated media players

---

## ✨ Why Wave?

Forget the clunky, feature-bloated media players of the past.  
Wave is built from the ground up to be **fast, beautiful, and truly native**.

---

## 🎨 Stunning "Liquid Glass" UI

- **Native Aesthetics**  
  Built with SwiftUI and designed to feel right at home on macOS Tahoe.

- **Unified Glass Interface**  
  A seamless, translucent design that merges perfectly with your desktop.

- **Liquid Interactions**  
  Smooth hover effects, animated controls, and premium glass-morphic elements throughout.

- **Zero-Latency Playback**  
  Instant response and buttery-smooth animations across the entire UI.

---

## 🚀 Powerful Performance

- **Dual-Engine Playback**  
  Native AVPlayer for MP4/MOV + VLCKit for MKV/WebM/AVI — best of both worlds.

- **Metal-Accelerated Rendering**  
  Hardware-accelerated video rendering for silky-smooth playback.

- **Real-Time Video Effects**  
  Adjust brightness, contrast, saturation, hue, and noise reduction on the fly using CoreImage.

- **Smart Format Detection**  
  Automatically switches between native and VLC engines based on file format.

---

## 🎬 Professional Features

- **Advanced Subtitle Support**  
  Native subtitle rendering with AVPlayerItemLegibleOutput.

- **AI-Powered Auto Subtitles**  
  Generate subtitles automatically using macOS Speech framework.

- **Thumbnail Scrubbing**  
  YouTube-style hover previews on the timeline for precise navigation.

- **Screen & Camera Recording**  
  Built-in recording using ScreenCaptureKit and AVCaptureSession.

- **Network Streaming**  
  Full support for HLS and HTTP streams.

- **Playlist Management**  
  Create and manage playlists with drag-and-drop support.

---

## 📁 Project Structure

```
Wave/
├── Wave/                          # Main SwiftUI macOS app
│   ├── WaveApp.swift             # App entry & lifecycle
│   ├── ContentView.swift         # Main UI & drop zone
│   ├── Core/                     # Core media engine
│   │   ├── MediaPlayer.swift    # Dual-engine player logic
│   │   └── FormatDetector.swift # Format detection
│   ├── UI/                       # All UI components
│   │   ├── UnifiedPlayerView.swift
│   │   ├── NativePlayerControls.swift
│   │   ├── VLCPlayerView.swift
│   │   ├── FluidSlider.swift
│   │   ├── GlassButton.swift
│   │   └── ...
│   ├── Features/                 # Advanced features
│   │   ├── LibraryManager.swift
│   │   ├── PlaylistManager.swift
│   │   ├── SubtitleGenerator.swift
│   │   ├── ThumbnailGenerator.swift
│   │   └── Recorder.swift
│   └── Assets.xcassets/          # App icons & resources
│
├── Wave.xcodeproj                # Xcode project file
└── README.md                     # Documentation
```

---

## 📥 Download & Install

You don't need to be a developer to use Wave. Just:

1. **Download the latest `.dmg`**  
   _(Coming soon to releases)_

2. Open the `.dmg`.

3. Drag **Wave** into **Applications**.

4. Launch the app and drop any video or audio file to play.

---

## 🛠️ For Developers

### 1. Clone the repository

```bash
git clone https://github.com/zakisheriff/Wave.git
cd Wave
```

### 2. Install Dependencies

Wave uses VLCKit via Swift Package Manager. Dependencies will be resolved automatically when you open the project.

### 3. Build

Open `Wave.xcodeproj` in Xcode → **Run (⌘ + R)**.

---

## 🎯 Supported Formats

### Video
**MP4** • **MOV** • **M4V** • **MKV** • **WebM** • **AVI** • **FLV** • **WMV** • **OGV** • **3GP**

### Audio
**MP3** • **M4A** • **AAC** • **WAV** • **AIFF** • **FLAC**

### Streaming
**HLS (m3u8)** • **HTTP Streams**

---

## 🎨 Design Philosophy

Wave follows the **macOS 26 Tahoe** design language:

- **Glassmorphism** — Translucent, layered materials with depth
- **Fluid Animations** — Spring-based, organic motion
- **Native Components** — 100% SwiftUI, zero custom hacks
- **Premium Feel** — Every interaction feels polished and intentional

---

## 🔮 Roadmap

- [ ] Audio equalizer with presets
- [ ] Advanced playlist features (shuffle, repeat modes)
- [ ] Picture-in-Picture support
- [ ] Chromecast/AirPlay integration
- [ ] Custom keyboard shortcuts
- [ ] Video conversion & export

---

## ☕️ Support the Project

If Wave enhanced your media experience or inspired you:

- Consider buying me a coffee
- It keeps development alive and motivates future updates

<div align="center">
<a href="https://buymeacoffee.com/zakisheriffw">
<img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" height="60" width="217">
</a>
</div>

---

## 📄 License

MIT License — see [LICENSE](LICENSE) for details.

---

<p align="center">
Made with Swift by <strong>Zaki Sheriff</strong>
</p>
