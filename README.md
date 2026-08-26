# DropShelf (Native Dropover Pro Clone for macOS)

A native, lightweight drag-and-drop utility for macOS built with Swift & SwiftUI. It brings the power of **Dropover Pro** with floating shelves, shake gestures, folder automation, and quick actions with **zero waiting delays and no paywalls**.

---

## ✨ Features (All Pro Features Unlocked)

- ⚡ **Instant Drag-and-Drop (0s Delay)**: No wait timer before dropping files.
- 🪟 **Floating Glass Shelves**: Multi-shelf support, stays floating on top across all Spaces (`NSPanel` + HUD blur material).
- 🖱️ **Shake Cursor to Activate**: Shake your mouse/trackpad cursor back and forth while dragging files to immediately summon a shelf right beneath your cursor.
- ⌨️ **Global Hotkey (`⌥ + Space`)**: Instantly create a new shelf at the mouse location from any app.
- 📦 **Bulk & Individual Drag-Out**: Drag individual items or use **"Drag All"** to move the entire collection to Finder, Mail, Slack, or any browser.
- 📁 **Folder Watcher (Pro)**: Automatically spawns a shelf when new files land in monitored folders (e.g., `Downloads` or `Desktop`).
- 🛠️ **Built-in File & Image Tools**:
  - **Convert Images**: Convert images directly to PNG or JPEG with 1 click.
  - **Resize Images**: Scale images down to 50% or 25%.
  - **Compress to Zip**: 1-click archive creation.
  - **Copy All to Clipboard**: Fast clipboard access for files and text.
- 🎨 **Custom Color Themes & Pinning**: Pin shelves to stay permanently open or color code them (Blue, Purple, Indigo, Orange, Emerald, Graphite).
- 🕒 **Shelf History**: Automatically stores recent items so you can restore past drops.

---

## 🚀 How to Run

### Option 1: Open the Native `.app` Bundle
Double-click [`DropShelf.app`](file:///Users/nghiadang/CKB/vim-motion-lab/DropShelf/DropShelf.app) or run:
```bash
open DropShelf.app
```

### Option 2: Run via Terminal
```bash
cd DropShelf
swift run
```

### Rebuilding
To recompile the release `.app` bundle at any time:
```bash
cd DropShelf
./bundle.sh
```

---

## 🔐 System Permissions
On first launch, macOS may prompt for **Accessibility** permission so DropShelf can detect the mouse shake gesture while you are dragging items across other applications.
- Go to **System Settings > Privacy & Security > Accessibility** and ensure **DropShelf** is enabled.
