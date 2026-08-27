# DropShelf

A sleek, native macOS drag-and-drop productivity utility built with Swift & SwiftUI. DropShelf lets you easily collect, organize, preview, and process files, folders, snippets, and images across applications with floating shelves and smart gesture activation.

---

## ✨ Features

- ⚡ **Instant Drag-and-Drop**: Effortlessly hold files and snippets in floating drop zones.
- 🪟 **Floating Glass Shelves**: Translucent dark squircle HUD panels that stay accessible across all Spaces and fullscreen windows.
- 🖱️ **Shake Cursor to Activate**: Shake your mouse or trackpad back and forth while dragging files to immediately summon a shelf right beneath your pointer.
- 🗂️ **Physical Card Stack UI**: Groups multiple dropped files into an elegant stacked card view.
- 🔍 **Expandable File Grid**: Click the file count pill (e.g. `3 Files 〉`) to expand and view individual thumbnails, filenames, and details.
- ⌨️ **Global Hotkey (`⌥ + Space`)**: Summon a new shelf anywhere with a keystroke.
- 📦 **Bulk & Individual Drag-Out**: Drag individual items or drag the entire card stack to Finder, Slack, Mail, or web browsers.
- 📁 **Folder Watcher**: Automatically summons a shelf when new files land in monitored folders (e.g., `Downloads` or `Desktop`).
- 🛠️ **Built-in Vision & File Tools**:
  - **Vision OCR**: Extract text from images directly to your clipboard using on-device Apple Vision.
  - **Remove Background**: 1-click transparent background cutout generation.
  - **Strip EXIF & Location**: Remove camera settings and GPS metadata before sharing photos.
  - **Convert Images**: Convert images to PNG or JPEG with 1 click.
  - **Resize Images**: Scale images to 50% or 25%.
  - **Compress to Zip**: 1-click archive creation.
  - **Copy to Clipboard**: Fast clipboard access for files and text.
- 🔊 **Subtle Audio Cues**: Native macOS sound feedback on shelf spawn, drop, and dismiss.
- 🕒 **Shelf History**: Automatically stores recent items so you can restore past drops.

---

## 🚀 Installation & Running

### Option 1: Download Pre-built App (Recommended)
1. Download **[DropShelf-v1.0.0-macOS.zip](https://github.com/nghiadang391/DropShelf/releases/latest/download/DropShelf-v1.0.0-macOS.zip)** from GitHub Releases.
2. Unzip and drag `DropShelf.app` into your `/Applications` folder.
3. On first launch: Right-click `DropShelf.app` > choose **Open** > click **Open**.

### Option 2: Build from Source
To build and package the release `.app` bundle:
```bash
git clone https://github.com/nghiadang391/DropShelf.git
cd DropShelf
./bundle.sh
open DropShelf.app
```

---

## 💻 Requirements
- macOS 13.0 (Ventura) or later
- Apple Silicon or Intel Mac
