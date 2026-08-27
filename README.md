# DropShelf

A lightweight, native macOS drag-and-drop productivity utility built with Swift and SwiftUI. DropShelf holds files, images, links, and text snippets on floating shelves so you can navigate between apps and spaces without losing your drag session.

---

## Features

- **Shake Cursor to Activate**: Shake your cursor left and right while dragging any file or image to summon a shelf directly under your mouse pointer.
- **Floating HUD Panels**: Frosted translucent shelves that remain accessible across full-screen apps and multiple macOS Spaces.
- **Card Stack & Expandable Grid**: Files automatically group into a physical card stack. Click the file count pill to expand into a full grid with individual previews and removal controls.
- **Single & Bulk Drag-Out**: Drag out individual items or grab the entire stack to drop all items into Finder, Slack, Mail, or your browser in one gesture.
- **Global Hotkey**: Press `Option + Space` anywhere to spawn a shelf on demand.
- **Folder Watcher**: Automatically open a shelf when new files arrive in your `Downloads` or `Desktop` folder.
- **Quick File Tools**:
  - **Vision OCR**: Extract text from images and screenshots directly to the clipboard using on-device Apple Vision.
  - **Background Removal**: Generate a transparent PNG cutout with one click.
  - **Metadata Scrubbing**: Strip EXIF camera settings and GPS location data from photos.
  - **Image Tools**: Batch convert to PNG/JPEG or scale to 50%/25%.
  - **Archive**: Compress shelf items into a zip file.
- **Subtle Audio Feedback**: Native macOS system sounds for shelf creation, drop, and dismissal.

---

## Installation

### Download Pre-built App
1. Download **[DropShelf-v1.0.0-macOS.zip](https://github.com/nghiadang391/DropShelf/releases/latest/download/DropShelf-v1.0.0-macOS.zip)**.
2. Unzip and move `DropShelf.app` to your `/Applications` folder.
3. On first launch: Right-click `DropShelf.app`, select **Open**, and click **Open**.

### Build from Source
```bash
git clone https://github.com/nghiadang391/DropShelf.git
cd DropShelf
./bundle.sh
open DropShelf.app
```

---

## Requirements

- macOS 13.0 (Ventura) or later
- Apple Silicon (M1/M2/M3/M4) or Intel Mac
